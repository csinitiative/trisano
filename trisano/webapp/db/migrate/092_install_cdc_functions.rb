# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
class InstallCdcFunctions < ActiveRecord::Migration
  
  def self.up
    begin
      execute "Create Language plpgsql"
    rescue Exception => e
      say "Likely 'plpgsql' already exists. Moving on..."
    end      

    transaction do
      execute(trisano_export_fn)
      execute(trisano_cdc_fn)
    end
  end

  def self.down
    transaction do
      # execute('DROP FUNCTION fnTrisanoExport(integer)')
      # execute('DROP FUNCTION  fnTrisanoExportNonGenericCdc (iexport_id integer, iexport_name varchar(50))')
    end
  end

  def self.trisano_export_fn
<<EXPORT
CREATE OR REPLACE FUNCTION  fnTrisanoExport (integer) RETURNS varchar 
AS $$
declare 
	iexport_id  ALIAS  FOR $1;
	vexport_name varchar(50);
	return_status varchar(50);
BEGIN
-- If the passed in value is NULL, then error!
	IF iexport_id IS NULL  
	THEN RETURN 'NULL VALUE PASSED';
	END IF;
-- If the passed in value is NOT NULL, but is not found in the export_names table, then error!
	SELECT export_name INTO vexport_name FROM export_names WHERE id = iexport_id;
	if vexport_name is NULL
	THEN RETURN 'Invalid export_name.id';
	END IF;

-- Get all the columns for the export_name that will need to be retrieved from the database.
	IF (vexport_name = 'CDC')
	THEN

	   return_status = fnTrisanoExportNonGenericCdc(iexport_id, vexport_name);
--	   return_status = fnTrisanoExportCdc(iexport_id, vexport_name);
	   return return_status;
--	   IF substring(return_status,1,7) = 'SUCCESS'
--	   THEN
--		return 'SUCCESS';
--	   ELSE
--		return 'FAILURE';
--	   END IF;
	ELSE
		return vexport_name;
	END IF;

END;
$$ 
LANGUAGE plpgsql;

EXPORT
  end

  def self.trisano_cdc_fn
<<CDCEXPORT
CREATE OR REPLACE FUNCTION  fnTrisanoExportNonGenericCdc (iexport_id integer, iexport_name varchar(50)) RETURNS varchar 
AS $$

-- to build the columns
DECLARE theCols cdc_exports%ROWTYPE;
DECLARE cols 	CURSOR  FOR SELECT * 
    FROM cdc_exports 
    ORDER BY start_position;


DECLARE theCreate	varchar(5000);
DECLARE theSQL		varchar(10000);
--DECLARE	theSelect	varchar(2000);
--DECLARE theFrom		varchar(2000);
--DECLARE thePredicate	varchar(2000);
DECLARE theRow		integer;

BEGIN
-- do some prep work
	theRow		:= 0;
	theCreate	:= 'CREATE TABLE '|| iexport_name || ' ( ';
	theSQL		:= 'SELECT
   CAST(exp_rectype AS CHAR(1))
,  CAST(exp_update AS CHAR(1))
,  CAST(exp_state AS CHAR(2))
,  CAST(exp_year  AS CHAR(2))
,  CAST(exp_caseid AS CHAR(6))
,  CAST(exp_site AS CHAR(3))
,  CAST(exp_week AS CHAR(2))
,  CAST(exp_event AS CHAR(5))
,  CAST(exp_count AS CHAR(6))
,  CAST(exp_county AS CHAR(3))
,  CAST(COALESCE(exp_birthdate,''99999999'',exp_birthdate) AS CHAR(8)) AS exp_birthdate 
,  CAST(exp_age   AS CHAR(3))
,  CAST(exp_agetype  AS CHAR(1))
,  CAST(exp_sex   AS CHAR(1))
,  CAST(exp_race   AS CHAR(1))
,  CAST(exp_ethnicity  AS CHAR(1))
-- have to do eventdate and datetype in separate query
,  CAST(CASE 
    WHEN 	event_onset_date <= first_reported_ph_date 
	AND 	event_onset_date <= collection_date 
	AND 	event_onset_date <= lab_test_date
    THEN event_onset_date
    WHEN 	first_reported_ph_date <= event_onset_date 
	AND 	first_reported_ph_date <= collection_date 
	AND 	first_reported_ph_date <= lab_test_date
    THEN first_reported_ph_date
    WHEN 	collection_date <= event_onset_date
	AND 	collection_date <= first_reported_ph_date
	AND 	collection_date <= lab_test_date
    THEN collection_date
    WHEN	lab_test_date <= event_onset_date
	AND	lab_test_date <= first_reported_ph_date
	AND	lab_test_date <= collection_date
    THEN lab_test_date
    END AS CHAR(6)) AS exp_eventdate
