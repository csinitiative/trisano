--drop view v_export_cdc;
SET datestyle TO MDY;
CREATE VIEW v_export_cdc AS
SELECT  DISTINCT
  cast(exp_rectype as char(1))
, cast(exp_update as char(1))
,  cast(exp_state as char(2))
,  cast(exp_year as char(2))
,  cast(exp_caseid  as char(6))
,  cast(exp_site as char(3))
,  cast(exp_week as char(2))
,  cast(exp_event as char(5))
,  cast(exp_count as char(5))
,  cast(exp_county as char(3))
,  cast(exp_birthdate as char(8) )
--,  cast(COALESCE(exp_birthdate,'99999999',exp_birthdate) as char(8)) AS exp_birthdate
,  cast(exp_age   as char(3))
,  cast(exp_agetype  as char(1))
,  cast(exp_sex   as char(1))
,  cast(exp_race  as char(1))
,  cast(exp_ethnicity  as char(1))
-- have to do eventdate and datetype in separate query
,  CASE 
    WHEN 	event_onset_date <= first_reported_ph_date 
	AND 	event_onset_date <= collection_date 
	AND 	event_onset_date <= lab_test_date
    THEN cast(substr(EXTRACT(YEAR FROM event_onset_date),3,4) 
      || LPAD(EXTRACT(MONTH FROM event_onset_date), 2, '0') 
      || LPAD(EXTRACT(DAY FROM event_onset_date), 2, '0') as char(6))
    WHEN 	first_reported_ph_date <= event_onset_date 
	AND 	first_reported_ph_date <= collection_date 
	AND 	first_reported_ph_date <= lab_test_date
    THEN cast(substr(EXTRACT(YEAR FROM first_reported_ph_date),3,4) 
      || LPAD(EXTRACT(MONTH FROM first_reported_ph_date), 2, '0') 
      || LPAD(EXTRACT(DAY FROM first_reported_ph_date), 2, '0') as char(6))
    WHEN 	collection_date <= event_onset_date
	AND 	collection_date <= first_reported_ph_date
	AND 	collection_date <= lab_test_date
    THEN cast(substr(EXTRACT(YEAR FROM collection_date),3,4) 
      || LPAD(EXTRACT(MONTH FROM collection_date), 2, '0') 
      || LPAD(EXTRACT(DAY FROM collection_date), 2, '0') as char(6))
    WHEN	lab_test_date <= event_onset_date
	        AND	lab_test_date <= first_reported_ph_date
	AND	lab_test_date <= collection_date
    THEN cast(substr(EXTRACT(YEAR FROM lab_test_date),3,4) 
      || LPAD(EXTRACT(MONTH FROM lab_test_date), 2, '0') 
      || LPAD(EXTRACT(DAY FROM lab_test_date), 2, '0') as char(6))
    END AS exp_eventdate
,  CASE 
    WHEN 	event_onset_date <= first_reported_ph_date 
	AND 	event_onset_date <= collection_date 
	AND 	event_onset_date <= lab_test_date
    THEN cast('1' as char(1))
    WHEN 	first_reported_ph_date <= event_onset_date 
	AND 	first_reported_ph_date <= collection_date 
	AND 	first_reported_ph_date <= lab_test_date
    THEN cast('4' as char(1))
    WHEN 	collection_date <= event_onset_date
	AND 	collection_date <= first_reported_ph_date
	AND 	collection_date <= lab_test_date
    THEN cast('9' as char(1))
    WHEN	lab_test_date <= event_onset_date
	AND	lab_test_date <= first_reported_ph_date
	AND	lab_test_date <= collection_date
    THEN cast('3' as char(1))
    ELSE cast('9' as char(1))
    END  as exp_datetype
