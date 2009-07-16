SET search_path = population, pg_catalog;

CREATE FUNCTION translate_gender(text) RETURNS text
    AS $_$
select case when $1 = 'Male' then 'M' when $1 = 'Female' then 'F' else null end; $_$
    LANGUAGE sql IMMUTABLE;

CREATE FUNCTION translate_race(text) RETURNS text
    AS $_$
select case when $1 = 'Alaskan Native' Then 'Alaska Native' when $1 = 'Black / African-American' then 'Black or African American' when $1 = 'Native Hawaiian / Pacific Islander' then 'Pacific Islander' else $1 end;$_$
    LANGUAGE sql IMMUTABLE;

CREATE TABLE population_dimensions (
    dim_name text,
    dim_cols text[],
    mapping_func text[]
);

COPY population_dimensions (dim_name, dim_cols, mapping_func) FROM stdin;
Gender	{gender}	{population.translate_gender}
Investigating Jurisdiction	{jurisdiction}	\N
Race	{race}	{population.translate_race}
Age	{age_group,age}	\N
Ethnicity	{ethnicity}	\N
\.

GRANT USAGE ON SCHEMA :TRISANO_POP_SCHEMA TO :TRISANO_POP_DWUSER;
GRANT SELECT ON TABLE :TRISANO_POP_SCHEMA.population_dimensions TO :TRISANO_POP_DWUSER;
