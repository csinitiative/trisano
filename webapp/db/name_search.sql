BEGIN;

CREATE TEXT SEARCH DICTIONARY simple_no_stop (
    TEMPLATE = pg_catalog.simple,
    stopwords = 'empty' );

CREATE TEXT SEARCH CONFIGURATION simple_no_stop (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR asciiword WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR word WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR numword WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR email WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR url WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR host WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR sfloat WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR version WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR hword_numpart WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR hword_part WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR hword_asciipart WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR numhword WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR asciihword WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR hword WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR url_path WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR file WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR "float" WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR "int" WITH simple_no_stop;

ALTER TEXT SEARCH CONFIGURATION simple_no_stop
    ADD MAPPING FOR uint WITH simple_no_stop;

CREATE OR REPLACE FUNCTION get_full_name(VARCHAR, VARCHAR) RETURNS VARCHAR AS $$
    SELECT COALESCE($1, ''::varchar) || ' '::varchar || COALESCE($2, ''::varchar)
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION get_trigram_tsvector(TEXT) RETURNS tsvector AS $$
    SELECT
    to_tsvector(
        'simple_no_stop'::regconfig,
        array_to_string(
            show_trgm(
                lower($1)
            ), ' '::text
        )
    )
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION search_for_trigram_fts(TEXT) RETURNS SETOF RECORD LANGUAGE SQL STABLE AS $$
    SELECT id, first_name, last_name,
        ts_rank(get_trigram_tsvector(
            get_full_name(first_name, last_name)),
            to_tsquery(array_to_string(show_trgm(lower($1)), '|'::text))) AS rank
    FROM people
    WHERE
        get_trigram_tsvector(get_full_name(first_name, last_name)) @@
        to_tsquery(array_to_string(show_trgm(lower($1)), '|'::text))

        UNION

    SELECT id, first_name, last_name,
        ts_rank(get_trigram_tsvector(first_name),
            to_tsquery(array_to_string(show_trgm(lower($1)), '|'::text))) AS rank
    FROM people
    WHERE
        get_trigram_tsvector(first_name) @@
        to_tsquery(array_to_string(show_trgm(lower($1)), '|'::text))

        UNION

    SELECT id, first_name, last_name,
        ts_rank(get_trigram_tsvector(last_name),
            to_tsquery(array_to_string(show_trgm(lower($1)), '|'::text))) AS rank
    FROM people
    WHERE
        get_trigram_tsvector(last_name) @@
        to_tsquery(array_to_string(show_trgm(lower($1)), '|'::text))
$$;

CREATE OR REPLACE FUNCTION search_for_name_fts(TEXT) RETURNS SETOF RECORD LANGUAGE SQL STABLE AS $$
    SELECT id, first_name, last_name,
        ts_rank(
            to_tsvector('simple_no_stop'::regconfig, get_full_name(first_name, last_name)),
            to_tsquery(array_to_string(regexp_split_to_array($1, E'\\s+'), '|'))
        )
    FROM people
        WHERE
        to_tsvector(get_full_name(first_name, last_name)) @@
        to_tsquery(array_to_string(regexp_split_to_array($1, E'\\s+'), '|'))
$$;

CREATE OR REPLACE FUNCTION
    search_for_name_trgm(TEXT)
    RETURNS SETOF RECORD
    LANGUAGE SQL STABLE AS
$$
    SELECT id, first_name, last_name,
        ts_rank(get_trigram_tsvector(last_name),
            to_tsquery(array_to_string(show_trgm(lower($1)), '|'::text))
        ) AS rank
    FROM people
    WHERE
        get_trigram_tsvector(last_name) @@
        to_tsquery(array_to_string(show_trgm(lower($1)), '|'::text))
$$;

CREATE OR REPLACE FUNCTION search_for_name(TEXT) RETURNS SETOF RECORD LANGUAGE SQL STABLE AS $$
    SELECT id, last_name, first_name, sources, summed_rank +
        similarity(COALESCE(last_name, ''), $1) + similarity(COALESCE(first_name, ''), $1) +
        (
            CASE WHEN soundex($1) = soundex(first_name) THEN 1 ELSE 0 END +
            CASE WHEN soundex($1) = soundex(last_name) THEN 1 ELSE 0 END +
            CASE WHEN metaphone($1, 10) = metaphone(first_name, 10) THEN 1 ELSE 0 END +
            CASE WHEN metaphone($1, 10) = metaphone(last_name, 10) THEN 1 ELSE 0 END
         ) / 4 AS rank
   FROM (

        SELECT id, last_name, first_name, SUM(rank) AS summed_rank, ARRAY_ACCUM(source) AS sources FROM (
            SELECT id, first_name, last_name, rank, 'trigram_fts'::text AS source
            FROM search_for_trigram_fts($1) AS a(id iNTEGER, first_name VARCHAR, last_name VARCHAR, rank REAL)
                UNION
            SELECT id, first_name, last_name, rank, 'name_fts'::text AS source
            FROM search_for_name_fts($1) AS a(id INTEGER, first_name VARCHAR, last_name VARCHAR, rank REAL)
                UNION
            SELECT id, first_name, last_name, rank, 'name_trgm'::text AS source
            FROM search_for_name_trgm($1) AS a(id INTEGER, first_name VARCHAR, last_name VARCHAR, rank REAL)
        ) a
        GROUP BY id, first_name, last_name
    ) b
    ORDER BY rank DESC
$$;

CREATE INDEX full_name_trgm_ix ON people USING GIST
    (get_trigram_tsvector(get_full_name(first_name, last_name)));

CREATE INDEX first_name_trgm_ix ON people USING GIST (get_trigram_tsvector(first_name));

CREATE INDEX last_name_trgm_ix ON people USING GIST (get_trigram_tsvector(last_name));

CREATE INDEX full_name_fts_ix ON people USING gist (to_tsvector('simple_no_stop'::regconfig,
                get_full_name(first_name, last_name)));

COMMIT;
