-- KDHE population import script
-- SUMLEV,STATE,COUNTY,STNAME,CTYNAME,YEAR,AGEGRP,TOT_POP,TOT_MALE,TOT_FEMALE,WA_MALE,WA_FEMALE,BA_MALE,BA_FEMALE,IA_MALE,IA_FEMALE,AA_MALE,AA_FEMALE,NA_MALE,NA_FEMALE,TOM_MALE,TOM_FEMALE,NH_MALE,NH_FEMALE,NHWA_MALE,NHWA_FEMALE,NHBA_MALE,NHBA_FEMALE,NHIA_MALE,NHIA_FEMALE,NHAA_MALE,NHAA_FEMALE,NHNA_MALE,NHNA_FEMALE,NHTOM_MALE,NHTOM_FEMALE,H_FEMALE,HWA_MALE,HWA_FEMALE,HBA_MALE,HBA_FEMALE,HIA_MALE,HIA_FEMALE,HAA_MALE,HAA_FEMALE,HNA_MALE,HNA_FEMALE,HTOM_MALE,HTOM_FEMALE,H_MALE,HWAC_MALE
-- 50,20,1,Kansas,Allen County,2007,0,13407,6568,6839,6227,6494,130,136,67,64,14,31,0,0,130,114,6403,6676,6082,6348,126,130,56,57,14,31,0,0,125,110,163,145,146,4,6,11,7,0,0,0,0,5,4,165,150

BEGIN;

SET search_path = population;

DROP TABLE IF EXISTS kdhe_csv;

CREATE TABLE kdhe_csv (
    level INTEGER,
    state_code INTEGER,
    county_code INTEGER,
    state_name TEXT,
    county_name TEXT,
    year TEXT,
    age_group INTEGER,
    total_population INTEGER,
    total_male INTEGER,
    total_female INTEGER,
    wa_male INTEGER, -- white alone
    wa_female INTEGER,
    ba_male INTEGER, -- black / african american alone
    ba_female INTEGER,
    ia_male INTEGER, -- american indian or alaska native alone
    ia_female INTEGER,
    aa_male INTEGER, -- asian alone
    aa_female INTEGER,
    na_male INTEGER, -- native hawaiian or other pacific islander alone
    na_female INTEGER,
    tom_male INTEGER, -- two or more races
    tom_female INTEGER,
    nh_male INTEGER, -- non-hispanic, otherwise same as above
    nh_female INTEGER,
    nhwa_male INTEGER,
    nhwa_female INTEGER,
    nhba_male INTEGER,
    nhba_female INTEGER,
    nhia_male INTEGER,
    nhia_female INTEGER,
    nhaa_male INTEGER,
    nhaa_female INTEGER,
    nhna_male INTEGER,
    nhna_female INTEGER,
    nhtom_male INTEGER,
    nhtom_female INTEGER,
    h_female INTEGER, -- hispanic, same as above
    hwa_male INTEGER,
    hwa_female INTEGER,
    hba_male INTEGER,
    hba_female INTEGER,
    hia_male INTEGER,
    hia_female INTEGER,
    haa_male INTEGER,
    haa_female INTEGER,
    hna_male INTEGER,
    hna_female INTEGER,
    htom_male INTEGER,
    htom_female INTEGER,
    h_male INTEGER,
    hwac_male INTEGER
);

COPY kdhe_csv FROM '/home/josh/tmp/trisano/population/KDHE/pfiles.csv' WITH CSV HEADER;

DROP TABLE IF EXISTS agegrp_map;
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

TRUNCATE TABLE population_dimensions;

DROP TABLE IF EXISTS kdhe_population;
CREATE TABLE kdhe_population AS
    SELECT 
       nhwa_male AS population,
       'Non-Hispanic'::TEXT AS ethnicity,
       'Male'::TEXT AS gender,
       'White'::TEXT AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40         -- XXX Can we include this somewhere? Some other table perhaps...
    ;

