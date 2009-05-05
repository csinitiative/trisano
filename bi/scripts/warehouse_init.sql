-- Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
--
-- This file is part of TriSano.
--
-- TriSano is free software: you can redistribute it and/or modify it under the
-- terms of the GNU Affero General Public License as published by the
-- Free Software Foundation, either version 3 of the License,
-- or (at your option) any later version.
--
-- TriSano is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

CREATE SCHEMA trisano;
ALTER SCHEMA trisano OWNER TO trisano_su;
CREATE LANGUAGE plpgsql;
-- NOTE: Adjust this user to the DEST_DB_USER 
ALTER SCHEMA public OWNER TO trisano_su;
GRANT USAGE ON SCHEMA trisano TO trisano_ro;

CREATE TABLE trisano.current_schema_name (
    schemaname TEXT NOT NULL
);
TRUNCATE TABLE trisano.current_schema_name;
INSERT INTO trisano.current_schema_name VALUES ('warehouse_a');

CREATE TABLE trisano.etl_success (
    success BOOLEAN,
    entrydate TIMESTAMPTZ DEFAULT NOW()
);
INSERT INTO trisano.etl_success (success) VALUES (FALSE);

CREATE OR REPLACE FUNCTION trisano.prepare_etl() RETURNS BOOLEAN AS $$
BEGIN
    RAISE NOTICE 'Preparing for ETL process by creating staging schema';
    EXECUTE 'DROP SCHEMA IF EXISTS staging CASCADE';
    CREATE SCHEMA staging;
    EXECUTE 'DROP SCHEMA IF EXISTS public CASCADE';
    CREATE SCHEMA public;
    TRUNCATE TABLE trisano.etl_success;
    INSERT INTO trisano.etl_success (success) VALUES (FALSE);
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trisano.swap_schemas() RETURNS BOOLEAN AS $$
DECLARE
    cur_schema TEXT;
    new_schema TEXT;
    tmp TEXT;
    viewname TEXT;
    validetl BOOLEAN;
