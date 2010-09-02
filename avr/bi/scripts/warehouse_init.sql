-- Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

BEGIN;
CREATE SCHEMA trisano;
ALTER SCHEMA trisano OWNER TO trisano_su;
COMMIT;

BEGIN;
CREATE SCHEMA population;
ALTER SCHEMA population OWNER TO trisano_su;
COMMIT;

BEGIN;
CREATE LANGUAGE plpgsql;
COMMIT;

BEGIN;
-- Running this bit on an already initialized database will result in errors.
-- Those errors can safely be ignored.
SET search_path = trisano;

CREATE TYPE hstore;

CREATE OR REPLACE FUNCTION hstore_in(cstring)
RETURNS hstore
AS '$libdir/hstore'
LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION hstore_out(hstore)
RETURNS cstring
AS '$libdir/hstore'
LANGUAGE C STRICT;

CREATE TYPE hstore (
        INTERNALLENGTH = -1,
        INPUT = hstore_in,
        OUTPUT = hstore_out,
        STORAGE = extended
);

CREATE OR REPLACE FUNCTION fetchval(hstore,text)
RETURNS text
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR -> (
	LEFTARG = hstore,
	RIGHTARG = text,
	PROCEDURE = fetchval
);

CREATE OR REPLACE FUNCTION isexists(hstore,text)
RETURNS bool
AS '$libdir/hstore','exists'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION exist(hstore,text)
RETURNS bool
AS '$libdir/hstore','exists'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR ? (
	LEFTARG = hstore,
	RIGHTARG = text,
	PROCEDURE = exist,
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OR REPLACE FUNCTION isdefined(hstore,text)
RETURNS bool
AS '$libdir/hstore','defined'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION defined(hstore,text)
RETURNS bool
AS '$libdir/hstore','defined'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION delete(hstore,text)
RETURNS hstore
AS '$libdir/hstore','delete'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION hs_concat(hstore,hstore)
RETURNS hstore
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR || (
	LEFTARG = hstore,
	RIGHTARG = hstore,
	PROCEDURE = hs_concat
);

CREATE OR REPLACE FUNCTION hs_contains(hstore,hstore)
RETURNS bool
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION hs_contained(hstore,hstore)
RETURNS bool
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OPERATOR @> (
	LEFTARG = hstore,
	RIGHTARG = hstore,
	PROCEDURE = hs_contains,
	COMMUTATOR = '<@',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR <@ (
	LEFTARG = hstore,
	RIGHTARG = hstore,
	PROCEDURE = hs_contained,
	COMMUTATOR = '@>',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

-- obsolete:
CREATE OPERATOR @ (
	LEFTARG = hstore,
	RIGHTARG = hstore,
	PROCEDURE = hs_contains,
	COMMUTATOR = '~',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OPERATOR ~ (
	LEFTARG = hstore,
	RIGHTARG = hstore,
	PROCEDURE = hs_contained,
	COMMUTATOR = '@',
	RESTRICT = contsel,
	JOIN = contjoinsel
);

CREATE OR REPLACE FUNCTION tconvert(text,text)
RETURNS hstore
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE;

CREATE OPERATOR => (
	LEFTARG = text,
	RIGHTARG = text,
	PROCEDURE = tconvert
);

CREATE OR REPLACE FUNCTION akeys(hstore)
RETURNS _text
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION avals(hstore)
RETURNS _text
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION skeys(hstore)
RETURNS setof text
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION svals(hstore)
RETURNS setof text
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION each(IN hs hstore,
    OUT key text,
    OUT value text)
RETURNS SETOF record
AS '$libdir/hstore'
LANGUAGE C STRICT IMMUTABLE;



-- define the GiST support methods

CREATE TYPE ghstore;

CREATE OR REPLACE FUNCTION ghstore_in(cstring)
RETURNS ghstore
AS '$libdir/hstore'
LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION ghstore_out(ghstore)
RETURNS cstring
AS '$libdir/hstore'
LANGUAGE C STRICT;

CREATE TYPE ghstore (
        INTERNALLENGTH = -1,
        INPUT = ghstore_in,
        OUTPUT = ghstore_out
);

CREATE OR REPLACE FUNCTION ghstore_compress(internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION ghstore_decompress(internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION ghstore_penalty(internal,internal,internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION ghstore_picksplit(internal, internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION ghstore_union(internal, internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION ghstore_same(internal, internal, internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION ghstore_consistent(internal,internal,int4)
RETURNS bool
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE;

-- register the opclass for indexing (not as default)
CREATE OPERATOR CLASS gist_hstore_ops
DEFAULT FOR TYPE hstore USING gist
AS
       	OPERATOR        7       @>       RECHECK,
       	OPERATOR        9       ?(hstore,text)       RECHECK,
        --OPERATOR        8       <@       RECHECK,
        OPERATOR        13      @       RECHECK,
        --OPERATOR        14      ~       RECHECK,
        FUNCTION        1       ghstore_consistent (internal, internal, int4),
        FUNCTION        2       ghstore_union (internal, internal),
        FUNCTION        3       ghstore_compress (internal),
        FUNCTION        4       ghstore_decompress (internal),
        FUNCTION        5       ghstore_penalty (internal, internal, internal),
        FUNCTION        6       ghstore_picksplit (internal, internal),
        FUNCTION        7       ghstore_same (internal, internal, internal),
        STORAGE         ghstore;

-- define the GIN support methods

CREATE OR REPLACE FUNCTION gin_extract_hstore(internal, internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION gin_extract_hstore_query(internal, internal, int2)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION gin_consistent_hstore(internal, int2, internal)
RETURNS internal
AS '$libdir/hstore'
LANGUAGE C IMMUTABLE;

CREATE OPERATOR CLASS gin_hstore_ops
DEFAULT FOR TYPE hstore USING gin
AS
	OPERATOR        7       @> RECHECK,
	OPERATOR        9       ?(hstore,text),
	FUNCTION        1       bttextcmp(text,text),
	FUNCTION        2       gin_extract_hstore(internal, internal),
	FUNCTION        3       gin_extract_hstore_query(internal, internal, int2),
	FUNCTION        4       gin_consistent_hstore(internal, int2, internal),
STORAGE         text;
COMMIT;

BEGIN;

-- Pentaho's reporting tool doesn't work well with non-text user-specified
-- parameters. This function converts text input to a date, trapping the
-- exception and using a fallback alternate date when the text can't be
-- converted to a date
CREATE FUNCTION make_date(input_date text, alternate date) RETURNS date
    AS $$
DECLARE
    converted_date DATE;
BEGIN
    BEGIN
        converted_date := input_date::DATE;
    EXCEPTION
        WHEN data_exception THEN 
            converted_date := alternate;
            RAISE NOTICE 'Invalid input syntax for date type: %', input_date;
    END;
    RETURN converted_date;
END;
$$
    LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION trisano.hstoreagg(trisano.hstore, text, text) RETURNS trisano.hstore AS $$
    SELECT trisano.hs_concat($1, trisano.tconvert($2, $3));
$$ LANGUAGE SQL;

CREATE AGGREGATE trisano.hstoreagg(TEXT, TEXT) (SFUNC = trisano.hstoreagg, STYPE = trisano.hstore, INITCOND = '');
COMMIT;

BEGIN;
-- NOTE: Adjust this user to the DEST_DB_USER
ALTER SCHEMA public OWNER TO trisano_su;
GRANT USAGE ON SCHEMA trisano TO trisano_ro;
GRANT USAGE ON SCHEMA population TO trisano_ro;
ALTER USER trisano_ro SET search_path = trisano;

DROP TABLE IF EXISTS trisano.current_schema_name;

CREATE TABLE trisano.current_schema_name (
    schemaname TEXT NOT NULL
);
TRUNCATE TABLE trisano.current_schema_name;
INSERT INTO trisano.current_schema_name VALUES ('warehouse_a');

CREATE OR REPLACE FUNCTION trisano.get_age_group(INTEGER) RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$
SELECT
    CASE
--      WHEN $1 < 1 THEN '< 1 year'
--      WHEN ($1 >= 1 AND $1 < 5) THEN '1-4 years'
        WHEN $1 >= 85 THEN '85+ years'
        WHEN $1 IS NULL THEN 'Unknown'
        ELSE ((floor($1 / 5) * 5)::integer)::text || '-' || ((floor($1 / 5) * 5)::integer + 4)::text || ' years'
    END
$$;

CREATE OR REPLACE FUNCTION trisano.get_age_group(NUMERIC) RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$
    SELECT trisano.get_age_group($1::INTEGER);
$$;

CREATE OR REPLACE FUNCTION trisano.get_age_group_ordinal(INTEGER) RETURNS INTEGER
    LANGUAGE SQL IMMUTABLE AS
$$
SELECT
    CASE
        WHEN $1 >= 85 THEN 85
        ELSE (floor($1 / 5) * 5)::integer
    END
$$;

CREATE OR REPLACE FUNCTION trisano.get_age_group_ordinal(NUMERIC) RETURNS INTEGER
    LANGUAGE SQL IMMUTABLE AS
$$
    SELECT trisano.get_age_group_ordinal($1::INTEGER);
$$;

DROP TABLE IF EXISTS trisano.etl_success;

CREATE TABLE trisano.etl_success (
    success BOOLEAN,
    entrydate TIMESTAMPTZ DEFAULT NOW()
);
INSERT INTO trisano.etl_success (success) VALUES (FALSE);

DROP TABLE IF EXISTS trisano.formbuilder_columns;
DROP TABLE IF EXISTS trisano.formbuilder_tables;

CREATE TABLE trisano.formbuilder_tables (
    id SERIAL PRIMARY KEY,
    short_name TEXT,
    table_name TEXT,
    modified BOOLEAN DEFAULT TRUE
);
CREATE INDEX formbuilder_form_name
    ON trisano.formbuilder_tables (short_name);
CREATE UNIQUE INDEX formbuilder_table_name
    ON trisano.formbuilder_tables (table_name);
CREATE INDEX formbuilder_tables_modified
    ON trisano.formbuilder_tables (modified);

CREATE TABLE trisano.formbuilder_columns (
    formbuilder_table_name TEXT REFERENCES trisano.formbuilder_tables(table_name)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    column_name TEXT,
    orig_column_name TEXT
);
CREATE UNIQUE INDEX formbuilder_columns_ix
    ON trisano.formbuilder_columns (formbuilder_table_name, column_name);
CREATE INDEX formbuilder_column_orig_name
    ON trisano.formbuilder_columns (orig_column_name);

CREATE OR REPLACE FUNCTION trisano.shorten_identifier(TEXT) RETURNS TEXT AS $$
    SELECT
        CASE
            WHEN char_length($1) < 64 THEN $1
            ELSE substring($1 FROM 1 FOR 1) || regexp_replace(substring($1 from 2), '[AEIOUaeiou]', '', 'g')
        END;
$$ LANGUAGE sql IMMUTABLE;

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

-- The types and associated functions below deserve some explanation. Mondrian,
-- Pentaho's OLAP engine, reports what in the OLAP world are called "measures" by
-- aggregating numbers found in the database.  Available aggregates include count,
-- sum, min, max, avg, and distinct-count, whose functions are fairly readily
-- apparent. Unfortunately, this is the full set of supported aggregates.
-- PostgreSQL supports a much wider array of aggregates (indeed, it allows users
-- to write their own where a suitable one isn't provided), but these are
-- unavailable to Mondrian without some sleight of hand, which is where these
-- functions and data type come in.
--
-- A Mondrian measure is defined as a column name or SQL expression and its
-- associated aggregate. For instance, a measure might show the average price for
-- an item, and be defined with the column "price" and the "avg" aggregate. A more
-- complex measure might involve the SQL expression "get_stock_on_hand(foo, bar)"
-- and the "min" aggregate. Mondrian translates these into SQL statements in the
-- obvious way: by wrapping the column name or SQL expression in the correct
-- aggregate function, e.g. avg(price) or min(get_stock_on_hand(foo, bar)).
--
-- For TriSano, we'd like to report, for instance, the standard deviation of
-- various measures. We could do this with the PostreSQL functions stddev_samp or
-- stddev_pop, which are aggregates, but it doesn't make sense to wrap the value
-- returned by stddev with any of the available Mondrian aggregates. PostgreSQL
-- yells when presented with nested aggregates, and rightly so, so the trick is to
-- get PostgreSQL to use some version of, say, the count() function, that differs
-- from the aggregate version. The replacement function is below, and it's
-- essentially a no-op, returning the argument it's passed. The only remaining
-- wrinkle is that we *don't* want PostgreSQL to use our subverted count()
-- function anytime *except* in these cases when we're trying to get Mondrian to
-- use some unusual aggregate. To achieve that end, we've created a custom type,
-- which will only be used by Mondrian, called dp_cust, derived from "custom
-- double precision", since stddev() returns DOUBLE PRECISION. We've also
-- defined int_cust and num_cust to handle integers and numerics in the same
-- way. Other types may have to follow. Now the only way our count() functions
-- will be called is if the argument happens to be of one of our custom types.
-- Note that we don't define a cast from our custom types to their more common
-- base types, but instead define functions to convert from one to the other. This
-- prevents PostgreSQL from switching types on us automatically, when we don't
-- want it.
--
-- Given this infrastructure, all PostgreSQL aggregates are now available to us
-- as Mondrian aggregates. For instance, to get the standard deviation of patient
-- ages, we create a measure defined with the expression
-- make_dpcust(stddev(age_in_years)) with the count aggregate. In SQL, this
-- becomes "SELECT count(make_dpcust(stddev(age_in_years)))" with stddev()
-- being the PostgreSQL aggregate, and the count() and make_dpcust() functions
-- simply transformations on the stddev() output. Note that database user
-- Mondrian uses must have the trisano schema in the search path, as these types
-- and functions are not being inserted into the pg_catalog schema.
--
-- Yes, it's a hack. But it prevents us from having to write patches for Mondrian.

DROP TYPE IF EXISTS trisano.dp_cust CASCADE;

CREATE TYPE trisano.dp_cust AS (
    dp DOUBLE PRECISION);

CREATE OR REPLACE FUNCTION trisano.make_dpcust(a DOUBLE PRECISION) RETURNS trisano.dp_cust IMMUTABLE AS $$
DECLARE
    dpc trisano.dp_cust;
BEGIN
    dpc.dp := a;
    RETURN dpc;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trisano.count(trisano.dp_cust) RETURNS DOUBLE PRECISION IMMUTABLE AS $$
    SELECT $1.dp
$$ LANGUAGE sql;

DROP TYPE IF EXISTS trisano.int_cust CASCADE;

CREATE TYPE trisano.int_cust AS (
    myint INTEGER);

CREATE OR REPLACE FUNCTION trisano.make_intcust(a INTEGER) RETURNS trisano.int_cust IMMUTABLE AS $$
DECLARE
    myi trisano.int_cust;
BEGIN
    myi.myint := a;
    RETURN myi;
END;

$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trisano.count(trisano.int_cust) RETURNS INTEGER IMMUTABLE AS $$
    SELECT $1.myint
$$ LANGUAGE sql;

DROP TYPE IF EXISTS trisano.num_cust CASCADE;

CREATE TYPE trisano.num_cust AS (
    mynum NUMERIC);

CREATE OR REPLACE FUNCTION trisano.make_numcust(a NUMERIC) RETURNS trisano.num_cust IMMUTABLE AS $$
DECLARE
    myi trisano.num_cust;
BEGIN
    myi.mynum := a;
    RETURN myi;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trisano.count(trisano.num_cust) RETURNS NUMERIC IMMUTABLE AS $$
    SELECT $1.mynum
$$ LANGUAGE sql;

-- End of Mondrian aggregate trickery

-- Beginning of median and mode aggregate definitions

CREATE OR REPLACE FUNCTION trisano.addlang(lang TEXT) RETURNS BOOLEAN VOLATILE LANGUAGE plpgsql AS
$addlang$
BEGIN
    PERFORM * FROM pg_language WHERE lanname = lang;
    IF NOT FOUND THEN
        EXECUTE 'CREATE LANGUAGE ' || lang;
    END IF;
    PERFORM * FROM pg_language WHERE lanname = lang;
    RETURN FOUND;
END;
$addlang$;

SELECT trisano.addlang('plperl');
SELECT trisano.addlang('plperlu');

CREATE OR REPLACE FUNCTION trisano.format_date(inputval TEXT) RETURNS TIMESTAMP AS $$
  use Date::Parse;
  use Date::Format;

  my $a = str2time($_[0]);
  return defined($a) ? ctime($a) : undef;
$$ LANGUAGE plperlu STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION trisano.array_median(i double precision[]) RETURNS double precision
    LANGUAGE plperl IMMUTABLE
    AS $_X$

my $arg = $_[0];
$arg =~ s/[{}]//g;
my @array = sort { $a <=> $b }   # Step 3: Sort result
            map { $_ * 1.0 }     # Step 2: Convert values from string to int
            split /,/, $arg;     # Step 1: Split stringified array into list
return $array[int($#array / 2)];

$_X$;

CREATE OR REPLACE FUNCTION trisano.array_median(i numeric[]) RETURNS numeric
    LANGUAGE plperl IMMUTABLE
    AS $_X$

my $arg = $_[0];
$arg =~ s/[{}]//g;
my @array = sort { $a <=> $b }   # Step 3: Sort result
            map { $_ * 1.0 }     # Step 2: Convert values from string to int
            split /,/, $arg;     # Step 1: Split stringified array into list
return $array[int($#array / 2)];
$_X$;

CREATE OR REPLACE FUNCTION trisano.array_median(i integer[]) RETURNS integer
    LANGUAGE plperl IMMUTABLE
    AS $_X$

my $arg = $_[0];
$arg =~ s/[{}]//g;
my @array = sort { $a <=> $b }   # Step 3: Sort result
            map { $_ * 1 }       # Step 2: Convert values from string to int
            split /,/, $arg;     # Step 1: Split stringified array into list
return $array[int($#array / 2)];

$_X$;

DROP AGGREGATE IF EXISTS trisano.median(double precision);

CREATE AGGREGATE trisano.median(double precision) (
    SFUNC = array_append,
    STYPE = double precision[],
    FINALFUNC = trisano.array_median
);

DROP AGGREGATE IF EXISTS trisano.median(numeric);

CREATE AGGREGATE trisano.median(numeric) (
    SFUNC = array_append,
    STYPE = numeric[],
    FINALFUNC = trisano.array_median
);

DROP AGGREGATE IF EXISTS trisano.median(integer);

CREATE AGGREGATE trisano.median(integer) (
    SFUNC = array_append,
    STYPE = integer[],
    FINALFUNC = trisano.array_median
);

CREATE OR REPLACE FUNCTION trisano.array_mode(i double precision[]) RETURNS double precision
    LANGUAGE plperl IMMUTABLE
    AS $_X$

my $arg = $_[0];
$arg =~ s/[{}]//g;

my ($mode, $modecount, $curcount, $curval);
$curcount = 0;

map {                # Step 4: Find the most common entry
    my $i = $_;
    $curval = $i if !defined $curval;
    if ($i == $curval) {
        $curcount++;
    }
    else {
        if (!defined $mode || $curcount > $modecount) {
            $mode = $curval;
            $modecount = $curcount;
        }
        $curval = $i;
        $curcount = 1;
    }
}
sort { $a <=> $b }   # Step 3: Sort list
map { $_ * 1.0 }     # Step 2: Turn it into a number
split /,/, $arg;     # Step 1: Split stringified array into list

return $mode;

$_X$;

CREATE OR REPLACE FUNCTION trisano.array_mode(i numeric[]) RETURNS numeric
    LANGUAGE plperl IMMUTABLE
    AS $_X$

my $arg = $_[0];
$arg =~ s/[{}]//g;

my ($mode, $modecount, $curcount, $curval);
$curcount = 0;

map {                # Step 4: Find the most common entry
    my $i = $_;
    $curval = $i if !defined $curval;
    if ($i == $curval) {
        $curcount++;
    }
    else {
        if (!defined $mode || $curcount > $modecount) {
            $mode = $curval;
            $modecount = $curcount;
        }
        $curval = $i;
        $curcount = 1;
    }
}
sort { $a <=> $b }   # Step 3: Sort list
map { $_ * 1.0 }     # Step 2: Turn it into a number
split /,/, $arg;     # Step 1: Split stringified array into list

return $mode;

$_X$;

CREATE OR REPLACE FUNCTION trisano.array_mode(i integer[]) RETURNS integer
    LANGUAGE plperl IMMUTABLE
    AS $_X$

my $arg = $_[0];
$arg =~ s/[{}]//g;

my ($mode, $modecount, $curcount, $curval);
$curcount = 0;

map {                # Step 4: Find the most common entry
    my $i = $_;
    $curval = $i if !defined $curval;
    if ($i == $curval) {
        $curcount++;
    }
    else {
        if (!defined $mode || $curcount > $modecount) {
            $mode = $curval;
            $modecount = $curcount;
        }
        $curval = $i;
        $curcount = 1;
    }
}
sort { $a <=> $b }   # Step 3: Sort list
map { $_ * 1.0 }     # Step 2: Turn it into a number
split /,/, $arg;     # Step 1: Split stringified array into list

return $mode;

$_X$;

DROP AGGREGATE IF EXISTS trisano.mode(double precision);

CREATE AGGREGATE trisano.mode(double precision) (
    SFUNC = array_append,
    STYPE = double precision[],
    FINALFUNC = trisano.array_mode
);

DROP AGGREGATE IF EXISTS trisano.mode(numeric);

CREATE AGGREGATE trisano.mode(numeric) (
    SFUNC = array_append,
    STYPE = numeric[],
    FINALFUNC = trisano.array_mode
);

DROP AGGREGATE IF EXISTS trisano.mode(integer);

CREATE AGGREGATE trisano.mode(integer) (
    SFUNC = array_append,
    STYPE = integer[],
    FINALFUNC = trisano.array_mode
);

-- END of median and mode aggregate definitions

CREATE OR REPLACE FUNCTION
    trisano.text_join(accum TEXT, newvalue TEXT, separator TEXT)
    RETURNS text AS
$$
DECLARE
    result TEXT DEFAULT '';
BEGIN
    IF accum IS NOT NULL AND accum != '' THEN
       result := accum || separator || newvalue;
    ELSE
       result := accum || newvalue;
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

DROP AGGREGATE IF EXISTS trisano.text_join_agg(text, text);

CREATE AGGREGATE trisano.text_join_agg (text, text) (
    sfunc = trisano.text_join,
    stype = text,
    initcond =''
);

CREATE OR REPLACE FUNCTION trisano.get_age_in_years(integer, text)
    RETURNS numeric
    LANGUAGE sql
    IMMUTABLE STRICT
AS $function$
    SELECT
        CASE
            WHEN floor(age) = age THEN floor(age)
            ELSE age
        END
    FROM
        (SELECT
            CASE
                WHEN $2 IS NULL OR $1 IS NULL OR $2 = 'unknown' THEN NULL
                WHEN $2 = 'years'  THEN $1
                WHEN $2 = 'months' THEN ROUND($1::NUMERIC / 12.0 , 1)
                WHEN $2 = 'weeks'  THEN ROUND($1::NUMERIC / 52.0 , 2)
                WHEN $2 = 'days'   THEN ROUND($1::NUMERIC / 365.0, 2)
            END AS age) f
$function$ ;

DROP AGGREGATE IF EXISTS trisano.array_accum(anyelement) CASCADE;

CREATE AGGREGATE trisano.array_accum (anyelement)
(
    sfunc = array_append,
    stype = anyarray,
    initcond = '{}'
);

CREATE OR REPLACE FUNCTION trisano.build_form_tables() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    questions_per_table     INTEGER := 200;
    form_name               TEXT;
    question_name           TEXT;
    question_count          INTEGER;
    cur_table_count         INTEGER;
    cur_table_name          TEXT;
    last_event_id           INTEGER;
    last_event_type         TEXT;
    insert_vals_clause      TEXT;
    insert_cols_clause      TEXT;
    tmprec                  RECORD;
    tmptext                 TEXT;
    tmpbool                 BOOLEAN;
    done                    BOOLEAN;
BEGIN
    -- This function creates tables for formbuilder data, in a series of steps:
    --
    -- 1) Develop schema for formbuilder tables
    --
    -- Forms are represented as one or more tables containing a column for
    -- each question. These tables contain up to questions_per_table columns.
    -- This step loops through each form name that has answers, and on each
    -- one, gets the lowercase short names of all answered questions
    -- associated with that form that aren't already assigned to a table
    -- (these assignments are recorded in the formbuilder_tables and
    -- formbuilder_columns tables in the trisano schema). These columns are
    -- added to the highest-numbered formbuilder table for this form (the only
    -- one that can possibly have room left for more columns) until it reaches
    -- questions_per_table columns, after which new tables are added. Any
    -- tables added or modified in this process are flagged so the metadata
    -- builder stuff can know to recreate that table.
    --
    -- 2) Build schema based on results from step 1
    --
    -- Having developed a schema in the last step, this step builds each of
    -- the tables defined in the formbuilder tables.
    --
    -- 3) Fill tables with data
    --
    -- Answers are sorted into the tables they belong to, and the data are
    -- inserted into the tables

    -- Loop through each form
    FOR form_name IN
                SELECT DISTINCT short_name
                FROM forms
                WHERE short_name IS NOT NULL AND short_name != ''
                ORDER BY short_name LOOP

        RAISE NOTICE 'Processing form name %', form_name;

        -- Get highest-numbered table for this form, and count of its rows
        SELECT INTO cur_table_count count(*) FROM trisano.formbuilder_tables
            WHERE short_name = form_name;
        SELECT INTO tmprec id, table_name, count(*) AS count
            FROM trisano.formbuilder_tables t
            JOIN trisano.formbuilder_columns c
                ON (c.formbuilder_table_name = t.table_name)
            WHERE t.short_name = form_name
            GROUP BY id, table_name
            ORDER BY id DESC
            LIMIT 1;
        question_count := tmprec.count;
        cur_table_name := tmprec.table_name;

        -- If we haven't found a table, make sure we're set up to create a new
        -- one properly
        IF question_count IS NULL THEN
            question_count := questions_per_table;
            cur_table_count := 0;
        END IF;
        tmpbool := FALSE;

        RAISE NOTICE 'Found table name %, question count % for form name %', COALESCE(cur_table_name, '<null>'), question_count, form_name;

        -- Get columns represented in the forms that aren't already in the
        -- defined schema
        <<question_loop>>
        FOR tmprec IN SELECT DISTINCT
                    q.short_name,
                    regexp_replace(lower(q.short_name), '[^[:alnum:]_]', '_', 'g') AS safe_name
                FROM questions q JOIN answers a
                    ON (a.question_id = q.id AND a.text_answer IS NOT NULL AND a.text_answer != '')
                JOIN form_elements fe ON (fe.id = q.form_element_id)
                JOIN forms f
                    ON (f.id = fe.form_id AND f.short_name = form_name)
                WHERE NOT EXISTS (
                    SELECT 1 FROM trisano.formbuilder_columns tfc
                    JOIN trisano.formbuilder_tables tft
                        ON (tfc.formbuilder_table_name = tft.table_name
                            AND tft.short_name = form_name)
                    WHERE tfc.orig_column_name = q.short_name
                )
                AND q.short_name IS NOT NULL AND q.short_name != ''
                ORDER BY 1 LOOP

            question_name := tmprec.safe_name;

            -- Create a new table if the current one is full
            IF question_count >= questions_per_table THEN
                cur_table_count := cur_table_count + 1;
                cur_table_name := 'formbuilder_' ||
                    regexp_replace(lower(form_name), '[^[:alnum:]_]', '_', 'g') ||
                    '_' || cur_table_count;
                    --regexp_replace(lower(q.short_name), '[^[:alnum:]_]', '_', 'g') AS safe_name
                RAISE NOTICE 'Creating schema for table %, form %', cur_table_name, form_name;
                INSERT INTO trisano.formbuilder_tables (short_name,
                    table_name) VALUES (form_name, trisano.shorten_identifier(cur_table_name));
                question_count := 0;
                tmpbool := FALSE;
            END IF;

            -- The loop takes care of columns with different short_names that reduce to
            -- the same safe name
            <<add_column>>
            LOOP
                done := TRUE;
                BEGIN
                    INSERT INTO trisano.formbuilder_columns (formbuilder_table_name,
                        column_name, orig_column_name)
                        VALUES (cur_table_name, trisano.shorten_identifier(question_name), tmprec.short_name);

                    -- Make sure table is marked as modified, as necessary
                    IF NOT tmpbool THEN
                        UPDATE trisano.formbuilder_tables SET modified = TRUE WHERE
                            table_name = cur_table_name;
                        tmpbool := TRUE;
                    END IF;
                EXCEPTION
                    WHEN unique_violation THEN
                        question_name := question_name || '1';
                    done := FALSE;
                END;
                IF done THEN
                    EXIT add_column;
                END IF;
            END LOOP add_column;

            question_count := question_count + 1;
        END LOOP question_loop;
    END LOOP;

    -- Create tables to match the schema we've just built
    FOR tmprec IN SELECT table_name, trisano.text_join_agg(column_name, ' TEXT, col_') AS cols
        FROM trisano.formbuilder_tables t JOIN trisano.formbuilder_columns c
            ON t.table_name = c.formbuilder_table_name
        GROUP BY table_name ORDER BY table_name
    LOOP
        tmptext := 'CREATE TABLE ' || tmprec.table_name || ' (event_id INTEGER, type TEXT, col_'
                    || tmprec.cols || ' TEXT);';
        RAISE NOTICE 'Creating table %', tmprec.table_name;
        EXECUTE tmptext;
    END LOOP;

    -- Fill tables with data from answers
    FOR cur_table_name IN SELECT table_name FROM trisano.formbuilder_tables ORDER BY table_name LOOP
        RAISE NOTICE 'Filling table %', cur_table_name;
        tmptext := '';

        insert_cols_clause := ' (event_id, type';
        insert_vals_clause := '';
        last_event_id := NULL;
        last_event_type := NULL;

        -- Find all non-blank answers and associated event information
        FOR tmprec IN SELECT DISTINCT ON (a.event_id, e.type, tfc.column_name) a.event_id, e.type, tfc.column_name AS short_name, a.text_answer
                    FROM answers a JOIN events e ON (e.id = a.event_id)
                    JOIN questions q ON (a.question_id = q.id)
                    JOIN form_elements fe ON (fe.id = q.form_element_id)
                    JOIN forms f ON (f.id = fe.form_id)
                    JOIN trisano.formbuilder_columns tfc ON (tfc.orig_column_name = q.short_name)
                    WHERE tfc.formbuilder_table_name = cur_table_name
                    AND a.text_answer IS NOT NULL
                    AND a.text_answer != ''
                    ORDER BY a.event_id, e.type, short_name LOOP

            IF last_event_id IS NOT NULL AND last_event_id != tmprec.event_id THEN
                tmptext := 'INSERT INTO ' || cur_table_name || insert_cols_clause || ') VALUES (' || last_event_id || ', ''' || last_event_type || '''' || insert_vals_clause || ')';
                EXECUTE tmptext;
                insert_cols_clause := ' (event_id, type';
                insert_vals_clause := '';
            END IF;
            last_event_id   := tmprec.event_id;
            last_event_type := tmprec.type;

            insert_cols_clause := insert_cols_clause || ', ' || quote_ident('col_' || tmprec.short_name);
            insert_vals_clause := insert_vals_clause || ', ' || quote_literal(tmprec.text_answer);
        END LOOP;

        IF last_event_id IS NOT NULL THEN
            tmptext := 'INSERT INTO ' || cur_table_name || insert_cols_clause || ') VALUES (' || last_event_id || ', ''' || last_event_type || '''' || insert_vals_clause || ')';
            EXECUTE tmptext;
        END IF;

        -- Create indexes while we're here
        RAISE NOTICE 'Creating indexes for table %', cur_table_name;
        EXECUTE 'CREATE UNIQUE INDEX ' || trisano.shorten_identifier(cur_table_name || '_event_id_ix') || ' ON ' || cur_table_name || ' (event_id)';
        EXECUTE 'CREATE INDEX ' || trisano.shorten_identifier(cur_table_name || '_event_type_ix') || ' ON ' || cur_table_name || ' (type)';
    END LOOP;
END;
$$;
-- END OF trisano.build_form_tables()

-- Commenting structure
DROP TABLE IF EXISTS trisano.schema_comments;

CREATE TABLE trisano.schema_comments (
    object_type TEXT,
    object_name TEXT,
    object_comment TEXT
);

INSERT INTO trisano.schema_comments (object_type, object_name, object_comment) VALUES
    ('SCHEMA', 'population', 'Schema for OLAP population and rate calculation data'),
    ('TABLE', 'population.population_dimensions', 'Describes each of the OLAP dimensions usable for population calculation'),
    ('COLUMN', 'population.population_dimensions.dim_name', 'Names of each OLAP dimension for which population divisions are known'),
    ('COLUMN', 'population.population_dimensions.dim_cols', 'Column names to be searched for population counts. Each array element corresponds to a different level of the dimension hierarchy'),
    ('COLUMN', 'population.population_dimensions.mapping_func', 'Functions to map OLAP values to something the underlying population tables will understand. Each element correspond to a level of the dimension hierarchy'),
    ('TABLE', 'population.population_tables', 'Records the tables in the population schema that record population information'),
    ('COLUMN', 'population.population_tables.table_name', 'Name of the population table'),
    ('COLUMN', 'population.population_tables.table_rank', 'When multiple tables will provide the required information, this rank is used to find the desired table. Lowest ranks are selected first (e.g. the table with rank 1 is the best one to use, all else being equal'),
    ('SCHEMA', 'public', 'Staging area for data warehouse ETL process'),
    ('SCHEMA', 'trisano', 'Contains views used for reporting and OLAP '),
    ('VIEW', 'trisano.addresses_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.answers_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.attachments_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.cdc_exports_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.codes_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.core_fields_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.csv_fields_view', 'data dictionary ignore'),
    ('TABLE', 'trisano.current_schema_name', 'Internal -- used so ETL process knows which schema can be dumped and reloaded'),
    ('COLUMN', 'trisano.current_schema_name.schemaname', 'Contains the name of the schema currently in use by the warehouse, and referenced by all the views'),
    ('VIEW', 'trisano.db_files_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.disease_events_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.diseases_export_columns_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.diseases_external_codes_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.diseases_forms_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.diseases_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.dw_contact_answers_view', 'Formbuilder answers applicable to contact events. See transactional database, answers table for more information'),
    ('COLUMN', 'trisano.dw_contact_answers_view.code', ''),
    ('VIEW', 'trisano.dw_contact_clinicians_view', 'Clinician information applicable to contact events'),
    ('COLUMN', 'trisano.dw_contact_clinicians_view.dw_contact_events_id', 'The contact event ID this answer refers to'),
    ('COLUMN', 'trisano.dw_contact_clinicians_view.first_name', ''),
    ('COLUMN', 'trisano.dw_contact_clinicians_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_clinicians_view.last_name', ''),
    ('COLUMN', 'trisano.dw_contact_clinicians_view.middle_name', ''),
    ('VIEW', 'trisano.dw_contact_diagnostic_facilities_view', 'Diagnostic facility information applicable to contact events'),
    ('COLUMN', 'trisano.dw_contact_diagnostic_facilities_view.dw_contact_events_id', 'The contact event ID this answer refers to'),
    ('COLUMN', 'trisano.dw_contact_diagnostic_facilities_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_diagnostic_facilities_view.name', 'Name of the diagnostic facility'),
    ('COLUMN', 'trisano.dw_contact_diagnostic_facilities_view.place_id', 'Places table record related to this record'),
    ('COLUMN', 'trisano.dw_contact_diagnostic_facilities_view.place_type', 'Type of facility'),
    ('VIEW', 'trisano.dw_contact_diseases_view', 'Diseases related to contact events. See diseases table for more information'),
    ('COLUMN', 'trisano.dw_contact_diseases_view.active', ''),
    ('COLUMN', 'trisano.dw_contact_diseases_view.cdc_code', ''),
    ('COLUMN', 'trisano.dw_contact_diseases_view.contact_lead_in', ''),
    ('COLUMN', 'trisano.dw_contact_diseases_view.disease_name', ''),
    ('COLUMN', 'trisano.dw_contact_diseases_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_diseases_view.place_lead_in', ''),
    ('COLUMN', 'trisano.dw_contact_diseases_view.treatment_lead_in', ''),
    ('VIEW', 'trisano.dw_contact_events_view', 'Table of contact events. Most fields match the events table'),
    ('COLUMN', 'trisano.dw_contact_events_view.actual_age_at_onset', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.actual_age_type', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.additional_risk_factors', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.age_in_years', 'Calculated age in years, based on actual_age_at_onset and actual_age_type'),
    ('COLUMN', 'trisano.dw_contact_events_view.city', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.contact_type', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.county', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.date_created', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.date_deleted', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.date_disease_diagnosed', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.date_disease_onset', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.date_entered_into_system', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.date_investigation_completed', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.date_investigation_started', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.date_updated', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.day_care_association', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.disease_event_died', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.disease_event_hospitalized', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.disease_id', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.disposition', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.dw_patients_id', 'ID of patient record related to this event'),
    ('COLUMN', 'trisano.dw_contact_events_view.estimated_age_at_onset', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.estimated_age_type', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.event_queue_id', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.food_handler', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.group_living', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.healthcare_worker', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.ibis_updated_at', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_events_view.imported_from_code', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.investigating_jurisdiction', 'Name of the investigating jurisdiction'),
    ('COLUMN', 'trisano.dw_contact_events_view.investigating_jurisdiction_id', 'Places table record for this investigating jurisdiction'),
    ('COLUMN', 'trisano.dw_contact_events_view.investigator', 'Name of investigator'),
    ('COLUMN', 'trisano.dw_contact_events_view.jurisdiction_of_residence', 'Name of jurisdiction of residence'),
    ('COLUMN', 'trisano.dw_contact_events_view.jurisdiction_of_residence_id', 'Places table record for this jurisdiction of residence'),
    ('COLUMN', 'trisano.dw_contact_events_view.latitude', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.longitude', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.occupation', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.other_data_1', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.other_data_2', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.parent_id', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.postal_code', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.pregnancy_due_date', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.pregnant', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.review_completed_by_state_date', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.risk_factor_details', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.sent_to_ibis', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.state', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.street_name', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.street_number', ''),
    ('COLUMN', 'trisano.dw_contact_events_view.unit_number', ''),
    ('VIEW', 'trisano.dw_contact_hospitals_view', 'Information about hospital admissions related to contact events'),
    ('COLUMN', 'trisano.dw_contact_hospitals_view.admission_date', ''),
    ('COLUMN', 'trisano.dw_contact_hospitals_view.discharge_date', ''),
    ('COLUMN', 'trisano.dw_contact_hospitals_view.dw_contact_events_id', ''),
    ('COLUMN', 'trisano.dw_contact_hospitals_view.hospital_name', ''),
    ('COLUMN', 'trisano.dw_contact_hospitals_view.hospital_record_number', ''),
    ('COLUMN', 'trisano.dw_contact_hospitals_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_hospitals_view.medical_record_number', ''),
    ('VIEW', 'trisano.dw_contact_jurisdictions_view', 'Jurisdictions related to contact events'),
    ('COLUMN', 'trisano.dw_contact_jurisdictions_view.created_at', ''),
    ('COLUMN', 'trisano.dw_contact_jurisdictions_view.entity_id', ''),
    ('COLUMN', 'trisano.dw_contact_jurisdictions_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_jurisdictions_view.name', ''),
    ('COLUMN', 'trisano.dw_contact_jurisdictions_view.short_name', ''),
    ('COLUMN', 'trisano.dw_contact_jurisdictions_view.updated_at', ''),
    ('VIEW', 'trisano.dw_contact_lab_results_view', 'Lab results for contact events. See lab results view for more information'),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.collection_date', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.comment', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.dw_contact_events_id', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.dw_encounter_events_id', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.lab_test_date', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.lab_type', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.loinc_code', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.name', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.reference_range', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.result_value', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.specimen_sent_to_state', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.specimen_source', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.test_result', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.test_status', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.test_type', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.units', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.hl7_message', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.staged_message_state', ''),
    ('COLUMN', 'trisano.dw_contact_lab_results_view.staged_message_note', ''),
    ('VIEW', 'trisano.dw_contact_patients_races_view', 'Races of patients involved in contact events. See patients_races table for more information'),
    ('COLUMN', 'trisano.dw_contact_patients_races_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_patients_races_view.person_id', ''),
    ('COLUMN', 'trisano.dw_contact_patients_races_view.race', ''),
--    ('VIEW', 'trisano.dw_contact_patients_view', 'Patients involved in contact events. See people table for more information'),
--    ('COLUMN', 'trisano.dw_contact_patients_view.birth_date', ''),
--    ('COLUMN', 'trisano.dw_contact_patients_view.birth_gender', ''),
--    ('COLUMN', 'trisano.dw_contact_patients_view.date_of_death', ''),
--    ('COLUMN', 'trisano.dw_contact_patients_view.entity_id', ''),
--    ('COLUMN', 'trisano.dw_contact_patients_view.ethnicity', ''),
--    ('COLUMN', 'trisano.dw_contact_patients_view.first_name', ''),
--    ('COLUMN', 'trisano.dw_contact_patients_view.first_name_soundex', ''),
--    ('COLUMN', 'trisano.dw_contact_patients_view.id', 'Primary key'),
--    ('COLUMN', 'trisano.dw_contact_patients_view.last_name', ''),
--    ('COLUMN', 'trisano.dw_contact_patients_view.last_name_soundex', ''),
--    ('COLUMN', 'trisano.dw_contact_patients_view.middle_name', ''),
--    ('COLUMN', 'trisano.dw_contact_patients_view.primary_language', ''),
    ('VIEW', 'trisano.dw_contact_questions_view', 'Questions on forms related to contact events. See questions table for more information'),
    ('COLUMN', 'trisano.dw_contact_questions_view.core_data', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.core_data_attr', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.created_at', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.data_type', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.form_element_id', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.help_text', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_questions_view.is_required', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.question_text', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.short_name', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.size', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.style', ''),
    ('COLUMN', 'trisano.dw_contact_questions_view.updated_at', ''),
    ('VIEW', 'trisano.dw_contact_secondary_jurisdictions_view', 'Secondary jurisdictions of contact events'),
    ('COLUMN', 'trisano.dw_contact_secondary_jurisdictions_view.dw_contact_events_id', ''),
    ('COLUMN', 'trisano.dw_contact_secondary_jurisdictions_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_secondary_jurisdictions_view.jurisdiction_id', 'Places record related to this jurisdiction'),
    ('COLUMN', 'trisano.dw_contact_secondary_jurisdictions_view.name', 'Name of the jurisdiction'),
    ('VIEW', 'trisano.dw_contact_treatments_events_view', 'Treatment events related to contact events. See treatment_events table for more information'),
    ('COLUMN', 'trisano.dw_contact_treatments_events_view.date_of_treatment', ''),
    ('COLUMN', 'trisano.dw_contact_treatments_events_view.dw_contact_events_id', ''),
    ('COLUMN', 'trisano.dw_contact_treatments_events_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_treatments_events_view.treatment_given', ''),
    ('COLUMN', 'trisano.dw_contact_treatments_events_view.treatment_id', ''),
    ('COLUMN', 'trisano.dw_contact_treatments_events_view.treatment_notes', ''),
    ('VIEW', 'trisano.dw_contact_treatments_view', 'Treatments related to contact events. See treatments table for more information'),
    ('COLUMN', 'trisano.dw_contact_treatments_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_contact_treatments_view.treatment_name', ''),
    ('COLUMN', 'trisano.dw_contact_treatments_view.treatment_type_id', ''),
    ('VIEW', 'trisano.dw_date_dimension_view', 'Dates used in various records. This provides functionality for the date-related dimensions in the OLAP system'),
    ('COLUMN', 'trisano.dw_date_dimension_view.day_of_month', ''),
    ('COLUMN', 'trisano.dw_date_dimension_view.day_of_week', ''),
    ('COLUMN', 'trisano.dw_date_dimension_view.day_of_year', ''),
    ('COLUMN', 'trisano.dw_date_dimension_view.fulldate', ''),
    ('COLUMN', 'trisano.dw_date_dimension_view.month', ''),
    ('COLUMN', 'trisano.dw_date_dimension_view.quarter', ''),
    ('COLUMN', 'trisano.dw_date_dimension_view.week_of_year', ''),
    ('COLUMN', 'trisano.dw_date_dimension_view.year', ''),
    ('VIEW', 'trisano.dw_encounter_answers_view', 'Formbuilder answers provided in relation to encounter events. See answers table for more information'),
    ('COLUMN', 'trisano.dw_encounter_answers_view.code', ''),
    ('COLUMN', 'trisano.dw_encounter_answers_view.event_id', ''),
    ('COLUMN', 'trisano.dw_encounter_answers_view.export_conversion_value_id', ''),
    ('COLUMN', 'trisano.dw_encounter_answers_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_encounter_answers_view.question_id', ''),
    ('COLUMN', 'trisano.dw_encounter_answers_view.text_answer', ''),
    ('VIEW', 'trisano.dw_encounter_patients_view', 'Patients involved in encounter events. See people table for more information'),
    ('COLUMN', 'trisano.dw_encounter_patients_view.birth_date', ''),
    ('COLUMN', 'trisano.dw_encounter_patients_view.birth_gender', ''),
    ('COLUMN', 'trisano.dw_encounter_patients_view.date_of_death', ''),
    ('COLUMN', 'trisano.dw_encounter_patients_view.entity_id', ''),
    ('COLUMN', 'trisano.dw_encounter_patients_view.ethnicity', ''),
    ('COLUMN', 'trisano.dw_encounter_patients_view.first_name', ''),
    ('COLUMN', 'trisano.dw_encounter_patients_view.first_name_soundex', ''),
    ('COLUMN', 'trisano.dw_encounter_patients_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_encounter_patients_view.last_name', ''),
    ('COLUMN', 'trisano.dw_encounter_patients_view.last_name_soundex', ''),
    ('COLUMN', 'trisano.dw_encounter_patients_view.middle_name', ''),
    ('COLUMN', 'trisano.dw_encounter_patients_view.primary_language', ''),
    ('VIEW', 'trisano.dw_encounter_questions_view', 'Questions asked on forms for encounter events. See questions table for more information'),
    ('COLUMN', 'trisano.dw_encounter_questions_view.core_data', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.core_data_attr', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.created_at', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.data_type', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.form_element_id', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.help_text', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_encounter_questions_view.is_required', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.question_text', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.short_name', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.size', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.style', ''),
    ('COLUMN', 'trisano.dw_encounter_questions_view.updated_at', ''),
    ('VIEW', 'trisano.dw_encounters_lab_results_view', 'Lab results for encounter events. See lab_results table for more information'),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.collection_date', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.comment', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.dw_contact_events_id', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.dw_encounter_events_id', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.lab_test_date', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.lab_type', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.loinc_code', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.name', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.reference_range', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.result_value', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.specimen_sent_to_state', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.specimen_source', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.test_result', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.test_status', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.test_type', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.units', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.hl7_message', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.staged_message_state', ''),
    ('COLUMN', 'trisano.dw_encounters_lab_results_view.staged_message_note', ''),
    ('VIEW', 'trisano.dw_encounters_treatments_events_view', 'Treatment events for encounter events. See treatment_events table for more information'),
    ('COLUMN', 'trisano.dw_encounters_treatments_events_view.date_of_treatment', ''),
    ('COLUMN', 'trisano.dw_encounters_treatments_events_view.dw_encounter_events_id', ''),
    ('COLUMN', 'trisano.dw_encounters_treatments_events_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_encounters_treatments_events_view.treatment_given', ''),
    ('COLUMN', 'trisano.dw_encounters_treatments_events_view.treatment_id', ''),
    ('COLUMN', 'trisano.dw_encounters_treatments_events_view.treatment_notes', ''),
--    ('VIEW', 'trisano.dw_encounters_treatments_view', 'Treatments for encounter events. See treatments table for more information'),
--    ('COLUMN', 'trisano.dw_encounters_treatments_view.dw_encounters_id', ''),
--    ('COLUMN', 'trisano.dw_encounters_treatments_view.dw_events_treatments_id', ''),
--    ('COLUMN', 'trisano.dw_encounters_treatments_view.id', 'Primary key'),
    ('VIEW', 'trisano.dw_encounter_events_view', 'Encounter events. See events table for more information, but note that many fields have been removed because they do not relate to encounter events'),
    ('COLUMN', 'trisano.dw_encounter_events_view.description', ''),
    ('COLUMN', 'trisano.dw_encounter_events_view.dw_morbidity_events_id', 'The morbidity event parent of this event'),
    ('COLUMN', 'trisano.dw_encounter_events_view.encounter_date', ''),
    ('COLUMN', 'trisano.dw_encounter_events_view.encounter_event_id', ''),
    ('COLUMN', 'trisano.dw_encounter_events_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_encounter_events_view.investigator_id', 'Users table record containing the investigator for this event'),
    ('COLUMN', 'trisano.dw_encounter_events_view.location', ''),
    ('VIEW', 'trisano.dw_events_diagnostic_facilities_view', 'Diagnostic facilities for various event types'),
    ('COLUMN', 'trisano.dw_events_diagnostic_facilities_view.dw_contact_events_id', 'Contact event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_diagnostic_facilities_view.dw_morbidity_events_id', 'Morbidity event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_diagnostic_facilities_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_events_diagnostic_facilities_view.name', 'Name of the diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_diagnostic_facilities_view.place_id', 'Place record for this facility'),
    ('COLUMN', 'trisano.dw_events_diagnostic_facilities_view.place_type', 'Type of facility'),
    ('VIEW', 'trisano.dw_events_hospitals_view', 'Hospitalizations related to various events'),
    ('COLUMN', 'trisano.dw_events_hospitals_view.admission_date', ''),
    ('COLUMN', 'trisano.dw_events_hospitals_view.discharge_date', ''),
    ('COLUMN', 'trisano.dw_events_hospitals_view.dw_contact_events_id', 'Contact event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_hospitals_view.dw_morbidity_events_id', 'Morbidity event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_hospitals_view.hospital_name', ''),
    ('COLUMN', 'trisano.dw_events_hospitals_view.hospital_record_number', ''),
    ('COLUMN', 'trisano.dw_events_hospitals_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_events_hospitals_view.medical_record_number', ''),
    ('VIEW', 'trisano.dw_events_reporters_view', 'Reporters for various event types'),
    ('COLUMN', 'trisano.dw_events_reporters_view.dw_contact_events_id', 'Contact event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_reporters_view.dw_morbidity_events_id', 'Morbidity event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_reporters_view.first_name', ''),
    ('COLUMN', 'trisano.dw_events_reporters_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_events_reporters_view.last_name', ''),
    ('COLUMN', 'trisano.dw_events_reporters_view.middle_name', ''),
    ('VIEW', 'trisano.dw_events_reporting_agencies_view', 'Reporting agencies for various event types'),
    ('COLUMN', 'trisano.dw_events_reporting_agencies_view.dw_contact_events_id', 'Contact event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_reporting_agencies_view.dw_morbidity_events_id', 'Morbidity event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_reporting_agencies_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_events_reporting_agencies_view.name', ''),
    ('COLUMN', 'trisano.dw_events_reporting_agencies_view.place_id', ''),
    ('COLUMN', 'trisano.dw_events_reporting_agencies_view.place_type', ''),
    ('VIEW', 'trisano.dw_events_treatments_view', 'Treatments events related to morbidity, encounter, or contact events'),
    ('COLUMN', 'trisano.dw_events_treatments_view.date_of_treatment', ''),
    ('COLUMN', 'trisano.dw_events_treatments_view.dw_contact_events_id', 'Contact event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_treatments_view.dw_encounter_events_id', 'Encounter event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_treatments_view.dw_morbidity_events_id', 'Morbidity event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_events_treatments_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_events_treatments_view.treatment_given', ''),
    ('COLUMN', 'trisano.dw_events_treatments_view.treatment_id', ''),
    ('COLUMN', 'trisano.dw_events_treatments_view.treatment_notes', ''),
    ('VIEW', 'trisano.dw_lab_results_view', 'Lab result records for various event types. See lab results table for more information'),
    ('COLUMN', 'trisano.dw_lab_results_view.collection_date', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.comment', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.dw_contact_events_id', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.dw_encounter_events_id', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_lab_results_view.lab_test_date', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.lab_type', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.loinc_code', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.name', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.reference_range', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.result_value', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.specimen_sent_to_state', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.specimen_source', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.test_result', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.test_status', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.test_type', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.units', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.hl7_message', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.staged_message_state', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.staged_message_note', ''),
    ('COLUMN', 'trisano.dw_lab_results_view.dw_contact_events_id', 'Contact event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_lab_results_view.dw_encounter_events_id', 'Encounter event ID, if any, related to this diagnostic facility'),
    ('COLUMN', 'trisano.dw_lab_results_view.dw_morbidity_events_id', 'Morbidity event ID, if any, related to this diagnostic facility'),
    ('VIEW', 'trisano.dw_morbidity_answers_view', 'Formbuild answers related to morbidity events. See answers table for more information'),
    ('COLUMN', 'trisano.dw_morbidity_answers_view.code', ''),
    ('COLUMN', 'trisano.dw_morbidity_answers_view.event_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_answers_view.export_conversion_value_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_answers_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_answers_view.question_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_answers_view.text_answer', ''),
    ('VIEW', 'trisano.dw_morbidity_clinicians_view', 'Clinicians related to morbidity events'),
    ('COLUMN', 'trisano.dw_morbidity_clinicians_view.dw_morbidity_events_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_clinicians_view.first_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_clinicians_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_clinicians_view.last_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_clinicians_view.middle_name', ''),
    ('VIEW', 'trisano.dw_morbidity_diagnostic_facilities_view', 'Diagnostic facilities asscoiated with morbidity events'),
    ('COLUMN', 'trisano.dw_morbidity_diagnostic_facilities_view.dw_morbidity_events_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_diagnostic_facilities_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_diagnostic_facilities_view.name', ''),
    ('COLUMN', 'trisano.dw_morbidity_diagnostic_facilities_view.place_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_diagnostic_facilities_view.place_type', ''),
    ('VIEW', 'trisano.dw_morbidity_diseases_view', 'Diseases related to morbidity events. See diseases table for more information'),
    ('COLUMN', 'trisano.dw_morbidity_diseases_view.active', ''),
    ('COLUMN', 'trisano.dw_morbidity_diseases_view.cdc_code', ''),
    ('COLUMN', 'trisano.dw_morbidity_diseases_view.contact_lead_in', ''),
    ('COLUMN', 'trisano.dw_morbidity_diseases_view.disease_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_diseases_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_diseases_view.place_lead_in', ''),
    ('COLUMN', 'trisano.dw_morbidity_diseases_view.treatment_lead_in', ''),
    ('VIEW', 'trisano.dw_morbidity_events_view', 'Morbidity event records. See events table for more information'),
    ('COLUMN', 'trisano.dw_morbidity_events_view.actual_age_at_onset', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.actual_age_type', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.acuity', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.additional_risk_factors', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.age_in_years', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.city', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.contact_type_if_once_a_contact', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.county', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.date_created', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.date_deleted', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.date_disease_diagnosed', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.date_disease_onset', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.date_entered_into_system', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.date_investigation_completed', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.date_investigation_started', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.date_reported_to_public_health', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.date_updated', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.day_care_association', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.disease_event_died', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.disease_event_hospitalized', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.disease_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.disposition_if_once_a_contact', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.dw_patients_id', 'Patient record for this event'),
    ('COLUMN', 'trisano.dw_morbidity_events_view.estimated_age_at_onset', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.estimated_age_type', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.event_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.event_queue_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.food_handler', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.group_living', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.healthcare_worker', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.ibis_updated_at', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_events_view.imported_from_code', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.investigating_jurisdiction', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.investigating_jurisdiction_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.investigator', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.jurisdiction_of_residence', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.jurisdiction_of_residence_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.latitude', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.lhd_case_status_code', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.longitude', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.mmwr_week', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.mmwr_year', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.occupation', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.other_data_1', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.other_data_2', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.outbreak_associated_code', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.outbreak_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.parent_guardian', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.parent_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.postal_code', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.pregnancy_due_date', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.pregnant', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.record_number', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.results_reported_to_clinician_date', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.review_completed_by_state_date', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.risk_factor_details', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.sent_to_cdc', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.sent_to_ibis', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.state', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.state_case_status_code', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.street_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.street_number', ''),
    ('COLUMN', 'trisano.dw_morbidity_events_view.unit_number', ''),
    ('VIEW', 'trisano.dw_morbidity_hospitals_view', 'Hospitalizations related to morbidity events'),
    ('COLUMN', 'trisano.dw_morbidity_hospitals_view.admission_date', ''),
    ('COLUMN', 'trisano.dw_morbidity_hospitals_view.discharge_date', ''),
    ('COLUMN', 'trisano.dw_morbidity_hospitals_view.dw_contact_events_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_hospitals_view.dw_morbidity_events_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_hospitals_view.hospital_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_hospitals_view.hospital_record_number', ''),
    ('COLUMN', 'trisano.dw_morbidity_hospitals_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_hospitals_view.medical_record_number', ''),
    ('VIEW', 'trisano.dw_morbidity_jurisdictions_view', 'Jurisdictions of morbidity events'),
    ('COLUMN', 'trisano.dw_morbidity_jurisdictions_view.created_at', ''),
    ('COLUMN', 'trisano.dw_morbidity_jurisdictions_view.entity_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_jurisdictions_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_jurisdictions_view.name', ''),
    ('COLUMN', 'trisano.dw_morbidity_jurisdictions_view.short_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_jurisdictions_view.updated_at', ''),
    ('VIEW', 'trisano.dw_morbidity_lab_results_view', 'Lab results for morbidity events. See lab_results table for more infomrmation'),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.collection_date', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.comment', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.dw_contact_events_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.dw_encounter_events_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.lab_test_date', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.lab_type', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.loinc_code', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.name', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.reference_range', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.result_value', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.specimen_sent_to_state', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.specimen_source', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.test_result', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.test_status', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.test_type', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.units', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.hl7_message', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.staged_message_state', ''),
    ('COLUMN', 'trisano.dw_morbidity_lab_results_view.staged_message_note', ''),
    ('VIEW', 'trisano.dw_morbidity_patients_races_view', 'Races of patients in morbidity events'),
    ('COLUMN', 'trisano.dw_morbidity_patients_races_view.id', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_races_view.person_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_races_view.race', ''),
    ('VIEW', 'trisano.dw_morbidity_patients_view', 'Patients associated with morbidity events. See people table for more information'),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.birth_date', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.birth_gender', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.date_of_death', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.entity_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.ethnicity', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.first_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.first_name_soundex', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.last_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.last_name_soundex', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.middle_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_patients_view.primary_language', ''),
    ('VIEW', 'trisano.dw_morbidity_questions_view', 'Formbuilder questions related to morbidity events. See questions table for more information'),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.core_data', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.core_data_attr', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.created_at', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.data_type', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.form_element_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.help_text', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.is_required', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.question_text', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.short_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.size', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.style', ''),
    ('COLUMN', 'trisano.dw_morbidity_questions_view.updated_at', ''),
    ('VIEW', 'trisano.dw_morbidity_reporters_view', 'Reporter records for morbidity events'),
    ('COLUMN', 'trisano.dw_morbidity_reporters_view.dw_morbidity_events_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_reporters_view.first_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_reporters_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_reporters_view.last_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_reporters_view.middle_name', ''),
    ('VIEW', 'trisano.dw_morbidity_reporting_agencies_view', 'Reporting agencies for morbidity events'),
    ('COLUMN', 'trisano.dw_morbidity_reporting_agencies_view.dw_morbidity_events_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_reporting_agencies_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_reporting_agencies_view.name', ''),
    ('COLUMN', 'trisano.dw_morbidity_reporting_agencies_view.place_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_reporting_agencies_view.place_type', ''),
    ('VIEW', 'trisano.dw_morbidity_secondary_jurisdictions_view', 'Secondary jurisdictions for morbidity events'),
    ('COLUMN', 'trisano.dw_morbidity_secondary_jurisdictions_view.dw_morbidity_events_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_secondary_jurisdictions_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_secondary_jurisdictions_view.jurisdiction_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_secondary_jurisdictions_view.name', ''),
    ('VIEW', 'trisano.dw_morbidity_treatments_events_view', 'Treatment events for morbidity events'),
    ('COLUMN', 'trisano.dw_morbidity_treatments_events_view.date_of_treatment', ''),
    ('COLUMN', 'trisano.dw_morbidity_treatments_events_view.dw_morbidity_events_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_treatments_events_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_treatments_events_view.treatment_given', ''),
    ('COLUMN', 'trisano.dw_morbidity_treatments_events_view.treatment_id', ''),
    ('COLUMN', 'trisano.dw_morbidity_treatments_events_view.treatment_notes', ''),
    ('VIEW', 'trisano.dw_morbidity_treatments_view', 'Treatments related to morbidity events'),
    ('COLUMN', 'trisano.dw_morbidity_treatments_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_morbidity_treatments_view.treatment_name', ''),
    ('COLUMN', 'trisano.dw_morbidity_treatments_view.treatment_type_id', ''),
    ('VIEW', 'trisano.dw_patients_races_view', 'Races of patients'),
    ('COLUMN', 'trisano.dw_patients_races_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_patients_races_view.person_id', ''),
    ('COLUMN', 'trisano.dw_patients_races_view.race', ''),
    ('VIEW', 'trisano.dw_place_answers_view', 'Answers to formbuilder questions related to place events. See answers table for more information'),
    ('COLUMN', 'trisano.dw_place_answers_view.code', ''),
    ('COLUMN', 'trisano.dw_place_answers_view.event_id', ''),
    ('COLUMN', 'trisano.dw_place_answers_view.export_conversion_value_id', ''),
    ('COLUMN', 'trisano.dw_place_answers_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_place_answers_view.question_id', ''),
    ('COLUMN', 'trisano.dw_place_answers_view.text_answer', ''),
    ('VIEW', 'trisano.dw_place_events_view', 'Place events. See events table for more information, keeping in mind that many fields have been removed'),
    ('COLUMN', 'trisano.dw_place_events_view.city', ''),
    ('COLUMN', 'trisano.dw_place_events_view.county', ''),
    ('COLUMN', 'trisano.dw_place_events_view.dw_morbidity_events_id', 'Morbidity event record that is the parent for this record'),
    ('COLUMN', 'trisano.dw_place_events_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_place_events_view.latitude', ''),
    ('COLUMN', 'trisano.dw_place_events_view.longitude', ''),
    ('COLUMN', 'trisano.dw_place_events_view.name', ''),
    ('COLUMN', 'trisano.dw_place_events_view.place_type', ''),
    ('COLUMN', 'trisano.dw_place_events_view.postal_code', ''),
    ('COLUMN', 'trisano.dw_place_events_view.state', ''),
    ('COLUMN', 'trisano.dw_place_events_view.street_name', ''),
    ('COLUMN', 'trisano.dw_place_events_view.street_number', ''),
    ('COLUMN', 'trisano.dw_place_events_view.unit_number', ''),
    ('VIEW', 'trisano.dw_place_questions_view', 'Formbuilder questions related to place events. See questions table for more information'),
    ('COLUMN', 'trisano.dw_place_questions_view.core_data', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.core_data_attr', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.created_at', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.data_type', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.form_element_id', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.help_text', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_place_questions_view.is_required', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.question_text', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.short_name', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.size', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.style', ''),
    ('COLUMN', 'trisano.dw_place_questions_view.updated_at', ''),
    ('VIEW', 'trisano.dw_secondary_jurisdictions_view', 'Secondary jurisdictions for various event typesj'),
    ('COLUMN', 'trisano.dw_secondary_jurisdictions_view.dw_contact_events_id', ''),
    ('COLUMN', 'trisano.dw_secondary_jurisdictions_view.dw_morbidity_events_id', ''),
    ('COLUMN', 'trisano.dw_secondary_jurisdictions_view.id', 'Primary key'),
    ('COLUMN', 'trisano.dw_secondary_jurisdictions_view.jurisdiction_id', ''),
    ('COLUMN', 'trisano.dw_secondary_jurisdictions_view.name', ''),
    ('VIEW', 'trisano.dw_outbreak_events_view', 'Outbreak events'),
    ('VIEW', 'trisano.email_addresses_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.encounters_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.entities_view', 'data dictionary ignore'),
    ('TABLE', 'trisano.etl_success', 'Internal - records results of ETL processes'),
    ('VIEW', 'trisano.event_queues_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.events_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.export_columns_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.export_conversion_values_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.export_disease_groups_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.export_names_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.external_codes_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.form_elements_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.form_references_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.forms_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.hospitals_participations_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.lab_results_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.notes_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.participations_contacts_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.participations_encounters_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.participations_places_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.participations_risk_factors_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.participations_treatments_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.participations_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.people_races_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.people_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.places_types_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.places_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.privileges_roles_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.privileges_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.questions_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.role_memberships_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.roles_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.schema_migrations_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.staged_messages_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.tasks_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.telephones_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.treatments_view', 'data dictionary ignore'),
    ('VIEW', 'trisano.users_view', 'data dictionary ignore');
-- END OF commenting structure

CREATE OR REPLACE FUNCTION trisano.swap_schemas() RETURNS BOOLEAN AS $$
DECLARE
    cur_schema TEXT;
    new_schema TEXT;
    tmp TEXT;
    tmp2 TEXT;
    viewname TEXT;
    validetl BOOLEAN;
    orig_search_path TEXT;
    tmprec RECORD;
    tblnum INTEGER;
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
    EXECUTE 'COMMENT ON SCHEMA staging IS ''Holds the actual warehouse data. data dictionary ignore''';
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
      WHERE pg_namespace.nspname = new_schema AND pg_class.relkind = 'r' AND relname NOT LIKE 'fb_%'
      LOOP
        tmp := 'CREATE VIEW trisano.' || viewname || '_view AS SELECT * FROM ' || new_schema || '.' || viewname;
        EXECUTE tmp;
    END LOOP;

    -- Create a whole bunch of event-type-specific views. This helps Pentaho
    -- not have cycles in its graph of the schema
    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_patients_races_view AS
            SELECT pr.* FROM ' || new_schema || '.dw_patients_races pr
            WHERE EXISTS (
                SELECT 1 FROM trisano.dw_morbidity_events_view
                WHERE dw_patients_id = pr.person_id
            )';
--            JOIN (
--                SELECT DISTINCT dw_patients_id FROM ' || new_schema || '.dw_morbidity_events
--            ) p
--                ON (p.dw_patients_id = pr.person_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_patients_races_view AS
            SELECT pr.* FROM ' || new_schema || '.dw_patients_races pr
            JOIN (
                SELECT DISTINCT dw_patients_id FROM ' || new_schema || '.dw_contact_events
            ) p 
                ON (p.dw_patients_id = pr.person_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_encounter_patients_races_view AS
            SELECT pr.* FROM ' || new_schema || '.dw_patients_races pr
            JOIN (
                SELECT DISTINCT dw_patients_id FROM ' || new_schema || '.dw_encounter_events
            ) p
                ON (p.dw_patients_id = pr.person_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_diagnostic_facilities_view AS
            SELECT * FROM ' || new_schema || '.dw_events_diagnostic_facilities
            WHERE dw_morbidity_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_diagnostic_facilities_view AS
            SELECT * FROM ' || new_schema || '.dw_events_diagnostic_facilities
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
        'CREATE VIEW trisano.dw_encounters_treatments_events_view AS
            SELECT * FROM ' || new_schema || '.dw_events_treatments
            WHERE dw_encounter_events_id IS NOT NULL';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_treatments_view AS
            SELECT t.* FROM ' || new_schema || '.treatments t
            WHERE EXISTS (
                SELECT 1 FROM trisano.dw_events_treatments_view
                WHERE dw_morbidity_events_id IS NOT NULL AND
                    treatment_id = t.id
            )';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_treatments_view AS
            SELECT t.* FROM ' || new_schema || '.treatments t
            WHERE EXISTS (
                SELECT 1 FROM trisano.dw_events_treatments_view
                WHERE dw_contact_events_id IS NOT NULL AND
                    treatment_id = t.id
            )';

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
            SELECT * FROM ' || new_schema || '.dw_lab_results
            WHERE dw_encounter_events_id IS NOT NULL';

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

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_email_addresses_view AS
            SELECT t.*
            FROM ' || new_schema || '.dw_email_addresses t
            INNER JOIN (
                SELECT DISTINCT patient_entity_id
                FROM ' || new_schema || '.dw_morbidity_events
            ) f
                ON (t.entity_id = f.patient_entity_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_email_addresses_view AS
            SELECT t.*
            FROM ' || new_schema || '.dw_email_addresses t
            INNER JOIN (
                SELECT DISTINCT patient_entity_id
                FROM ' || new_schema || '.dw_contact_events
            ) f
                ON (t.entity_id = f.patient_entity_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_encounter_email_addresses_view AS
            SELECT t.*
            FROM ' || new_schema || '.dw_email_addresses t
            INNER JOIN (
                SELECT DISTINCT patient_entity_id
                FROM ' || new_schema || '.dw_encounter_events
            ) f
                ON (t.entity_id = f.patient_entity_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_morbidity_telephones_view AS
            SELECT t.*
            FROM ' || new_schema || '.dw_telephones t
            INNER JOIN (
                SELECT DISTINCT patient_entity_id
                FROM ' || new_schema || '.dw_morbidity_events
            ) f
                ON (t.entity_id = f.patient_entity_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_contact_telephones_view AS
            SELECT t.*
            FROM ' || new_schema || '.dw_telephones t
            INNER JOIN (
                SELECT DISTINCT patient_entity_id
                FROM ' || new_schema || '.dw_contact_events
            ) f
                ON (t.entity_id = f.patient_entity_id)';

    EXECUTE
        'CREATE VIEW trisano.dw_encounter_telephones_view AS
            SELECT t.*
            FROM ' || new_schema || '.dw_telephones t
            INNER JOIN (
                SELECT DISTINCT patient_entity_id
                FROM ' || new_schema || '.dw_encounter_events
            ) f
                ON (t.entity_id = f.patient_entity_id)';

    FOR viewname IN
      SELECT relname
      FROM pg_class JOIN pg_namespace
      ON (pg_class.relnamespace = pg_namespace.oid)
      WHERE nspname = 'trisano' AND relkind = 'v'
      LOOP
        tmp := 'GRANT SELECT ON trisano.' || viewname || ' TO trisano_ro';
        EXECUTE tmp;
    END LOOP;

    -- Do object comments
    -- This loop isn't terribly robust against weird comment values,
    -- because trapping errors in PL/pgSQL is painful. Since we're populating
    -- the comments table manually, this *shouldn't* be a problem.
    FOR tmprec IN
        SELECT
            object_type, object_name, object_comment
        FROM trisano.schema_comments
        -- Trap unknown namespaces here because there's apparently no exception
        -- type to trap invalid schema errors below
        LEFT JOIN information_schema.schemata s
            ON (s.schema_name = object_name)
        WHERE
            lower(object_type) != 'schema'
            OR s.schema_name IS NOT NULL
    LOOP
        tmp := 'COMMENT ON ' || tmprec.object_type || ' ' || tmprec.object_name || ' IS ''' || tmprec.object_comment || '''';
        BEGIN
            EXECUTE tmp;
        EXCEPTION
            WHEN undefined_column THEN
                RAISE NOTICE 'Exception: unknown column %', tmprec.object_name;
            WHEN undefined_table THEN
                RAISE NOTICE 'Exception: unknown table %', tmprec.object_name;
            END;
    END LOOP;

    UPDATE trisano.current_schema_name SET schemaname = new_schema;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
-- END OF trisano.swap_schemas()

SET search_path = population;

DROP TABLE IF EXISTS population_tables;

DROP TABLE IF EXISTS population_dimensions CASCADE;

CREATE TABLE population_tables (
    table_name text NOT NULL,
    table_rank integer NOT NULL
);

GRANT SELECT ON population_tables TO trisano_ro;

CREATE TABLE population_dimensions (
    dim_name text NOT NULL,
    dim_cols text[],
    mapping_func text[],
    required boolean default false
);

GRANT SELECT ON population_dimensions TO trisano_ro;

ALTER TABLE ONLY population_dimensions
    ADD CONSTRAINT dim_name_pkey PRIMARY KEY (dim_name);
ALTER TABLE ONLY population_tables
    ADD CONSTRAINT population_tables_pkey PRIMARY KEY (table_name);
ALTER TABLE ONLY population_tables
    ADD CONSTRAINT population_tables_table_rank_key UNIQUE (table_rank);

INSERT INTO population_dimensions VALUES
    ('Investigating Jurisdiction', ARRAY['jurisdiction'], NULL, false),
    ('Race',                       ARRAY['race'],         NULL, false),
    ('Population Year',            ARRAY['year'],         NULL, true);

DROP TABLE IF EXISTS population;

CREATE TABLE population (
    race TEXT,
    jurisdiction TEXT,
    year TEXT,
    population INTEGER
);

GRANT SELECT ON population TO trisano_ro;

INSERT INTO population_tables VALUES ('population', 1);

CREATE OR REPLACE FUNCTION population.distinct_dimension_values(my_dim_name TEXT, my_level INTEGER) RETURNS SETOF TEXT STABLE AS $$
DECLARE
    col_name TEXT;
    table_name TEXT;
    query TEXT := '';
    value TEXT;
    tmp TEXT;
BEGIN
    -- Returns all distinct values for a particular level of a particular
    -- dimension across all population tables supporting that dimension

    -- First, find column name
    SELECT dim_cols[my_level] FROM population.population_dimensions WHERE dim_name = my_dim_name INTO col_name;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Couldn''t find column for dimension called %, level %', my_dim_name, my_level;
    END IF;

    -- Now, find tables containing that column
    FOR table_name IN
        SELECT
            ppt.table_name
        FROM
            population.population_tables ppt
            JOIN information_schema.columns isc
                ON (
                    isc.table_name = ppt.table_name AND
                    isc.table_schema = 'population'
                )
        WHERE
            isc.column_name = col_name
    LOOP
        IF query != '' THEN
            query := query || ' UNION ALL ';
        END IF;
        query := query || '(SELECT ' || col_name || '::TEXT AS res FROM population.' || table_name || ')';
    END LOOP; -- Tables containing the dimension we want

    IF query = '' THEN
        RAISE EXCEPTION 'Found no tables containing the dimension %', my_dim_name;
    END IF;
  
    tmp := query;
    query := 'SELECT DISTINCT res FROM ( ' || tmp || ' ) f ORDER BY res';

    RAISE DEBUG 'getting distinct values for dimension % level % using this query: %', my_dim_name, my_level, query;
    FOR value IN EXECUTE query LOOP
        RETURN NEXT value;
    END LOOP; -- Results loop
END;
$$ LANGUAGE plpgsql;
-- End of distinct_dimension_values

GRANT EXECUTE ON FUNCTION population.distinct_dimension_values(my_dim_name TEXT, my_level INTEGER)
    TO trisano_ro;

CREATE OR REPLACE VIEW population.population_years AS
    SELECT 1 AS id, d.year AS year
    FROM population.distinct_dimension_values('Population Year'::text, 1) d(year);

GRANT SELECT ON population.population_years TO trisano_ro;

COMMIT;

-- Sample script to create bogus population data, to be run after etl.sh runs
--
-- SET search_path = population;
-- INSERT INTO population (jurisdiction, race, population)
--     SELECT investigating_jurisdiction, race, floor(random() * 1000)
--     FROM
--         (SELECT DISTINCT investigating_jurisdiction FROM trisano.dw_morbidity_events_view) a
--         CROSS JOIN (SELECT DISTINCT race FROM trisano.dw_patient_races_view) b;