, cast(exp_casestatus   as char(2))
, cast(exp_imported as char(2))
, cast(exp_outbreak  as char(2))
, cast(exp_future  as char(2))
, disease_name
, disease_id
, mmwr_week
, mmwr_year
, udoh_case_status_id
, event_onset_date
, event_status
, age_at_onset
, age_type_id
FROM
(
SELECT events.id
  , events."MMWR_week" AS mmwr_week
  , events."MMWR_year" AS mmwr_year
  , events.udoh_case_status_id AS udoh_case_status_id
  , addresses.county_id
  , people.birth_date
  , events.age_at_onset AS age_at_onset
  , events.age_type_id AS age_type_id
  , people.birth_gender_id
  , people_races.race_id
  , people.ethnicity_id
  , coalesce(events.event_onset_date,'12/31/9998', event_onset_date) AS event_onset_date
  , coalesce(events."first_reported_PH_date",'12/31/9998', events."first_reported_PH_date")
	  AS first_reported_ph_date
  , coalesce(lab_results.collection_date,'12/31/9998', lab_results.collection_date ) AS collection_date
  , coalesce(lab_results.lab_test_date,'12/31/9998', lab_results.lab_test_date )  AS lab_test_date
  , events.event_status
  , events.imported_from_id
  , events.outbreak_associated_id
  , county.the_code AS county_code
  , ageType.the_code AS age_type
  , gender.the_code AS gender
  , CASE 
      WHEN events.cdc_update = true THEN 'T'
      ELSE 'F'
      END
  , CASE 
      WHEN events.sent_to_cdc = true THEN 'T'
      ELSE 'F'
      END
-- these columns are to get the conversion values
  , CAST('M'  AS char(1)) AS exp_rectype
  , CAST(' '  AS char(1)) AS exp_update
  , CAST('49' AS char(2)) AS exp_state
  , SUBSTR(EXTRACT(YEAR from CURRENT_DATE), 3,2) AS exp_year 
  , SUBSTR(events.record_number, 5) AS exp_caseid
  , CAST('S01' AS CHAR(3)) AS exp_site
  , events."MMWR_week" AS exp_week
  , cast(coalesce(valdisease.value_to, '99999', valdisease.value_to) as char(5)) AS exp_event
  , disease_name AS disease_name
  , diseases.id as disease_id
  , CAST('00001' AS CHAR(6))  as exp_count
  , COALESCE(valcounty.value_to, '999', valcounty.value_to) AS exp_county
  , cast(coalesce(EXTRACT(YEAR FROM people.birth_date) 
      || LPAD(EXTRACT(MONTH FROM people.birth_date), 2, '0') 
      ||  LPAD(EXTRACT(DAY FROM people.birth_date), 2, '0'),'99999999',
	EXTRACT(YEAR FROM people.birth_date) 
	|| LPAD(EXTRACT(MONTH FROM people.birth_date), 2, '0') 
	||  LPAD(EXTRACT(DAY FROM people.birth_date), 2, '0')) as char(8)) 
    AS exp_birthdate
  , people.approximate_age_no_birthday AS exp_age  
  , COALESCE(ageType.the_code, '9', ageType.the_code) AS exp_agetype 
  , COALESCE(gender.the_code, 'U', gender.the_code) AS exp_sex
  , COALESCE(valrace.value_to, 'U', valrace.value_to) AS exp_race  
  , COALESCE(valethnicity.value_to, 'U', valethnicity.value_to)  AS exp_ethnicity 
-- have to do eventdate and datetype in separate query
--  , 'evdate' AS exp_eventdate
--  , 'X' as exp_datetype
  , COALESCE(valcasestatus.value_to, '9', valcasestatus.value_to) AS exp_casestatus
  , COALESCE(valimported.value_to, '9', valimported.value_to) AS exp_imported
  , CAST('0' AS CHAR(1)) AS exp_outbreak   
  , CAST('     ' AS CHAR(5)) AS exp_future 
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
      AND rolecode.the_code = 'I' and rolecode.code_name = 'participant'
   LEFT  OUTER JOIN external_codes locprimary
      ON  locprimary.id = entities_locations.primary_yn_id
      AND locprimary.the_code = 'Y' and locprimary.code_name = 'yesno'
    LEFT  OUTER JOIN external_codes county
      ON  county.id = addresses.county_id
    LEFT  OUTER JOIN external_codes ageType
        ON  ageType.id = events.age_type_id
--      ON  ageType.id = people.age_type_id
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
      AND valcounty.export_column_id = 11
    LEFT  OUTER JOIN export_conversion_values valrace
      ON  valrace.value_from = race.the_code
      AND valrace.export_column_id = 16
    LEFT  OUTER JOIN export_conversion_values valethnicity
      ON  valethnicity.value_from = ethnicity.the_code
      AND valethnicity.export_column_id = 17
    LEFT  OUTER JOIN export_conversion_values valcasestatus
      ON  valcasestatus.value_from = events.event_status
      AND valcasestatus.export_column_id = 20
    LEFT  OUTER JOIN export_conversion_values valimported
      ON  valimported.value_from = imported.the_code
      AND valimported.export_column_id = 21
    LEFT  OUTER JOIN export_conversion_values valdisease
      ON  valdisease.value_from = diseases.disease_name
      AND valdisease.export_column_id = 9
   ) AS b
;