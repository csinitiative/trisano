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
ALTER SCHEMA trisano OWNER TO nedss;
CREATE LANGUAGE plpgsql;
-- NOTE: Adjust this user to the DEST_DB_USER 
ALTER SCHEMA public OWNER TO nedss;
GRANT USAGE ON SCHEMA trisano TO nedss_dw;

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
        tmp := 'DROP VIEW trisano.' || viewname;
        EXECUTE tmp;
    END LOOP;

    -- Create a new view for each table in the current schema
    FOR viewname IN 
      SELECT pg_class.relname
      FROM pg_class JOIN pg_namespace ON (pg_class.relnamespace = pg_namespace.oid)
      WHERE pg_namespace.nspname = new_schema AND pg_class.relkind = 'r'
      LOOP
        tmp := 'CREATE VIEW trisano.' || viewname || '_view AS SELECT * FROM ' || new_schema || '.' || viewname;
        EXECUTE tmp;
        tmp := 'GRANT SELECT ON trisano.' || viewname || '_view TO nedss_dw';
        EXECUTE tmp;
    END LOOP;

    UPDATE trisano.current_schema_name SET schemaname = new_schema;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
