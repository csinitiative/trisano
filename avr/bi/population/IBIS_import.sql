-- This file takes CSV files from Utah's IBIS system and creates OLAP-suitable
-- population tables from them. See the TriSano EE Utah wiki for the files

BEGIN;

SET search_path = population;

DROP TABLE IF EXISTS newpop;
DROP TABLE IF EXISTS racecombined;

CREATE TABLE newpop_src (
    year integer,
    popcount integer,
    age integer,
    rescnty integer,
    sex integer,
    dist integer,
    dist2 integer,
    ptcounty2 integer,
    rescnty2 integer
);

-- CREATE TABLE pop_y2k (
--     year integer,
--     popcount integer,
--     age integer,
--     rescnty integer,
--     sex integer,
--     rescnty2 integer,
--     dist integer,
--     dist2 integer,
--     ptcounty2 integer,
--     agepop integer,
--     agepop10 integer,
--     agegrp2 integer,
--     agegrp4 integer,
--     magegrp integer,
--     dthyr integer,
--     dutcnty integer
-- );
-- 
-- CREATE TABLE racealone (
--     fips integer,
--     year integer,
--     agegrp integer,
--     popcount integer,
--     sex integer,
--     race integer,
--     origin integer,
--     cnty_code integer,
--     dist integer
-- );

CREATE TABLE racecombined_src (
    fips integer,
    year integer,
    agegrp integer,
    popcount integer,
    sex integer,
    race integer,
    origin integer,
    cnty_code integer,
    dist integer
);

copy newpop_src from '/home/josh/tmp/trisano/population/newpop80_60_2008_7_23.csv' with csv header;
-- copy pop_y2k from '/home/josh/tmp/trisano/population/pop_y2k_2008_7_23.csv' with csv header;
-- copy racealone from '/home/josh/tmp/trisano/population/racealone.csv' with csv header;
copy racecombined_src from '/home/josh/tmp/trisano/population/racecombined.csv' with csv header;

CREATE TABLE sex_map (a INTEGER, b TEXT);
INSERT INTO sex_map VALUES (1, 'Male'), (2, 'Female');

CREATE TABLE county_map (a INTEGER, b TEXT);
INSERT INTO county_map VALUES
    (1, 'Beaver'), (2, 'Box Elder'), (3, 'Cache'), (4, 'Carbon'),
    (5, 'Daggett'), (6, 'Davis'), (7, 'Duchesne'), (8, 'Emery'),
    (9, 'Garfield'), (10, 'Grand'), (11, 'Iron'), (12, 'Juab'),
    (13, 'Kane'), (14, 'Millard'), (15, 'Morgan'), (16, 'Piute'),
    (17, 'Rich'), (18, 'Salt Lake'), (19, 'San Juan'), (20, 'Sanpete'),
    (21, 'Sevier'), (22, 'Summit'), (23, 'Tooele'), (24, 'Uintah'),
    (25, 'Utah'), (26, 'Wasatch'), (27, 'Washington'), (28, 'Wayne'),
    (29, 'Weber'), (99, 'UNK');

CREATE TABLE dist_map (a INTEGER, b TEXT);
INSERT INTO dist_map VALUES
    (1, 'Bear River Health Department'),
    (2, 'Central Utah Public Health Department'),
    (3, 'Davis County Health Department'),
    (4, 'Salt Lake Valley Health Department'),
    (5, 'Southeastern Utah District Health Department'),
    (6, 'Southwest Utah Public Health Department'),
    (7, 'Summit County Public Health Department'),
    (8, 'Tooele County Health Department'),
    (9, 'TriCounty Health Department'),
    (10, 'Utah County Health Department'),
    (11, 'Wasatch County Health Department'),
    (12, 'Weber-Morgan Health Department');

CREATE TABLE race_map (a INTEGER, b TEXT);
INSERT INTO race_map VALUES 
--    (1, 'White'),
--    (2, 'Black or African American'),
--    (3, 'American Indian or Alaskan Native'),
--    (4, 'Asian'),
--    (5, 'Native Hawaiian or Other Pacific Islander'),
--    (6, 'Two or more races'),
    (7, 'White'),
    (8, 'Black / African-American'),
    (9, 'American Indian and Alaskan Native'),  -- TODO: Figure out how to split this up
    (10, 'Asian'),
    (11, 'Native Hawaiian / Pacific Islander');

CREATE TABLE origin_map (a INTEGER, b TEXT);
INSERT INTO origin_map VALUES (1, 'Not Hispanic or Latino'), (2, 'Hispanic or Latino');