INSERT INTO kdhe_population
    SELECT 
       hwa_male AS population,
       'Hispanic' AS ethnicity,
       'Male' AS gender,
       'White' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhwa_female AS population,
       'Non-Hispanic' AS ethnicity,
       'Female' AS gender,
       'White' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       hwa_female AS population,
       'Hispanic' AS ethnicity,
       'Female' AS gender,
       'White' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhba_male AS population,
       'Non-Hispanic' AS ethnicity,
       'Male' AS gender,
       'Black or African American' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       hba_male AS population,
       'Hispanic' AS ethnicity,
       'Male' AS gender,
       'Black or African American' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhba_female AS population,
       'Non-Hispanic' AS ethnicity,
       'Female' AS gender,
       'Black or African American' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       hba_female AS population,
       'Hispanic' AS ethnicity,
       'Female' AS gender,
       'Black or African American' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhaa_male AS population,
       'Non-Hispanic' AS ethnicity,
       'Male' AS gender,
       'Asian' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       haa_male AS population,
       'Hispanic' AS ethnicity,
       'Male' AS gender,
       'Asian' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhaa_female AS population,
       'Non-Hispanic' AS ethnicity,
       'Female' AS gender,
       'Asian' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       haa_female AS population,
       'Hispanic' AS ethnicity,
       'Female' AS gender,
       'Asian' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhia_male AS population,
       'Non-Hispanic' AS ethnicity,
       'Male' AS gender,
       'American Indian and Alaska Native' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       hia_male AS population,
       'Hispanic' AS ethnicity,
       'Male' AS gender,
       'American Indian and Alaska Native' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhia_female AS population,
       'Non-Hispanic' AS ethnicity,
       'Female' AS gender,
       'American Indian and Alaska Native' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       hia_female AS population,
       'Hispanic' AS ethnicity,
       'Female' AS gender,
       'American Indian and Alaska Native' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhna_male AS population,
       'Non-Hispanic' AS ethnicity,
       'Male' AS gender,
       'Native Hawaiian and Other Pacific Islander' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       hna_male AS population,
       'Hispanic' AS ethnicity,
       'Male' AS gender,
       'Native Hawaiian and Other Pacific Islander' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhna_female AS population,
       'Non-Hispanic' AS ethnicity,
       'Female' AS gender,
       'Native Hawaiian and Other Pacific Islander' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       hna_female AS population,
       'Hispanic' AS ethnicity,
       'Female' AS gender,
       'Native Hawaiian and Other Pacific Islander' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhtom_male AS population,
       'Non-Hispanic' AS ethnicity,
       'Male' AS gender,
       'Two or More Races' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       htom_male AS population,
       'Hispanic' AS ethnicity,
       'Male' AS gender,
       'Two or More Races' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       nhtom_female AS population,
       'Non-Hispanic' AS ethnicity,
       'Female' AS gender,
       'Two or More Races' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO kdhe_population
    SELECT 
       htom_female AS population,
       'Hispanic' AS ethnicity,
       'Female' AS gender,
       'Two or More Races' AS race, 
        county_name AS county,
        year AS population_year,
        agegrp_map.b
    FROM
        kdhe_csv JOIN agegrp_map ON age_group = agegrp_map.a
    WHERE
        age_group != 0 AND
        level != 40
    ;

INSERT INTO population_dimensions VALUES
    ('County', '{county}', NULL, default),
    ('Age Group', '{age_group}', NULL, default),
    ('Gender', '{gender}', NULL, default),
    ('Ethnicity', '{ethnicity}', NULL, default),
    ('Race', '{race}', NULL, default),
    ('Population Year', '{year}', NULL, true);

TRUNCATE TABLE population_tables;
INSERT INTO population_tables (table_name, table_rank) VALUES ('kdhe_population', 1);

DROP TABLE agegrp_map;
DROP TABLE kdhe_csv;

COMMIT;
