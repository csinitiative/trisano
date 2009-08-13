CREATE OR REPLACE FUNCTION get_data_dictionary() RETURNS TEXT STABLE LANGUAGE plpgsql AS $$
DECLARE
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
    FOR tables IN
        SELECT t.oid AS tableoid, n.nspname AS schemaname, t.relname AS tablename, d.description
        FROM pg_catalog.pg_namespace n
        JOIN pg_catalog.pg_class t
            ON (n.nspname NOT LIKE 'pg_%' AND n.nspname != 'information_schema' AND n.oid = t.relnamespace)
        JOIN pg_catalog.pg_description d
            ON (d.classoid = 'pg_catalog.pg_class'::regclass AND d.objoid = t.oid)
        WHERE relkind = 'r' AND d.objsubid = 0 ORDER BY schemaname, tablename
    LOOP
        result := result || 'h2. ' || tables.schemaname || '.' || tables.tablename || E'\n' || tables.description || E'\n\n';
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
                COALESCE(d.description, ' ') AS desc
            FROM pg_catalog.pg_attribute a
            LEFT JOIN pg_catalog.pg_description d
                ON (d.objoid = a.attrelid AND d.classoid = 'pg_catalog.pg_class'::regclass AND d.objsubid = a.attnum)
            LEFT JOIN pg_catalog.pg_attrdef f
                ON (f.adrelid = tables.tableoid AND f.adnum = a.attnum AND a.atthasdef)
            WHERE a.attnum > 0 AND a.attrelid = tables.tableoid
        LOOP
            result := result || '|' || columns.colname || '|' || columns.type || '|' || columns.details || '|' || columns.desc || E'|\n';
        END LOOP;

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
        END LOOP;

        result := result || E'\n';

    END LOOP;

    RETURN result;
END;
$$;

SELECT get_data_dictionary();

ROLLBACK;


-- "Constraints":
-- NOT NULL
-- UNIQUE
-- default values
-- foreign keys