,  CAST(CASE 
    WHEN 	event_onset_date <= first_reported_ph_date 
	AND 	event_onset_date <= collection_date 
	AND 	event_onset_date <= lab_test_date
    THEN ''1''
    WHEN 	first_reported_ph_date <= event_onset_date 
	AND 	first_reported_ph_date <= collection_date 
	AND 	first_reported_ph_date <= lab_test_date
    THEN ''4''
    WHEN 	collection_date <= event_onset_date
	AND 	collection_date <= first_reported_ph_date
	AND 	collection_date <= lab_test_date
    THEN ''9''
    WHEN	lab_test_date <= event_onset_date
	AND	lab_test_date <= first_reported_ph_date
	AND	lab_test_date <= collection_date
    THEN ''3''
    ELSE ''9''
    END AS CHAR(6))  as exp_datetype
, CAST(exp_casestatus AS CHAR(1))  
, CAST(exp_imported AS CHAR(1))
, CAST(exp_outbreak    AS CHAR(1))
, CAST(exp_future   AS CHAR(5))
FROM
(
SELECT events.id
  , events."MMWR_week" AS mmwr_week
  , addresses.county_id
  , people.birth_date
  , people.approximate_age_no_birthday
  , people.age_type_id
  , people.birth_gender_id
  , people_races.race_id
  , people.ethnicity_id
  , coalesce(events.event_onset_date,''12/31/9998'', event_onset_date) AS event_onset_date
  , coalesce(events."first_reported_PH_date",''12/31/9998'', events."first_reported_PH_date")
	  AS first_reported_ph_date
  , coalesce(lab_results.collection_date,''12/31/9998'', lab_results.collection_date ) AS collection_date
  , coalesce(lab_results.lab_test_date,''12/31/9998'', lab_results.lab_test_date )  AS lab_test_date
  , events.event_status
  , events.imported_from_id
  , events.outbreak_associated_id
  , county.the_code AS county_code
  , ageType.the_code AS age_type
  , gender.the_code AS gender
  , CASE 
      WHEN events.cdc_update = true THEN ''T''
      ELSE ''F''
      END
  , CASE 
      WHEN events.sent_to_cdc = true THEN ''T''
      ELSE ''F''
      END
-- these columns are to get the conversion values
  , CAST(''M''  AS char(1)) AS exp_rectype
  , CAST('' ''  AS char(1)) AS exp_update
  , CAST(''49'' AS char(2)) AS exp_state
  , SUBSTR(EXTRACT(YEAR from CURRENT_DATE), 3,2) AS exp_year 
  , LPAD(events.id, 6, '' '') AS exp_caseid
  , CAST(''S01'' AS CHAR(3)) AS exp_site
  , events."MMWR_week" AS exp_week
  , disease_name AS exp_event
  , CAST(''000001'' AS CHAR(6))  as exp_count
  , COALESCE(valcounty.value_to, ''999'', valcounty.value_to) AS exp_county
  , EXTRACT(YEAR FROM people.birth_date) 
      || LPAD(EXTRACT(MONTH FROM people.birth_date), 2, ''0'') 
      ||  LPAD(EXTRACT(DAY FROM people.birth_date), 2, ''0'') AS exp_birthdate  
  , people.approximate_age_no_birthday AS exp_age 
  , COALESCE(ageType.the_code, ''9'', ageType.the_code) AS exp_agetype 
  , COALESCE(valgender.value_to,''U'', valgender.value_to) AS exp_sex  
  , COALESCE(valrace.value_to, ''U'', valrace.value_to) AS exp_race  
  , COALESCE(valethnicity.value_to, ''U'', valethnicity.value_to)  AS exp_ethnicity 
-- have to do eventdate and datetype in separate query
--  , ''evdate'' AS exp_eventdate
--  , ''X'' as exp_datetype
  , COALESCE(valcasestatus.value_to, ''9'', valcasestatus.value_to) AS exp_casestatus  
  , COALESCE(valimported.value_to, ''9'', valimported.value_to) AS exp_imported
  , CAST(''0'' AS CHAR(1)) AS exp_outbreak   
  , CAST(''     '' AS VARCHAR(7)) AS exp_future  
FROM 
    events 
    INNER JOIN participations
      ON  events.id = participations.event_id
    INNER JOIN entities
      ON  participations.primary_entity_id = entities.id
    LEFT OUTER JOIN entities_locations
      ON  entities_locations.entity_id = entities.id
    LEFT OUTER JOIN addresses
      ON  addresses.location_id = entities_locations.location_id
    INNER JOIN disease_events
      ON  events.id = disease_events.event_id
    INNER JOIN diseases
      ON  disease_events.disease_id = diseases.id
    INNER JOIN people
      ON  people.entity_id = entities.id
    LEFT  OUTER JOIN people_races
      ON  people_races.entity_id = people.entity_id
    LEFT  OUTER JOIN lab_results
      ON  lab_results.participation_id = participations.id
    LEFT  OUTER JOIN codes rolecode
      ON  rolecode.id = participations.role_id
    LEFT  OUTER JOIN external_codes locprimary
      ON  locprimary.id = entities_locations.primary_yn_id
    LEFT  OUTER JOIN external_codes county
      ON  county.id = addresses.county_id
    LEFT  OUTER JOIN external_codes ageType
      ON  ageType.id = people.age_type_id
    LEFT  OUTER JOIN external_codes gender
      ON  gender.id = people.birth_gender_id
    LEFT  OUTER JOIN external_codes race
      ON  race.id = people_races.race_id
    LEFT  OUTER JOIN external_codes ethnicity
      ON  ethnicity.id = people.ethnicity_id
    LEFT  OUTER JOIN external_codes imported
      ON  imported.id = events.imported_from_id
-- now, get the conversion values
    LEFT  OUTER JOIN export_conversion_values valgender
      ON  valgender.value_from  = gender.the_code
    LEFT  OUTER JOIN export_conversion_values valcounty
      ON  valcounty.value_from  = county.the_code
    LEFT  OUTER JOIN export_conversion_values valrace
      ON  valrace.value_from = race.the_code
    LEFT  OUTER JOIN export_conversion_values valethnicity
      ON  valethnicity.value_from = ethnicity.the_code
    LEFT  OUTER JOIN export_conversion_values valcasestatus
      ON  valcasestatus.value_from = events.event_status
    LEFT  OUTER JOIN export_conversion_values valimported
      ON  valimported.value_from = imported.the_code
 WHERE 
    rolecode.the_code = ''I'' and rolecode.code_name = ''participant''
 and locprimary.the_code = ''Y'' and locprimary.code_name = ''yesno''
 ) AS b '