CREATE TABLE agegrp_map (a INTEGER, b TEXT);
INSERT INTO agegrp_map VALUES
    (1, '0-4 years'),
    (2, '5-9 years'),
    (3, '10-14 years'),
    (4, '15-19 years'),
    (5, '20-24 years'),
    (6, '25-29 years'),
    (7, '30-34 years'),
    (8, '35-39 years'),
    (9, '40-44 years'),
    (10, '45-49 years'),
    (11, '50-54 years'),
    (12, '55-59 years'),
    (13, '60-64 years'),
    (14, '65-69 years'),
    (15, '70-74 years'),
    (16, '75-79 years'),
    (17, '80-84 years'),
    (18, '85+ years');

CREATE TABLE newpop AS
    SELECT
        year,
        popcount AS population,
        age,
        trisano.get_age_group(age) AS age_group,
        sex_map.b AS sex,
        rcmap.b AS county,
        dm.b AS jurisdiction
    FROM
        newpop_src
        JOIN county_map rcmap
            ON (rescnty = rcmap.a)
        JOIN sex_map
            ON (sex_map.a = sex)
        JOIN dist_map dm
            ON (dm.a = dist)
    WHERE
        year = 2007
;

CREATE OR REPLACE FUNCTION get_age_group(INTEGER) RETURNS TEXT IMMUTABLE AS $$
    SELECT CASE
--        WHEN $1 < 1              THEN '< 1 year'
--        WHEN $1 < 5 AND $1 >= 1 THEN '1-4 years'
        WHEN $1 >= 85            THEN '85+ years'
        ELSE
            (5 * FLOOR($1 / 5))::TEXT ||
            '-' ||
            (5 * FLOOR($1 / 5) + 1)::TEXT ||
            ' years'
    END;
$$ LANGUAGE sql;

-- CREATE TABLE pop_y2k_mapped AS
--     SELECT
--         year,
--         popcount,
--         age,
--         rescnty_map.b AS rescnty,
--         sex_map.b AS sex,
--         dist_map.b AS dist,
--         get_age_group(age) AS age_group,
--         magegrp
--     FROM
--         pop_y2k
--         JOIN county_map rescnty_map
--             ON (rescnty_map.a = rescnty)
--         JOIN sex_map
--             ON (sex = sex_map.a)
--         JOIN dist_map
--             ON (dist = dist_map.a)
-- ;
-- 
-- CREATE TABLE racealone_mapped AS
--     SELECT
--         year,
--         agegrp_map.b AS agegrp,
--         popcount,
--         sex_map.b AS sex,
--         race_map.b AS race,
--         origin_map.b AS origin,
--         county_map.b AS county,
--         dist_map.b AS dist
--     FROM
--         racealone
--         JOIN agegrp_map
--             ON (agegrp_map.a = agegrp)
--         JOIN sex_map
--             ON (sex_map.a = sex)
--         JOIN race_map
--             ON (race_map.a = race)
--         JOIN origin_map
--             ON (origin_map.a = origin)
--         JOIN county_map
--             ON (county_map.a = cnty_code)
--         JOIN dist_map
--             ON (dist_map.a = dist)
-- ;

CREATE TABLE racecombined AS
    SELECT
        year,
        agegrp_map.b AS age_group,
        popcount AS population,
        sex_map.b AS sex,
        race_map.b AS race,
        origin_map.b AS ethnicity,
        county_map.b AS county,
        dist_map.b AS jurisdiction
    FROM
        racecombined_src
        JOIN agegrp_map
            ON (agegrp_map.a = agegrp)
        JOIN sex_map
            ON (sex_map.a = sex)
        JOIN race_map
            ON (race_map.a = race)
        JOIN origin_map
            ON (origin_map.a = origin)
        JOIN county_map
            ON (county_map.a = cnty_code)
        JOIN dist_map
            ON (dist_map.a = dist)
    WHERE
        year = 2007
;

DROP TABLE newpop_src;
DROP TABLE racecombined_src;
DROP TABLE sex_map;
DROP TABLE dist_map;
DROP TABLE county_map;
DROP TABLE race_map;
DROP TABLE origin_map;
DROP TABLE agegrp_map;

TRUNCATE TABLE population_tables;
INSERT INTO population_tables (table_name, table_rank) VALUES ('newpop', 1), ('racecombined', 2);

GRANT SELECT ON newpop TO trisano_ro;
GRANT SELECT ON racecombined TO trisano_ro;

TRUNCATE TABLE population_dimensions;

INSERT INTO population_dimensions VALUES ('Investigating Jurisdiction', '{jurisdiction}', NULL);
INSERT INTO population_dimensions VALUES ('Age', '{age_group,age}', NULL);
INSERT INTO population_dimensions VALUES ('Ethnicity', '{ethnicity}', NULL);
INSERT INTO population_dimensions VALUES ('Race', '{race}', NULL);
INSERT INTO population_dimensions VALUES ('Gender', '{sex}', NULL);

COMMIT;
