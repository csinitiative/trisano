/* $PostgreSQL: pgsql/contrib/pg_trgm/pg_trgm.sql.in,v 1.7 2007/12/09 02:22:46 tgl Exp $ */

-- Adjust this setting to control where the objects get created.
SET search_path = public;

CREATE OR REPLACE FUNCTION set_limit(float4)
RETURNS float4
AS '$libdir/pg_trgm'
LANGUAGE C STRICT VOLATILE;

CREATE OR REPLACE FUNCTION show_limit()
RETURNS float4
AS '$libdir/pg_trgm'
LANGUAGE C STRICT STABLE;

CREATE OR REPLACE FUNCTION show_trgm(text)
RETURNS _text
AS '$libdir/pg_trgm'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION similarity(text,text)
RETURNS float4
AS '$libdir/pg_trgm'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION similarity_op(text,text)
RETURNS bool
AS '$libdir/pg_trgm'
LANGUAGE C STRICT STABLE;

CREATE OPERATOR % (
        LEFTARG = text,
        RIGHTARG = text,
        PROCEDURE = similarity_op,
        COMMUTATOR = '%',
        RESTRICT = contsel,
        JOIN = contjoinsel
);

-- gist key
CREATE OR REPLACE FUNCTION gtrgm_in(cstring)
RETURNS gtrgm
AS '$libdir/pg_trgm'
LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION gtrgm_out(gtrgm)
RETURNS cstring
AS '$libdir/pg_trgm'
LANGUAGE C STRICT;

CREATE TYPE gtrgm (
        INTERNALLENGTH = -1,
        INPUT = gtrgm_in,
        OUTPUT = gtrgm_out
);

-- support functions for gist
CREATE OR REPLACE FUNCTION gtrgm_consistent(gtrgm,internal,int4)
RETURNS bool
AS '$libdir/pg_trgm'
LANGUAGE C IMMUTABLE;
 
CREATE OR REPLACE FUNCTION gtrgm_compress(internal)
RETURNS internal
AS '$libdir/pg_trgm'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION gtrgm_decompress(internal)
RETURNS internal
AS '$libdir/pg_trgm'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION gtrgm_penalty(internal,internal,internal)
RETURNS internal
AS '$libdir/pg_trgm'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION gtrgm_picksplit(internal, internal)
RETURNS internal
AS '$libdir/pg_trgm'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION gtrgm_union(bytea, internal)
RETURNS _int4
AS '$libdir/pg_trgm'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION gtrgm_same(gtrgm, gtrgm, internal)
RETURNS internal
AS '$libdir/pg_trgm'
LANGUAGE C IMMUTABLE;

-- create the operator class for gist
CREATE OPERATOR CLASS gist_trgm_ops
FOR TYPE text USING gist
AS
        OPERATOR        1       % (text, text),
        FUNCTION        1       gtrgm_consistent (gtrgm, internal, int4),
        FUNCTION        2       gtrgm_union (bytea, internal),
        FUNCTION        3       gtrgm_compress (internal),
        FUNCTION        4       gtrgm_decompress (internal),
        FUNCTION        5       gtrgm_penalty (internal, internal, internal),
        FUNCTION        6       gtrgm_picksplit (internal, internal),
        FUNCTION        7       gtrgm_same (gtrgm, gtrgm, internal),
        STORAGE         gtrgm;

-- support functions for gin
CREATE OR REPLACE FUNCTION gin_extract_trgm(text, internal)
RETURNS internal
AS '$libdir/pg_trgm'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION gin_extract_trgm(text, internal, internal)
RETURNS internal
AS '$libdir/pg_trgm'
LANGUAGE C IMMUTABLE;

CREATE OR REPLACE FUNCTION gin_trgm_consistent(internal, internal, text)
RETURNS internal
AS '$libdir/pg_trgm'
LANGUAGE C IMMUTABLE;

-- create the operator class for gin
CREATE OPERATOR CLASS gin_trgm_ops
FOR TYPE text USING gin
AS
        OPERATOR        1       % (text, text) RECHECK,
        FUNCTION        1       btint4cmp (int4, int4),
        FUNCTION        2       gin_extract_trgm (text, internal),
        FUNCTION        3       gin_extract_trgm (text, internal, internal),
        FUNCTION        4       gin_trgm_consistent (internal, internal, text),
        STORAGE         int4;