;

-- Get all the columns for the export_name that will need to be retrieved from the database
	TRUNCATE TABLE cdc_exports;  -- first truncate the table
	-- now insert the data from export_columns
	INSERT INTO cdc_exports 
	(	type_data
	, export_column_name
	, is_required
	, start_position
	, length_to_output
	, table_name
	, column_name
	)
	SELECT 
	type_data
	, export_column_name
	, is_required
	, start_position
	, length_to_output
	, table_name
	, column_name
	FROM export_columns
	WHERE export_name_id = iexport_id
	;

	OPEN cols
	;

	LOOP
		FETCH cols
		INTO 
		theCols
		;
		EXIT WHEN NOT FOUND;

		theRow := theRow + 1;
		theCreate := theCreate || theCols.export_column_name || '  varchar('|| theCols.length_to_output || '),';
	END LOOP;
	theCreate	:= substr(theCreate,1,length(theCreate)-1) || ');';

	CLOSE cols
	;

-- OK, now it is time to build the output table with the conversions
	IF (select count(*) from information_schema.tables where table_name = 'cdc') = 1
	THEN
	  execute 'DROP TABLE ' || iexport_name || ' ;';  -- first drop the output table
	END IF;

--	insert into thestring (thesql) values (theCreate);
	execute theCreate;  -- create the table
	
	execute 'INSERT INTO ' || iexport_name || '   ' || theSQL || ';';

	return 'SUCCESS ' || cast( theRow as varchar(5));
END;
$$ 
LANGUAGE plpgsql;

CDCEXPORT
    end
end
