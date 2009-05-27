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

CREATE OR REPLACE FUNCTION trisano.build_form_tables() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    form_name             TEXT;
    question_name         TEXT;
    questions_per_table   INTEGER := 200;
    i                     INTEGER;
    table_count           INTEGER;
    cols_plus_vals_clause TEXT := '';
    colnames_clause       TEXT := '';
    insert_col_clause     TEXT := '';
    answer_rec            RECORD;
    last_event            INTEGER;
    values_clause         TEXT;
    tmp                   TEXT;
    table_name            TEXT;
BEGIN
    FOR form_name IN
                SELECT DISTINCT short_name
                FROM forms 
                WHERE short_name IS NOT NULL AND short_name != ''
                ORDER BY short_name LOOP
        -- For each form, find all the question short names that appear on it
        RAISE NOTICE 'Processing form name %', form_name;
        i := 0;
        colnames_clause := '';
        cols_plus_vals_clause := '';
        table_count := 1;
        FOR question_name IN SELECT DISTINCT lower(q.short_name)
                    FROM questions q JOIN form_elements fe ON fe.id = q.form_element_id
                    JOIN forms f ON f.id = fe.form_id JOIN answers a ON a.question_id = q.id
                    WHERE f.short_name = form_name
                    AND q.short_name IS NOT NULL
                    AND q.short_name != ''
                    AND a.text_answer IS NOT NULL
                    ORDER BY 1
                    LOOP
            RAISE NOTICE ' ** Processing question % in current form', question_name;
            -- Get some number of question short names
            IF colnames_clause != '' THEN
                colnames_clause := colnames_clause || ', ';
                cols_plus_vals_clause := cols_plus_vals_clause || ', ';
            END IF;
            colnames_clause := colnames_clause || quote_literal(question_name);
            cols_plus_vals_clause := cols_plus_vals_clause || quote_ident(question_name) || ' TEXT';
            i := i + 1;

            IF i > questions_per_table THEN
                PERFORM trisano.create_single_form_table(form_name, table_count, colnames_clause, cols_plus_vals_clause);
                table_count := table_count + 1;
                colnames_clause := '';
                cols_plus_vals_clause := '';
                i := 0;
            END IF;
        END LOOP;
        IF colnames_clause != '' THEN
            PERFORM trisano.create_single_form_table(form_name, table_count, colnames_clause, cols_plus_vals_clause);
        END IF;
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION trisano.create_single_form_table(form_name text, table_count integer, colnames_clause text, cols_plus_vals_clause text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    insert_col_clause TEXT;
    values_clause     TEXT;
    last_event        INTEGER;
    last_type         TEXT;
    tmp               TEXT;
    answer_rec        RECORD;
    table_name        TEXT;
BEGIN
    table_name := quote_ident('formtable_' || lower(form_name) || '_' || table_count);
    insert_col_clause := '';
    values_clause := '';
    last_event := NULL;
    EXECUTE 'DROP TABLE IF EXISTS ' || table_name;
    RAISE NOTICE 'Creating table %', table_name;
    EXECUTE 'CREATE TABLE ' || table_name || ' (event_id INTEGER, type TEXT, ' || cols_plus_vals_clause || ')';
    -- Note that there's no ordering with this DISTINCT ON. There's nothing in
    -- the tables now to prevent multiple questions with the same short name
    -- being answered for the same event, so we've got to prevent it here
    tmp := 'SELECT DISTINCT ON (a.event_id, e.type, q.short_name) a.event_id, e.type, q.short_name, a.text_answer
            FROM answers a JOIN questions q ON (q.id = a.question_id)
            JOIN form_elements fe ON (fe.id = q.form_element_id)
            JOIN forms f ON (fe.form_id = f.id)
            JOIN events e ON (a.event_id = e.id)
            WHERE f.short_name = ' || quote_literal(form_name) || '
            AND lower(q.short_name) IN (' || colnames_clause || ')
            AND text_answer IS NOT NULL
            ORDER BY event_id';
    FOR answer_rec IN EXECUTE tmp LOOP
        IF last_event IS NOT NULL AND last_event != answer_rec.event_id THEN
            tmp := 'INSERT INTO ' || table_name || ' (event_id, type, ' || lower(insert_col_clause) || ') VALUES (' || last_event || ', ''' || last_type || ''', ' || values_clause || ')';
            RAISE NOTICE 'Running %', tmp;
            EXECUTE tmp;
            insert_col_clause := '';
            values_clause := '';
        END IF;
        last_event := answer_rec.event_id;
        last_type  := answer_rec.type;

        IF insert_col_clause != '' THEN
            insert_col_clause := insert_col_clause || ', ';
            values_clause := values_clause || ', ';
        END IF;
        insert_col_clause := insert_col_clause || quote_ident(answer_rec.short_name);
        values_clause := values_clause || quote_literal(answer_rec.text_answer);
    END LOOP;
    IF last_event IS NOT NULL THEN
        tmp := 'INSERT INTO ' || table_name || ' (event_id, type, ' || lower(insert_col_clause) || ') VALUES (' || last_event || ', ''' || last_type || ''', ' || values_clause || ')';
        RAISE NOTICE 'Running %', tmp;
        EXECUTE tmp;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION trisano.swap_schemas() RETURNS BOOLEAN AS $$
DECLARE
    cur_schema TEXT;
    new_schema TEXT;
    tmp TEXT;
    viewname TEXT;
    validetl BOOLEAN;
    orig_search_path TEXT;
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

    -- Create form builder tables
    SELECT INTO orig_search_path setting FROM pg_settings WHERE name = 'search_path';
    EXECUTE 'SET search_path = ' || new_schema;
    PERFORM trisano.build_form_tables();
    EXECUTE 'SET search_path = ' || orig_search_path;

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
            -- CASCADE just in case there are dependencies
            tmp := 'DROP VIEW trisano.' || viewname || ' CASCADE';   
            EXECUTE tmp;
        END IF;
    END LOOP;

    -- Create a new view for each table in the current schema
    FOR viewname IN 
      SELECT pg_class.relname
      FROM pg_class JOIN pg_namespace ON (pg_class.relnamespace = pg_namespace.oid)
      WHERE pg_namespace.nspname = new_schema AND pg_class.relkind = 'r' AND relname NOT LIKE 'formtable_%'
      LOOP
        tmp := 'CREATE VIEW trisano.' || viewname || '_view AS SELECT * FROM ' || new_schema || '.' || viewname;
        EXECUTE tmp;
    END LOOP;

    -- Create event-type-specific views for each formtable* table
    FOR viewname IN
      SELECT pg_class.relname
      FROM pg_class JOIN pg_namespace ON (pg_class.relnamespace = pg_namespace.oid)
      WHERE pg_namespace.nspname = new_schema AND pg_class.relkind = 'r' AND relname LIKE 'formtable_%'
      LOOP
        tmp := 'CREATE VIEW trisano.' || viewname || '_morbidity_view AS SELECT * FROM ' || new_schema || '.' || viewname || ' WHERE type = ''MorbidityEvent''';
        EXECUTE tmp;
        tmp := 'CREATE VIEW trisano.' || viewname || '_place_view AS SELECT * FROM ' || new_schema || '.' || viewname || ' WHERE type = ''PlaceEvent''';
        EXECUTE tmp;
        tmp := 'CREATE VIEW trisano.' || viewname || '_contact_view AS SELECT * FROM ' || new_schema || '.' || viewname || ' WHERE type = ''ContactEvent''';
        EXECUTE tmp;
        tmp := 'CREATE VIEW trisano.' || viewname || '_encounter_view AS SELECT * FROM ' || new_schema || '.' || viewname || ' WHERE type = ''EncounterEvent''';
        EXECUTE tmp;
    END LOOP;

    -- Create a whole bunch of event-type-specific views. This helps Pentaho
    -- not have cycles in its graph of the schema
    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_patients_races_view AS
            SELECT pr.* FROM ' || new_schema || '.dw_patients_races pr
            JOIN ' || new_schema || '.dw_morbidity_patients p
                ON (p.id = pr.person_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_patients_races_view AS
            SELECT pr.* FROM ' || new_schema || '.dw_patients_races pr
            JOIN ' || new_schema || '.dw_contact_patients p
                ON (p.id = pr.person_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_reporting_agencies_view AS
            SELECT * FROM ' || new_schema || '.dw_events_reporting_agencies
            WHERE dw_morbidity_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_reporting_agencies_view AS
            SELECT * FROM ' || new_schema || '.dw_events_reporting_agencies
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
