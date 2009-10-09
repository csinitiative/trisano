SET SEARCH_PATH = :TRISANO_POP_SCHEMA;

CREATE TEMPORARY TABLE jurisdiction_county_map (
    jurisdiction text,
    county text
);

INSERT INTO jurisdiction_county_map VALUES ('Southwest District Health Department', 'Beaver County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Bear River District Health Department', 'Box Elder County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Bear River District Health Department', 'Cache County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Southeast District Health Department', 'Carbon County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Davis County Health Department', 'Davis County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Southeast District Health Department', 'Emery County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Southwest District Health Department', 'Garfield County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Southeast District Health Department', 'Grand County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Southwest District Health Department', 'Iron County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Central Utah District Health Department', 'Juab County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Southwest District Health Department', 'Kane County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Central Utah District Health Department', 'Millard County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Weber-Morgan Health Department', 'Morgan County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Central Utah District Health Department', 'Piute County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Bear River District Health Department', 'Rich County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Salt Lake Valley Health Department', 'Salt Lake County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Southeast District Health Department', 'San Juan County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Central Utah District Health Department', 'Sanpete County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Central Utah District Health Department', 'Sevier County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Summit County Health Department', 'Summit County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Tooele County Health Department', 'Tooele County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Utah County Health Department', 'Utah County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Wasatch County Health Department', 'Wasatch County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Southwest District Health Department', 'Washington County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Central Utah District Health Department', 'Wayne County, UT');
INSERT INTO jurisdiction_county_map VALUES ('Weber-Morgan Health Department', 'Weber County, UT');
INSERT INTO jurisdiction_county_map VALUES ('TriCounty Health Department', 'Daggett County, UT');
INSERT INTO jurisdiction_county_map VALUES ('TriCounty Health Department', 'Duchesne County, UT');
INSERT INTO jurisdiction_county_map VALUES ('TriCounty Health Department', 'Uintah County, UT');

CREATE TEMPORARY TABLE percentages (
    race text,
    percentage integer
);

INSERT INTO percentages VALUES ('Asian', 50);
INSERT INTO percentages VALUES ('American Indian', 50);

DROP TABLE IF EXISTS population;
CREATE TABLE population AS
SELECT
    age,
    CASE
        WHEN age::INTEGER = 0 THEN '< 1 year'
        WHEN age::INTEGER < 5 THEN '1-4 years'
        WHEN age::INTEGER = 85 THEN '85+ years'
        ELSE (5 * floor(age::INTEGER / 5))::TEXT || '-' || (5 * floor(age::INTEGER / 5) + 4)::TEXT || ' years'
    END AS age_group,
    ethnicity,
    jurisdiction,
    gender_code AS gender,
    CASE
        WHEN race = 'American Indian or Alaska Native' THEN 'American Indian'
        WHEN race = 'Asian or Pacific Islander' THEN 'Asian'
        ELSE race
    END AS race,
    :TRISANO_POP_YEAR::TEXT AS year,
    CASE
        WHEN race = 'American Indian or Alaska Native' THEN
            floor(population * (SELECT percentage FROM percentages WHERE race = 'American Indian') / 100)
        WHEN race = 'Asian or Pacific Islander' THEN
            floor(population * (SELECT percentage FROM percentages WHERE race = 'Asian') / 100)
        ELSE population
    END AS population
FROM
    (
        SELECT
            CASE
                WHEN age = '< 1 year' THEN 0::TEXT
                ELSE regexp_replace(age, $$\+? years?$$, '')
            END AS age,
            ethnicity,
            county,
            gender_code,
            race,
            population
        FROM
            popinit
    ) f
    JOIN jurisdiction_county_map
        USING (county)

UNION ALL

SELECT
    age,
    CASE
        WHEN age::INTEGER = 0 THEN '< 1 year'
        WHEN age::INTEGER < 5 THEN '1-4 years'
        WHEN age::INTEGER = 85 THEN '85+ years'
        ELSE (5 * floor(age::INTEGER / 5))::TEXT || '-' || (5 * floor(age::INTEGER / 5) + 4)::TEXT || ' years'
    END AS age_group,
    ethnicity,
    jurisdiction,
    gender_code AS gender,
    CASE
        WHEN race = 'American Indian or Alaska Native' THEN 'Alaska Native'
        WHEN race = 'Asian or Pacific Islander' THEN 'Pacific Islander'
        ELSE race
    END AS race,
    :TRISANO_POP_YEAR AS year,
    CASE
        WHEN race = 'American Indian or Alaska Native' THEN
            population - floor(population * (SELECT percentage FROM percentages WHERE race = 'American Indian') / 100)
        WHEN race = 'Asian or Pacific Islander' THEN
            population - floor(population * (SELECT percentage FROM percentages WHERE race = 'Asian') / 100)
        ELSE population
    END AS population
FROM
    (
        SELECT
            CASE
                WHEN age = '< 1 year' THEN 0::TEXT
                ELSE regexp_replace(age, $$\+? years?$$, '')
            END AS age,
            ethnicity,
            county,
            gender_code,
            race,
            population
        FROM
            popinit
        WHERE
            race IN ('American Indian or Alaska Native', 'Asian or Pacific Islander')
    ) f
    JOIN jurisdiction_county_map
        USING (county)
;

--DROP TABLE popinit;
GRANT SELECT ON :TRISANO_POP_SCHEMA.population TO :TRISANO_POP_DWUSER;