BEGIN
    SELECT success INTO validetl FROM trisano.etl_success ORDER BY entrydate LIMIT 1;
    IF NOT validetl THEN
        RAISE EXCEPTION 'Last ETL process was, apparently, not valid. Not swapping schemas. See table trisano.etl_success.';
    END IF;
    SELECT schemaname FROM trisano.current_schema_name LIMIT 1 INTO cur_schema;
    IF cur_schema = 'warehouse_a' THEN
        new_schema = 'warehouse_b';
    ELSE
        new_schema = 'warehouse_a';
    END IF;
    RAISE NOTICE 'Production schema is %; will switch to %', cur_schema, new_schema;

    tmp := 'DROP SCHEMA IF EXISTS ' || new_schema || ' CASCADE';
    EXECUTE tmp;
    tmp := 'ALTER SCHEMA staging RENAME TO ' || new_schema;
    EXECUTE tmp;

    -- Drop views in trisano schema
    FOR viewname IN
      SELECT pg_class.relname
      FROM pg_class JOIN pg_namespace ON (pg_class.relnamespace = pg_namespace.oid)
      WHERE pg_namespace.nspname = 'trisano' AND pg_class.relkind = 'v'
      LOOP
        IF EXISTS
          (SELECT 1 FROM pg_class JOIN pg_namespace
          ON pg_namespace.oid = pg_class.relnamespace
          WHERE pg_class.relname = viewname AND pg_class.relkind = 'v') THEN
            tmp := 'DROP VIEW trisano.' || viewname || ' CASCADE';   -- CASCADE just in case there are dependencies
            EXECUTE tmp;
        END IF;
    END LOOP;

    -- Create a new view for each table in the current schema
    FOR viewname IN 
      SELECT pg_class.relname
      FROM pg_class JOIN pg_namespace ON (pg_class.relnamespace = pg_namespace.oid)
      WHERE pg_namespace.nspname = new_schema AND pg_class.relkind = 'r'
      LOOP
        tmp := 'CREATE VIEW trisano.' || viewname || '_view AS SELECT * FROM ' || new_schema || '.' || viewname;
        EXECUTE tmp;
    END LOOP;

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_patients_view AS
            SELECT p.* FROM ' || new_schema || '.dw_patients p
            JOIN ' || new_schema || '.dw_morbidity_events dce
                ON (dce.dw_patients_id = p.id)';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_patients_view AS
            SELECT p.* FROM ' || new_schema || '.dw_patients p
            JOIN ' || new_schema || '.dw_contact_events dce
                ON (dce.dw_patients_id = p.id)';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_patients_races_view AS
            SELECT pr.* FROM ' || new_schema || '.dw_patients_races pr
            JOIN trisano.dw_morbidity_patients_view dcp
                ON (dcp.id = pr.person_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_patients_races_view AS
            SELECT pr.* FROM ' || new_schema || '.dw_patients_races pr
            JOIN trisano.dw_contact_patients_view dcp
                ON (dcp.id = pr.person_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_reporting_agencies_view AS
            SELECT * FROM ' || new_schema || '.dw_events_reporting_agencies
            WHERE dw_morbidity_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_reporting_agencies_view AS
            SELECT * FROM ' || new_schema || '.dw_events_reporting_agencies
            WHERE dw_contact_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_clinicians_view AS
            SELECT * FROM ' || new_schema || '.dw_events_clinicians
            WHERE dw_morbidity_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_clinicians_view AS
            SELECT * FROM ' || new_schema || '.dw_events_clinicians
            WHERE dw_contact_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_diagnostic_facilities_view AS
            SELECT * FROM ' || new_schema || '.dw_events_diagnostic_facilities
            WHERE dw_morbidity_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_diagnostic_facilities_view AS
            SELECT * FROM ' || new_schema || '.dw_events_diagnostic_facilities
            WHERE dw_contact_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_reporters_view AS
            SELECT * FROM ' || new_schema || '.dw_events_reporters
            WHERE dw_morbidity_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_reporters_view AS
            SELECT * FROM ' || new_schema || '.dw_events_reporters
            WHERE dw_contact_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_treatments_events_view AS
            SELECT * FROM ' || new_schema || '.dw_events_treatments
            WHERE dw_morbidity_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_treatments_events_view AS
            SELECT * FROM ' || new_schema || '.dw_events_treatments
            WHERE dw_contact_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_treatments_view AS
            SELECT t.* FROM ' || new_schema || '.treatments t
            JOIN trisano.dw_events_treatments_view det
                ON (det.treatment_id = t.id AND det.dw_morbidity_events_id IS NOT NULL)';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_treatments_view AS
            SELECT t.* FROM ' || new_schema || '.treatments t
            JOIN trisano.dw_events_treatments_view det
                ON (det.treatment_id = t.id AND det.dw_contact_events_id IS NOT NULL)';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_lab_results_view AS
            SELECT * FROM ' || new_schema || '.dw_lab_results
            WHERE dw_morbidity_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_lab_results_view AS
            SELECT * FROM ' || new_schema || '.dw_lab_results
            WHERE dw_contact_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_encounters_lab_results_view AS
            SELECT l.* FROM ' || new_schema || '.lab_results l
            JOIN trisano.dw_encounters_labs_view del
                ON (del.dw_lab_results_id = l.id)';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_hospitals_view AS
            SELECT * FROM ' || new_schema || '.dw_events_hospitals
            WHERE dw_morbidity_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_hospitals_view AS
            SELECT * FROM ' || new_schema || '.dw_events_hospitals
            WHERE dw_contact_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_secondary_jurisdictions_view AS
            SELECT * FROM ' || new_schema || '.dw_secondary_jurisdictions
            WHERE dw_morbidity_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_secondary_jurisdictions_view AS
            SELECT * FROM ' || new_schema || '.dw_secondary_jurisdictions
            WHERE dw_contact_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_diseases_view AS
            SELECT d.* FROM ' || new_schema || '.diseases d
            JOIN trisano.dw_morbidity_events_view dw
                ON (dw.disease_id = d.id)';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_diseases_view AS
            SELECT d.* FROM ' || new_schema || '.diseases d
            JOIN trisano.dw_contact_events_view dw
                ON (dw.disease_id = d.id)';

    EXECUTE
        'CREATE VIEW trisano.dw_enc_treatments_view AS
            SELECT tr.* FROM ' || new_schema || '.treatments tr
            JOIN trisano.dw_encounters_treatments_view det
                ON (det.dw_events_treatments_id = tr.id)';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_jurisdictions_view AS
            SELECT p.*
            FROM ' || new_schema || '.places p
            INNER JOIN (
                SELECT DISTINCT j.id
                FROM ' || new_schema || '.places j
                LEFT JOIN trisano.dw_morbidity_events_view dme
                    ON (dme.investigating_jurisdiction_id = j.id
                        OR dme.jurisdiction_of_residence_id = j.id)
                LEFT JOIN trisano.dw_secondary_jurisdictions_view dsj
                    ON (dsj.jurisdiction_id = j.id AND dsj.dw_morbidity_events_id IS NOT NULL)
                WHERE dme.investigating_jurisdiction_id IS NOT NULL
                    OR dsj.dw_morbidity_events_id IS NOT NULL
            ) f
                ON (p.id = f.id)';
            
    EXECUTE
        'CREATE VIEW trisano.dw_contact_jurisdictions_view AS
            SELECT p.*
            FROM ' || new_schema || '.places p
            INNER JOIN (
                SELECT DISTINCT j.id
                FROM ' || new_schema || '.places j
                LEFT JOIN trisano.dw_contact_events_view dme
                    ON (dme.investigating_jurisdiction_id = j.id
                        OR dme.jurisdiction_of_residence_id = j.id)
                LEFT JOIN trisano.dw_secondary_jurisdictions_view dsj
                    ON (dsj.jurisdiction_id = j.id AND dsj.dw_contact_events_id IS NOT NULL)
                WHERE dme.investigating_jurisdiction_id IS NOT NULL
                    OR dsj.dw_morbidity_events_id IS NOT NULL
            ) f
                ON (p.id = f.id)';
            
    FOR viewname IN 
      SELECT relname
      FROM pg_class JOIN pg_namespace
      ON (pg_class.relnamespace = pg_namespace.oid)
      WHERE nspname = 'trisano' AND relkind = 'v'
      LOOP
        tmp := 'GRANT SELECT ON trisano.' || viewname || ' TO trisano_ro';
        EXECUTE tmp;
    END LOOP;

    UPDATE trisano.current_schema_name SET schemaname = new_schema;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
