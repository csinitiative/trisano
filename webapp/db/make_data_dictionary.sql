CREATE OR REPLACE FUNCTION get_data_dictionary() RETURNS TEXT STABLE LANGUAGE plpgsql AS $$
DECLARE
    schemas RECORD;
    tables  RECORD;
    columns RECORD;
    tmprec  RECORD;
    result  TEXT;
    heading BOOLEAN;
BEGIN
    -- Note that this ought to use information_schema instead of catalog tables, to prevent
    -- causing problems if the catalogs ever change. But the information_schema doesn't include
    -- object comments.

    -- Get each table
    SELECT INTO result E'h1. TriSano Data Dictionary\nCreated ' || now() || ' in the ' || current_database() || E' database\n\n{toc}\n\n';

    FOR schemas IN
        SELECT n.oid AS schoid, n.nspname AS schemaname, d.description 
        FROM pg_catalog.pg_namespace n
        LEFT JOIN pg_catalog.pg_description d 
            ON (d.objsubid = 0 AND n.oid = d.objoid AND d.classoid = 'pg_catalog.pg_namespace'::regclass)
        WHERE (d.description IS NULL or lower(d.description) !~ 'data dictionary ignore')
        AND n.nspname NOT LIKE 'pg_%' AND n.nspname != 'information_schema'
        ORDER BY schemaname
    LOOP
        -- RAISE NOTICE 'schema %', schemas.schemaname;
        FOR tables IN
            SELECT t.oid AS tableoid, t.relname AS tablename, d.description
            FROM pg_catalog.pg_class t
            LEFT JOIN pg_catalog.pg_description d
                ON (d.objoid = t.oid)
            WHERE (d.classoid = 'pg_catalog.pg_class'::regclass OR d.classoid IS NULL)
                AND t.relkind IN ('r', 'v') AND (d.objsubid = 0 OR d.objsubid IS NULL)
                AND t.relnamespace = schemas.schoid
                AND t.relname NOT LIKE 'formbuilder_%'
                AND (d.description IS NULL OR d.description !~ 'data dictionary ignore')
            ORDER BY tablename
        LOOP
            -- RAISE NOTICE 'table %.%', schemas.schemaname, tables.tablename;
            result := result || 'h2. ' || schemas.schemaname || '.' || tables.tablename || E'\n' || COALESCE(tables.description || E'\n\n', E'\n');
            result := result || E'||column||type||details||description||\n';

            -- Get columns for this table
            FOR columns IN
                SELECT a.attname AS colname,
                    pg_catalog.array_to_string(
                    ARRAY[
                        CASE WHEN a.attnotnull THEN 'NOT NULL' ELSE '' END,
                        COALESCE('DEFAULT ' || SUBSTRING(pg_catalog.pg_get_expr(f.adbin, f.adrelid) for 128), ' ')
                    ], ' ') AS details,
                    pg_catalog.format_type(a.atttypid, a.atttypmod) AS type,
                    COALESCE(d.description, ' ') AS desc,
                    d.objoid
                FROM pg_catalog.pg_attribute a
                LEFT JOIN pg_catalog.pg_description d
                    ON (d.objsubid = a.attnum AND d.objoid = a.attrelid)
                LEFT JOIN pg_catalog.pg_attrdef f
                    ON (f.adrelid = tables.tableoid AND f.adnum = a.attnum AND a.atthasdef)
                WHERE a.attnum > 0 AND a.attrelid = tables.tableoid
                    AND (d.classoid = 'pg_catalog.pg_class'::regclass OR d.classoid IS NULL)
            LOOP
                 -- RAISE NOTICE 'column %.%.%', schemas.schemaname, tables.tablename, columns.colname;
                result := result || '|' || columns.colname || '|' || columns.type || '|' || columns.details || '|' || columns.desc || E'|\n';
            END LOOP; -- COLUMNS

            result := result || E'\n';

            heading := false;
            -- Constraints
            FOR tmprec IN SELECT pg_catalog.pg_get_constraintdef(oid, true) AS condef                                  
                FROM pg_catalog.pg_constraint WHERE conrelid = tables.tableoid
                ORDER BY pg_catalog.pg_get_constraintdef(oid, true) !~ 'PRIMARY KEY', 1
            LOOP
                IF NOT heading THEN
                    heading := true;
                    result := result || E'||Constraints||\n';
                END IF;
                result := result || '|' || tmprec.condef || E'|\n';
            END LOOP; -- CONSTRAINTS

            result := result || E'\n';

        END LOOP; -- TABLES
    END LOOP; -- SCHEMAS

    RETURN result;
END;
$$;

SELECT get_data_dictionary();

ROLLBACK;
