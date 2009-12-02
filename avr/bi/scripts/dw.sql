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


-- This script creates new denormalized tables from a freshly dumped OLTP
-- database, using a schema called "staging".

BEGIN;
    DROP SCHEMA IF EXISTS staging;
    ALTER SCHEMA public RENAME TO staging;
    CREATE SCHEMA public;
COMMIT;

BEGIN;

SET search_path = staging, public;

CREATE TABLE dw_date_dimension (
    fulldate        DATE PRIMARY KEY,
    day_of_week     INTEGER,
    day_of_month    INTEGER,
    day_of_year     INTEGER,
    month           INTEGER,
    quarter         INTEGER,
    week_of_year    INTEGER,
    year            INTEGER
);

-- Takes a date and returns its ID in the dw_date_dimension table, inserting it
-- if it doesn't exist
CREATE OR REPLACE FUNCTION upsert_date(d DATE) RETURNS DATE AS $$
BEGIN
    BEGIN
        INSERT INTO dw_date_dimension (fulldate, day_of_week, day_of_month, day_of_year,
                month, quarter, week_of_year, year)
            VALUES
                (d, EXTRACT(DOW FROM d), EXTRACT(DAY FROM d), EXTRACT(DOY FROM d),
                EXTRACT(MONTH FROM d), EXTRACT(QUARTER FROM d), EXTRACT(WEEK FROM d),
                EXTRACT(YEAR FROM d));
    EXCEPTION WHEN unique_violation THEN
        --
    END;
    RETURN d;
END;
$$ LANGUAGE plpgsql VOLATILE STRICT;

CREATE OR REPLACE FUNCTION upsert_date(t TIMESTAMP) RETURNS DATE AS $$
DECLARE
    date_id DATE;
BEGIN
    SELECT INTO date_id upsert_date(t::DATE);
    RETURN date_id;
END;
$$ LANGUAGE plpgsql VOLATILE STRICT;

CREATE OR REPLACE FUNCTION upsert_date(t TIMESTAMPTZ) RETURNS DATE AS $$
DECLARE
    date_id DATE;
BEGIN
    SELECT INTO date_id upsert_date(t::DATE);
    RETURN date_id;
END;
$$ LANGUAGE plpgsql VOLATILE STRICT;

CREATE OR REPLACE FUNCTION drop_my_object(a text, b text) RETURNS text AS $$
BEGIN
    EXECUTE 'DROP ' || b || ' ' || a || ';';
    RETURN 'Dropping ' || b || ' ' || a;
END;
$$
LANGUAGE PLPGSQL VOLATILE;
COMMIT;

BEGIN;
SELECT
    drop_my_object(tablename, 'TABLE')
FROM
    pg_tables t
WHERE
    schemaname = 'staging' AND
    tablename IN (
        'dw_morbidity_events',
        'dw_contact_events',
        'dw_secondary_jurisdictions',
        'dw_patients',
        'dw_events_hospitals',
        'dw_addresses',                -- Consider altering the table instead of creating a new one
        'dw_email_addresses',            -- Consider altering the table instead of creating a new one
        'dw_hospitals_participations',
        'dw_lab_results',
        'dw_participations_treatments',
        'dw_events_treatments',
        'dw_patients_races',
        'dw_events_clinicians',
        'dw_events_diagnostic_facilities',
        'dw_events_reporting_agencies',
        'dw_events_reporters',
        'dw_people_races',
        'dw_place_events',
        'dw_encounters',
        'dw_encounters_labs',
        'dw_encounters_treatments',
        'dw_morbidity_patients',
        'dw_contact_patients',
        'dw_place_patients',
        'dw_encounter_patients',
        'dw_morbidity_answers',
        'dw_contact_answers',
        'dw_place_answers',
        'dw_encounter_answers',
        'dw_morbidity_questions',
        'dw_contact_questions',
        'dw_place_questions',
        'dw_encounter_questions'
    );
COMMIT;

BEGIN;
SELECT
    drop_my_object(relname, 'SEQUENCE')
FROM
    pg_class c
    INNER JOIN pg_namespace n
        ON (n.oid = c.relnamespace)
WHERE
    relkind = 'S' AND
    relname IN (
        'dw_patients_races_seq',
        'dw_events_reporting_agencies_id_seq',
        'dw_events_diagnostic_facilities_id_seq'
    ) AND
    n.nspname = 'public' ;
COMMIT;

BEGIN;
CREATE TABLE dw_morbidity_patients AS
SELECT
    people.id,
    people.entity_id,            -- Keeping this just in case
    birth_gender_ec.code_description AS birth_gender,            -- code_description?
    ethnicity_ec.code_description AS ethnicity,                -- code_description?
    primary_language_ec.code_description AS primary_language,        -- code_description?
    people.first_name,
    people.middle_name,
    people.last_name,
    upsert_date(people.birth_date) AS birth_date,
    upsert_date(people.date_of_death) AS date_of_death,
    people.first_name_soundex,
    people.last_name_soundex
FROM
    people
    LEFT JOIN external_codes birth_gender_ec
        ON (birth_gender_ec.id = people.birth_gender_id AND birth_gender_ec.deleted_at IS NULL)
    LEFT JOIN external_codes ethnicity_ec
        ON (ethnicity_ec.id = people.ethnicity_id AND ethnicity_ec.deleted_at IS NULL)
    LEFT JOIN external_codes primary_language_ec
        ON (primary_language_ec.id = people.primary_language_id AND primary_language_ec IS NULL)
    INNER JOIN (
        SELECT
            part.primary_entity_id
        FROM
            participations part
            INNER JOIN events
                ON (events.id = part.event_id AND events.deleted_at IS NULL)
        WHERE
            part.type = 'InterestedParty' AND
            events.type = 'MorbidityEvent'
        GROUP BY part.primary_entity_id
    ) f
        ON (f.primary_entity_id = people.entity_id)
;

ALTER TABLE dw_morbidity_patients
    ADD CONSTRAINT dw_morbidity_patients_pkey PRIMARY KEY (id);
CREATE INDEX dw_morbidity_patients_entity_ix ON dw_morbidity_patients (entity_id);
CREATE INDEX dw_morbidity_patients_birth_gender_ix
    ON dw_morbidity_patients (birth_gender);
CREATE INDEX dw_morbidity_patients_ethnicity_ix ON dw_morbidity_patients (ethnicity);
CREATE INDEX dw_morbidity_patients_birth_date_ix
    ON dw_morbidity_patients (birth_date);
CREATE INDEX dw_morbidity_patients_date_of_death_ix
    ON dw_morbidity_patients (date_of_death);

CREATE TABLE dw_contact_patients AS
SELECT
    people.id,
    people.entity_id,            -- Keeping this just in case
    birth_gender_ec.code_description AS birth_gender,            -- code_description?
    ethnicity_ec.code_description AS ethnicity,                -- code_description?
    primary_language_ec.code_description AS primary_language,        -- code_description?
    people.first_name,
    people.middle_name,
    people.last_name,
    upsert_date(people.birth_date) AS birth_date,
    upsert_date(people.date_of_death) AS date_of_death,
    people.first_name_soundex,
    people.last_name_soundex
FROM
    people
    LEFT JOIN external_codes birth_gender_ec
        ON (birth_gender_ec.id = people.birth_gender_id AND birth_gender_ec.deleted_at IS NULL)
    LEFT JOIN external_codes ethnicity_ec
        ON (ethnicity_ec.id = people.ethnicity_id AND ethnicity_ec IS NULL)
    LEFT JOIN external_codes primary_language_ec
        ON (primary_language_ec.id = people.primary_language_id AND primary_language_ec IS NULL)
    INNER JOIN (
        SELECT
            part.primary_entity_id
        FROM
            participations part
            INNER JOIN events
                ON (events.id = part.event_id AND events.deleted_at IS NULL)
        WHERE
            part.type = 'InterestedParty' AND
            events.type = 'ContactEvent'
        GROUP BY part.primary_entity_id
    ) f
        ON (f.primary_entity_id = people.entity_id)
;

ALTER TABLE dw_contact_patients
    ADD CONSTRAINT dw_contact_patients_pkey PRIMARY KEY (id);
CREATE INDEX dw_contact_patients_entity_ix ON dw_contact_patients (entity_id);
CREATE INDEX dw_contact_patients_birth_gender_ix
    ON dw_contact_patients (birth_gender);
CREATE INDEX dw_contact_patients_ethnicity_ix ON dw_contact_patients (ethnicity);
CREATE INDEX dw_contact_patients_birth_date_ix
    ON dw_contact_patients (birth_date);
CREATE INDEX dw_contact_patients_date_of_death_ix
    ON dw_contact_patients (date_of_death);

CREATE TABLE dw_encounter_patients AS
SELECT
    people.id,
    people.entity_id,            -- Keeping this just in case
    birth_gender_ec.code_description AS birth_gender,            -- code_description?
    ethnicity_ec.code_description AS ethnicity,                -- code_description?
    primary_language_ec.code_description AS primary_language,        -- code_description?
    people.first_name,
    people.middle_name,
    people.last_name,
    upsert_date(people.birth_date) AS birth_date,
    upsert_date(people.date_of_death) AS date_of_death,
    people.first_name_soundex,
    people.last_name_soundex
FROM
    people
    LEFT JOIN external_codes birth_gender_ec
        ON (birth_gender_ec.id = people.birth_gender_id AND birth_gender_ec.deleted_at IS NULL)
    LEFT JOIN external_codes ethnicity_ec
        ON (ethnicity_ec.id = people.ethnicity_id AND ethnicity_ec.deleted_at IS NULL)
    LEFT JOIN external_codes primary_language_ec
        ON (primary_language_ec.id = people.primary_language_id AND primary_language_ec.deleted_at IS NULL)
    INNER JOIN (
        SELECT
            part.primary_entity_id
        FROM
            participations part
            INNER JOIN events
                ON (events.id = part.event_id AND events.deleted_at IS NULL)
        WHERE
            part.type = 'InterestedParty' AND
            events.type = 'EncounterEvent'
        GROUP BY part.primary_entity_id
    ) f
        ON (f.primary_entity_id = people.entity_id)
;

ALTER TABLE dw_encounter_patients
    ADD CONSTRAINT dw_encounter_patients_pkey PRIMARY KEY (id);
CREATE INDEX dw_encounter_patients_entity_ix ON dw_encounter_patients (entity_id);
CREATE INDEX dw_encounter_patients_birth_gender_ix
    ON dw_encounter_patients (birth_gender);
CREATE INDEX dw_encounter_patients_ethnicity_ix ON dw_encounter_patients (ethnicity);
CREATE INDEX dw_encounter_patients_birth_date_ix
    ON dw_encounter_patients (birth_date);
CREATE INDEX dw_encounter_patients_date_of_death_ix
    ON dw_encounter_patients (date_of_death);

CREATE TABLE dw_morbidity_events AS
SELECT
    events.id,
    events.parent_id,               -- Reporting tool might provide a field "was_a_contact" == parent_id IS NOT NULL
    ppl.id AS dw_patients_id,

    ds.id AS disease_id,
    ijpl.name AS investigating_jurisdiction,
    ijpl.id AS investigating_jurisdiction_id,
    jorpl.name AS jurisdiction_of_residence,
    jorpl.id AS jurisdiction_of_residence_id,
    scsi.code_description AS state_case_status_code,     -- code_description?
    lcsi.code_description AS lhd_case_status_code,        -- code_description?
    events."MMWR_week" AS mmwr_week,
    events."MMWR_year" AS mmwr_year,

    events.event_name,
    events.record_number,

    events.age_at_onset AS actual_age_at_onset,
    agetypeec.code_description AS actual_age_type,
    trisano.get_age_in_years(events.age_at_onset, agetypeec.code_description) AS age_in_years,
    ppl.approximate_age_no_birthday AS estimated_age_at_onset,
    est_ec.code_description AS estimated_age_type,
    events.parent_guardian,

    fhec.code_description AS food_handler,
    hcwec.code_description AS healthcare_worker,
    glec.code_description AS group_living,
    dcaec.code_description AS day_care_association,
    pregec.code_description AS pregnant,
    upsert_date(prf.pregnancy_due_date) AS pregnancy_due_date,
    prf.risk_factors AS additional_risk_factors,
    prf.risk_factors_notes AS risk_factor_details,
    prf.occupation,
    events.other_data_1,
    events.other_data_2,
    disevhosp.code_description AS disease_event_hospitalized,    -- code description?

    oaci.code_description AS outbreak_associated_code,    -- code_description?
    events.outbreak_name,

    -- events.event_status,                    -- Change this from a code to a text value?
    COALESCE(inv.first_name || ' ' || inv.last_name, '') AS investigator,
    events.event_queue_id,
    events.acuity,

    pataddr.street_number,
    pataddr.street_name,
    pataddr.unit_number,
    pataddr.city,
    jorec.code_description AS county,
    stateec.code_description AS state,
    pataddr.postal_code,
    pataddr.latitude,
    pataddr.longitude,

    upsert_date(disev.disease_onset_date) AS date_disease_onset,
    upsert_date(disev.date_diagnosed) AS date_disease_diagnosed,
    upsert_date(events.results_reported_to_clinician_date) AS results_reported_to_clinician_date,
    upsert_date(events."first_reported_PH_date") AS date_reported_to_public_health,

    upsert_date(events.event_onset_date) AS date_entered_into_system,
    upsert_date(events.investigation_started_date) AS date_investigation_started,
    upsert_date(events."investigation_completed_LHD_date") AS date_investigation_completed,
    upsert_date(events.review_completed_by_state_date) AS review_completed_by_state_date,

    events.created_at AS date_created,
    events.updated_at AS date_updated,
    events.deleted_at AS date_deleted,

    events.sent_to_cdc,

    partcon_disp_ec.code_description AS disposition_if_once_a_contact,        -- the_code?
    partcon_cont_ec.code_description AS contact_type_if_once_a_contact,        -- the_code?

-- Stuff that didn't show up in Pete's model
    ifi.code_description AS imported_from_code,         -- code_description?
--      events."investigation_LHD_status_id",  Can be ignored, as it's never used
    events.sent_to_ibis,
    events.ibis_updated_at,
    disevdied.code_description AS disease_event_died,        -- code description?

    -- See "Feature Areas -- Public Health Status"
    CASE
        WHEN ijpl.id IS NULL OR ijpl.name = 'Unassigned' THEN 'Unassigned to a Jurisdiction'::TEXT
        WHEN investigator_id IS NULL THEN 'Assigned to a Jurisdiction (not assigned to an investigator)'::TEXT
        WHEN events.investigation_started_date IS NULL THEN 'Assigned to an Investigator'::TEXT
        WHEN events."investigation_completed_LHD_date" IS NULL THEN 'Investigation in process'::TEXT
        ELSE 'Investigation complete'::TEXT
    END AS public_health_status,

    1::integer AS always_one     -- This column joins against the population.population_years view
                                 -- to associate every event with every population year, and keep
                                 -- Mondrian happy
FROM events
    LEFT JOIN participations pplpart
        ON (events.id = pplpart.event_id)
    LEFT JOIN participations_risk_factors prf
        ON (prf.participation_id = pplpart.id)
    LEFT JOIN entities pplent
        ON (pplpart.primary_entity_id = pplent.id AND pplent.deleted_at IS NULL)
    LEFT JOIN people ppl
        ON (ppl.entity_id = pplent.id)
    LEFT JOIN external_codes ifi
        ON (events.imported_from_id = ifi.id)
    LEFT JOIN external_codes scsi
        ON (events.state_case_status_id = scsi.id AND scsi.deleted_at IS NULL)
    LEFT JOIN external_codes oaci
        ON (events.outbreak_associated_id = oaci.id AND oaci.deleted_at IS NULL)
    LEFT JOIN external_codes lcsi
        ON (events.lhd_case_status_id = lcsi.id AND lcsi.deleted_at IS NULL)
    LEFT JOIN users inv
        ON (events.investigator_id = inv.id)
    LEFT JOIN disease_events disev
        ON (events.id = disev.event_id)
    LEFT JOIN diseases ds
        ON (disev.disease_id = ds.id)
    LEFT JOIN external_codes disevhosp
        ON (disevhosp.id = disev.hospitalized_id AND disevhosp.deleted_at IS NULL)
    LEFT JOIN external_codes disevdied
        ON (disevdied.id = disev.died_id AND disevdied.deleted_at IS NULL)
    LEFT JOIN participations pa
        ON (pa.event_id = events.id)
    LEFT JOIN places ijpl
        ON (ijpl.entity_id = pa.secondary_entity_id)
    LEFT JOIN external_codes fhec
        ON (prf.food_handler_id = fhec.id AND fhec.deleted_at IS NULL)
    LEFT JOIN external_codes hcwec
        ON (hcwec.id = prf.healthcare_worker_id AND hcwec.deleted_at IS NULL)
    LEFT JOIN external_codes glec
        ON (glec.id = prf.group_living_id AND glec.deleted_at IS NULL)
    LEFT JOIN external_codes dcaec
        ON (dcaec.id = prf.day_care_association_id AND dcaec.deleted_at IS NULL)
    LEFT JOIN external_codes pregec
        ON (pregec.id = prf.pregnant_id AND pregec.deleted_at IS NULL)
    LEFT JOIN addresses pataddr
        ON (pataddr.event_id = events.id)
    LEFT JOIN external_codes jorec
        ON (jorec.id = pataddr.county_id AND jorec.deleted_at IS NULL)
    LEFT JOIN places jorpl
        ON (jorpl.entity_id = jorec.jurisdiction_id)
    LEFT JOIN external_codes stateec
        ON (stateec.id = pataddr.state_id AND stateec.deleted_at IS NULL)
    LEFT JOIN external_codes agetypeec
        ON (agetypeec.id = events.age_type_id AND agetypeec.deleted_at IS NULL)
    LEFT JOIN external_codes est_ec
        ON (est_ec.id = ppl.age_type_id AND est_ec.deleted_at IS NULL)
    LEFT JOIN participations_contacts partcon
        ON (partcon.id = events.participations_contact_id)
    LEFT JOIN external_codes partcon_disp_ec
        ON (partcon.disposition_id = partcon_disp_ec.id AND partcon_disp_ec.deleted_at IS NULL)
    LEFT JOIN external_codes partcon_cont_ec
        ON (partcon.contact_type_id = partcon_cont_ec.id AND partcon_cont_ec.deleted_at IS NULL)
WHERE
    events.type = 'MorbidityEvent' AND
    events.deleted_at IS NULL AND
    pa.type = 'Jurisdiction' AND
    pplpart.secondary_entity_id IS NULL AND
    pplpart.type = 'InterestedParty'
;

ALTER TABLE dw_morbidity_events
    ADD CONSTRAINT pk_dw_morbidity_events PRIMARY KEY (id);

CREATE INDEX dw_morbidity_events_patient_id ON dw_morbidity_events (dw_patients_id);
CREATE INDEX dw_morbidity_events_investigating_jurisdiction
    ON dw_morbidity_events (investigating_jurisdiction);
CREATE INDEX dw_morbidity_events_jurisdiction_of_residence
    ON dw_morbidity_events (jurisdiction_of_residence);
CREATE INDEX dw_morbidity_events_disease_id_ix
    ON dw_morbidity_events (disease_id);
CREATE INDEX dw_morbidity_events_food_handler_ix
    ON dw_morbidity_events (food_handler);
CREATE INDEX dw_morbidity_events_healthcare_worker_ix
    ON dw_morbidity_events (healthcare_worker);
CREATE INDEX dw_morbidity_events_group_living_ix
    ON dw_morbidity_events (group_living);
CREATE INDEX dw_morbidity_events_day_care_ix
    ON dw_morbidity_events (day_care_association);
CREATE INDEX dw_morbidity_events_pregnant_ix
    ON dw_morbidity_events (pregnant);
CREATE INDEX dw_morbidity_events_date_disease_onset_ix
    ON dw_morbidity_events (date_disease_onset);
CREATE INDEX dw_morbidity_events_date_disease_diagnosed_ix
    ON dw_morbidity_events (date_disease_diagnosed);
CREATE INDEX dw_morbidity_events_results_reported_to_clinician_date_ix
    ON dw_morbidity_events (results_reported_to_clinician_date);
CREATE INDEX dw_morbidity_events_date_reported_to_public_health_ix
    ON dw_morbidity_events (date_reported_to_public_health);
CREATE INDEX dw_morbidity_events_date_entered_into_system_ix
    ON dw_morbidity_events (date_entered_into_system);
CREATE INDEX dw_morbidity_events_date_investigation_started_ix
    ON dw_morbidity_events (date_investigation_started);
CREATE INDEX dw_morbidity_events_date_investigation_completed_ix
    ON dw_morbidity_events (date_investigation_completed);
CREATE INDEX dw_morbidity_events_review_completed_by_state_date_ix
    ON dw_morbidity_events (review_completed_by_state_date);
CREATE INDEX dw_morbidity_events_date_created_ix
    ON dw_morbidity_events (date_created);
CREATE INDEX dw_morbidity_events_parent_id_ix
    ON dw_morbidity_events (parent_id);

CREATE TABLE dw_contact_events AS
SELECT
    events.id,
    events.parent_id,               -- Reporting tool might provide a field "was_a_contact" == parent_id IS NOT NULL
    ppl.id AS dw_patients_id,

    ds.id AS disease_id,
    ijpl.name AS investigating_jurisdiction,
    ijpl.id AS investigating_jurisdiction_id,
    jorpl.name AS jurisdiction_of_residence,
    jorpl.id AS jurisdiction_of_residence_id,

    events.age_at_onset AS actual_age_at_onset,
    agetypeec.code_description AS actual_age_type,
    trisano.get_age_in_years(events.age_at_onset, agetypeec.code_description) AS age_in_years,
    ppl.approximate_age_no_birthday AS estimated_age_at_onset,
    est_ec.code_description AS estimated_age_type,

    fhec.code_description AS food_handler,
    hcwec.code_description AS healthcare_worker,
    glec.code_description AS group_living,
    dcaec.code_description AS day_care_association,
    pregec.code_description AS pregnant,
    prf.pregnancy_due_date,
    prf.risk_factors AS additional_risk_factors,
    prf.risk_factors_notes AS risk_factor_details,
    prf.occupation,
    events.other_data_1,
    events.other_data_2,
    disevhosp.code_description AS disease_event_hospitalized,    -- code description?

    -- events.event_status,                    -- Change this from a code to a text value?
    COALESCE(inv.first_name || ' ' || inv.last_name, '') AS investigator,
    events.event_queue_id,                    -- do something w/ event queues?

    pataddr.street_number,
    pataddr.street_name,
    pataddr.unit_number,
    pataddr.city,
    jorec.code_description AS county,
    stateec.code_description AS state,
    pataddr.postal_code,
    pataddr.latitude,
    pataddr.longitude,

    upsert_date(disev.disease_onset_date) AS date_disease_onset,
    upsert_date(disev.date_diagnosed) AS date_disease_diagnosed,

    upsert_date(events.event_onset_date) AS date_entered_into_system,
    upsert_date(events.investigation_started_date) AS date_investigation_started,
    upsert_date(events."investigation_completed_LHD_date") AS date_investigation_completed,
    upsert_date(events.review_completed_by_state_date) AS review_completed_by_state_date,

    events.created_at AS date_created,
    events.updated_at AS date_updated,
    events.deleted_at AS date_deleted,

    partcon_disp_ec.code_description AS disposition,        -- the_code?
    partcon_cont_ec.code_description AS contact_type,        -- the_code?

-- Stuff that didn't show up in Pete's model
    ifi.code_description AS imported_from_code,         -- code_description?
--      events."investigation_LHD_status_id",  Can be ignored, as it's never used
    events.sent_to_ibis,
    events.ibis_updated_at,
    disevdied.code_description AS disease_event_died,        -- code description?

    -- See "Feature Areas -- Public Health Status"
    CASE
        WHEN ijpl.id IS NULL OR ijpl.name = 'Unassigned' THEN 'Unassigned to a Jurisdiction'::TEXT
        WHEN investigator_id IS NULL THEN 'Assigned to a Jurisdiction (not assigned to an investigator)'::TEXT
        WHEN events.investigation_started_date IS NULL THEN 'Assigned to an Investigator'::TEXT
        WHEN events."investigation_completed_LHD_date" IS NULL THEN 'Investigation in process'::TEXT
        ELSE 'Investigation complete'::TEXT
    END AS public_health_status,

    1::integer AS always_one
FROM events
    LEFT JOIN participations pplpart
        ON (events.id = pplpart.event_id)
    LEFT JOIN participations_risk_factors prf
        ON (prf.participation_id = pplpart.id)
    LEFT JOIN entities pplent
        ON (pplpart.primary_entity_id = pplent.id AND pplent.deleted_at IS NULL)
    LEFT JOIN people ppl
        ON (ppl.entity_id = pplent.id)
    LEFT JOIN external_codes ifi
        ON (events.imported_from_id = ifi.id AND ifi.deleted_at IS NULL)
    LEFT JOIN external_codes scsi
        ON (events.state_case_status_id = scsi.id AND scsi.deleted_at IS NULL)
    LEFT JOIN external_codes oaci
        ON (events.outbreak_associated_id = oaci.id AND oaci.deleted_at IS NULL)
    LEFT JOIN external_codes lcsi
        ON (events.lhd_case_status_id = lcsi.id AND lcsi.deleted_at IS NULL)
    LEFT JOIN users inv
        ON (events.investigator_id = inv.id)
    LEFT JOIN disease_events disev
        ON (events.id = disev.event_id)
    LEFT JOIN diseases ds
        ON (disev.disease_id = ds.id)
    LEFT JOIN external_codes disevhosp
        ON (disevhosp.id = disev.hospitalized_id AND disevhosp.deleted_at IS NULL)
    LEFT JOIN external_codes disevdied
        ON (disevdied.id = disev.died_id AND disevdied.deleted_at IS NULL)
    LEFT JOIN participations pa
        ON (pa.event_id = events.id)
    LEFT JOIN places ijpl
        ON (ijpl.entity_id = pa.secondary_entity_id)
    LEFT JOIN external_codes fhec
        ON (prf.food_handler_id = fhec.id AND fhec.deleted_at IS NULL)
    LEFT JOIN external_codes hcwec
        ON (hcwec.id = prf.healthcare_worker_id AND hcwec.deleted_at IS NULL)
    LEFT JOIN external_codes glec
        ON (glec.id = prf.group_living_id AND glec.deleted_at IS NULL)
    LEFT JOIN external_codes dcaec
        ON (dcaec.id = prf.day_care_association_id AND dcaec.deleted_at IS NULL)
    LEFT JOIN external_codes pregec
        ON (pregec.id = prf.pregnant_id AND pregec.deleted_at IS NULL)
    LEFT JOIN addresses pataddr
        ON (pataddr.event_id = events.id)
    LEFT JOIN external_codes jorec
        ON (jorec.id = pataddr.county_id AND jorec.deleted_at IS NULL)
    LEFT JOIN places jorpl
        ON (jorpl.entity_id = jorec.jurisdiction_id)
    LEFT JOIN external_codes stateec
        ON (stateec.id = pataddr.state_id AND stateec.deleted_at IS NULL)
    LEFT JOIN external_codes agetypeec
        ON (agetypeec.id = events.age_type_id AND agetypeec.deleted_at IS NULL)
    LEFT JOIN external_codes est_ec
        ON (est_ec.id = ppl.age_type_id AND est_ec.deleted_at IS NULL)
    LEFT JOIN participations_contacts partcon
        ON (partcon.id = events.participations_contact_id)
    LEFT JOIN external_codes partcon_disp_ec
        ON (partcon.disposition_id = partcon_disp_ec.id AND partcon_disp_ec.deleted_at IS NULL)
    LEFT JOIN external_codes partcon_cont_ec
        ON (partcon.contact_type_id = partcon_cont_ec.id AND partcon_cont_ec.deleted_at IS NULL)
WHERE
    events.type = 'ContactEvent' AND
    events.deleted_at IS NULL AND
    pa.type = 'Jurisdiction' AND
    pplpart.secondary_entity_id IS NULL AND
    pplpart.type = 'InterestedParty'
;

ALTER TABLE dw_contact_events
    ADD CONSTRAINT pk_dw_contact_events PRIMARY KEY (id);
CREATE INDEX dw_contact_events_patient_id ON dw_contact_events (dw_patients_id);
CREATE INDEX dw_contact_events_parent_id ON dw_contact_events (parent_id);
CREATE INDEX dw_contact_events_disease_id_ix
    ON dw_contact_events (disease_id);
CREATE INDEX dw_contact_events_food_handler_ix
    ON dw_contact_events (food_handler);
CREATE INDEX dw_contact_events_healthcare_worker_ix
    ON dw_contact_events (healthcare_worker);
CREATE INDEX dw_contact_events_group_living_ix
    ON dw_contact_events (group_living);
CREATE INDEX dw_contact_events_day_care_ix
    ON dw_contact_events (day_care_association);
CREATE INDEX dw_contact_events_pregnant_ix
    ON dw_contact_events (pregnant);
CREATE INDEX dw_contact_events_date_disease_onset_ix
    ON dw_contact_events (date_disease_onset);
CREATE INDEX dw_contact_events_date_disease_diagnosed_ix
    ON dw_contact_events (date_disease_diagnosed);
CREATE INDEX dw_contact_events_date_entered_into_system_ix
    ON dw_contact_events (date_entered_into_system);
CREATE INDEX dw_contact_events_date_investigation_started_ix
    ON dw_contact_events (date_investigation_started);
CREATE INDEX dw_contact_events_date_investigation_completed_ix
    ON dw_contact_events (date_investigation_completed);
CREATE INDEX dw_contact_events_review_completed_by_state_date_ix
    ON dw_contact_events (review_completed_by_state_date);
CREATE INDEX dw_contact_events_date_created_ix
    ON dw_contact_events (date_created);
CREATE INDEX dw_contact_events_parent_id_ix
    ON dw_contact_events (parent_id);

CREATE TABLE dw_secondary_jurisdictions AS
SELECT
    events.id,
    CASE
        WHEN events.type = 'MorbidityEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_morbidity_events_id,
    CASE
        WHEN events.type = 'ContactEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_contact_events_id,
    pl.id AS jurisdiction_id,
    pl.name
FROM
    events
    LEFT JOIN participations pr
        ON (pr.event_id = events.id)
    LEFT JOIN places pl
        ON (pl.entity_id = pr.secondary_entity_id)
WHERE
    pr.type = 'AssociatedJurisdiction' AND
    events.deleted_at IS NULL AND
    (
        events.type = 'ContactEvent' OR
        events.type = 'MorbidityEvent'
    )
;

ALTER TABLE dw_secondary_jurisdictions
    ADD CONSTRAINT dw_secondary_jurisdictions_pkey PRIMARY KEY (id, jurisdiction_id);
CREATE INDEX dw_secondary_jurisdictions_morbidity_id_ix
    ON dw_secondary_jurisdictions (dw_morbidity_events_id);
CREATE INDEX dw_secondary_jurisdictions_contact_id_ix
    ON dw_secondary_jurisdictions (dw_contact_events_id);
CREATE INDEX dw_secondary_jurisdictions_jurisdiction_id_ix
    ON dw_secondary_jurisdictions (jurisdiction_id);

CREATE TABLE dw_events_hospitals AS
SELECT
    hpart.id AS id,
    CASE
        WHEN events.type = 'MorbidityEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_morbidity_events_id,
    CASE
        WHEN events.type = 'ContactEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_contact_events_id,
    pl.name AS hospital_name,
    upsert_date(hpart.admission_date) AS admission_date,
    upsert_date(hpart.discharge_date) AS discharge_date,
    hpart.medical_record_number,
    hpart.hospital_record_number
FROM
    events
    JOIN participations p
        ON (p.event_id = events.id)
    JOIN places pl
        ON (pl.entity_id = p.secondary_entity_id)
    JOIN hospitals_participations hpart
        ON (hpart.participation_id = p.id)
WHERE
    p.type = 'HospitalizationFacility' AND
    events.deleted_at IS NULL
;

ALTER TABLE dw_events_hospitals
    ADD CONSTRAINT pk_dw_events_hospitals PRIMARY KEY (id);
CREATE INDEX dw_events_hospitals_morbidity_event_id_ix
    ON dw_events_hospitals (dw_morbidity_events_id);
CREATE INDEX dw_events_hospitals_contact_event_id_ix
    ON dw_events_hospitals (dw_contact_events_id);
CREATE INDEX dw_events_hospitals_admission_date_ix
    ON dw_events_hospitals (admission_date);
CREATE INDEX dw_events_hospitals_discharge_date_ix
    ON dw_events_hospitals (discharge_date);

CREATE TABLE dw_lab_results AS
SELECT
    lr.id,
    CASE
        WHEN events.type = 'MorbidityEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_morbidity_events_id,
    CASE
        WHEN events.type = 'ContactEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_contact_events_id,
    CASE
        WHEN events.type = 'EncounterEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_encounter_events_id,
    ssec.code_description AS specimen_source,
    upsert_date(lr.collection_date) AS collection_date,
    upsert_date(lr.lab_test_date) AS lab_test_date,
    uphlec.code_description AS specimen_sent_to_state,
    lr.reference_range,
    lr.loinc_code,
    ctt.common_name AS test_type,
    trec.code_description AS test_result,
    lr.result_value,
    lr.units,
    tsec.code_description AS test_status,
    lr.comment,
    places.name,
    c.code_description AS lab_type,
    sm.hl7_message,
    sm.state AS staged_message_state,
    sm.note AS staged_message_note
FROM
    lab_results lr
    LEFT JOIN staged_messages sm
        ON (sm.id = lr.staged_message_id)
    LEFT JOIN external_codes tsec
        ON (tsec.id = lr.test_status_id AND tsec.deleted_at IS NULL)
    LEFT JOIN external_codes trec
        ON (trec.id = lr.test_result_id AND trec.deleted_at IS NULL)
    LEFT JOIN common_test_types ctt
        ON (ctt.id = lr.test_type_id)
    LEFT JOIN external_codes ssec
        ON (ssec.id = lr.specimen_source_id AND ssec.deleted_at IS NULL)
    LEFT JOIN external_codes uphlec
        ON (uphlec.id = lr.specimen_sent_to_state_id AND uphlec.deleted_at IS NULL)
    LEFT JOIN participations p
        ON (p.id = lr.participation_id)
    LEFT JOIN events
        ON (p.event_id = events.id AND events.deleted_at IS NULL)
    LEFT JOIN places
        ON (places.entity_id = p.secondary_entity_id)
    LEFT JOIN places_types pt
        ON (pt.place_id = places.id)
    LEFT JOIN codes c
        ON (c.id = pt.type_id AND c.deleted_at IS NULL)
;

--ALTER TABLE dw_lab_results
    --ADD CONSTRAINT pk_dw_lab_results PRIMARY KEY (id, lab_type);
CREATE INDEX dw_lab_results_morbidity_id_ix
    ON dw_lab_results (dw_morbidity_events_id);
CREATE INDEX dw_lab_results_contact_id_ix
    ON dw_lab_results (dw_contact_events_id);

CREATE SEQUENCE dw_patients_races_seq;

CREATE TABLE dw_patients_races AS
SELECT
    NEXTVAL('dw_patients_races_seq') AS id,
    ex.code_description AS race,
    p.id AS person_id
FROM
    people_races pr
    LEFT JOIN external_codes ex
        ON (pr.race_id = ex.id AND ex.deleted_at IS NULL)
    LEFT JOIN people p
        ON (p.entity_id = pr.entity_id)
;

ALTER TABLE dw_patients_races
    ADD CONSTRAINT pk_dw_patients_races PRIMARY KEY (id);
CREATE INDEX dw_patients_races_patient_id ON dw_patients_races (person_id);
CREATE INDEX dw_patients_races_race_ix ON dw_patients_races (race);

CREATE TABLE dw_events_treatments AS
SELECT
    pt.id,
    CASE
        WHEN events.type = 'MorbidityEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_morbidity_events_id,
    CASE
        WHEN events.type = 'ContactEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_contact_events_id,
    CASE
        WHEN events.type = 'EncounterEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_encounter_events_id,
    pt.treatment_id,
    tgec.code_description AS treatment_given,
    upsert_date(pt.treatment_date) AS date_of_treatment,
    pt.treatment AS treatment_notes
FROM
    participations_treatments pt
    LEFT JOIN participations p
        ON (p.id = pt.participation_id)
    LEFT JOIN events
        ON (events.id = p.event_id AND events.deleted_at IS NULL)
    LEFT JOIN external_codes tgec
        ON (tgec.id = pt.treatment_given_yn_id AND tgec.deleted_at IS NULL)
;

ALTER TABLE dw_events_treatments
    ADD CONSTRAINT pk_dw_events_treatments PRIMARY KEY (id);
CREATE INDEX dw_events_treatments_morbidity_id_ix
    ON dw_events_treatments (dw_morbidity_events_id);
CREATE INDEX dw_events_treatments_contact_id_ix
    ON dw_events_treatments (dw_contact_events_id);
CREATE INDEX dw_events_treatments_encounter_id_ix
    ON dw_events_treatments (dw_encounter_events_id);
CREATE INDEX dw_events_treatments_date_of_treatment_ix
    ON dw_events_treatments (date_of_treatment);

CREATE TABLE dw_morbidity_clinicians AS
SELECT
    p.id AS id,
    events.id AS dw_morbidity_events_id,
    pl.first_name,
    pl.last_name,
    pl.middle_name
FROM
    events
    JOIN participations p
        ON (p.event_id = events.id AND events.type = 'MorbidityEvent')
    JOIN people pl
        ON (pl.entity_id = p.secondary_entity_id)
WHERE
    p.type = 'Clinician' AND
    events.deleted_at IS NULL
;

ALTER TABLE dw_morbidity_clinicians
    ADD CONSTRAINT dw_morbidity_clinicians_pkey PRIMARY KEY (id);
CREATE INDEX dw_morbidity_clinicians_event_id_ix
    ON dw_morbidity_clinicians (dw_morbidity_events_id);

CREATE TABLE dw_contact_clinicians AS
SELECT
    p.id AS id,
    events.id AS dw_contact_events_id,
    pl.first_name,
    pl.last_name,
    pl.middle_name
FROM
    events
    JOIN participations p
        ON (p.event_id = events.id AND events.type = 'ContactEvent')
    JOIN people pl
        ON (pl.entity_id = p.secondary_entity_id)
WHERE
    p.type = 'Clinician' AND
    events.deleted_at IS NULL
;

ALTER TABLE dw_contact_clinicians
    ADD CONSTRAINT dw_contact_clinicians_pkey PRIMARY KEY (id);
CREATE INDEX dw_contact_clinicians_event_id_ix
    ON dw_contact_clinicians (dw_contact_events_id);

CREATE SEQUENCE dw_events_diagnostic_facilities_id_seq;

CREATE TABLE dw_events_diagnostic_facilities AS
SELECT
    nextval('dw_events_diagnostic_facilities_id_seq') AS id,
    CASE
        WHEN events.type = 'MorbidityEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_morbidity_events_id,
    CASE
        WHEN events.type = 'ContactEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_contact_events_id,
    pl.name AS name,
    c.code_description AS place_type,
    pl.id AS place_id
FROM
    events
    JOIN participations p
        ON (p.event_id = events.id)
    JOIN places pl
        ON (pl.entity_id = p.secondary_entity_id)
    JOIN places_types pt
        ON (pt.place_id = pl.id)
    JOIN codes c
        ON (c.id = pt.type_id AND c.deleted_at IS NULL)
WHERE
    p.type = 'DiagnosticFacility' AND
    events.deleted_at IS NULL
;

ALTER TABLE dw_events_diagnostic_facilities
    ADD CONSTRAINT pk_dw_events_diagnostic_facilities PRIMARY KEY (id);
CREATE INDEX dw_events_diag_fac_morbidity_event_ix
    ON dw_events_diagnostic_facilities (dw_morbidity_events_id);
CREATE INDEX dw_events_diag_fac_contact_event_ix
    ON dw_events_diagnostic_facilities (dw_contact_events_id);
CREATE INDEX dw_events_diag_fac_place_id_ix
    ON dw_events_diagnostic_facilities (place_id);

CREATE SEQUENCE dw_events_reporting_agencies_id_seq;

CREATE TABLE dw_events_reporting_agencies AS
SELECT
    nextval('dw_events_reporting_agencies_id_seq') AS id,
    CASE
        WHEN events.type = 'MorbidityEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_morbidity_events_id,
    CASE
        WHEN events.type = 'ContactEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_contact_events_id,
    pl.name AS name,
    c.code_description AS place_type,
    pl.id AS place_id
FROM
    events
    JOIN participations p
        ON (p.event_id = events.id)
    JOIN places pl
        ON (pl.entity_id = p.secondary_entity_id)
    JOIN places_types pt
        ON (pt.place_id = pl.id)
    JOIN codes c
        ON (c.id = pt.type_id AND c.deleted_at IS NULL)
WHERE
    p.type = 'ReportingAgency' AND
    events.deleted_at IS NULL
;

ALTER TABLE dw_events_reporting_agencies
    ADD CONSTRAINT pk_dw_events_reporting_agencies PRIMARY KEY (id);
CREATE INDEX dw_events_rep_agen_morbidity_event_ix
    ON dw_events_reporting_agencies (dw_morbidity_events_id);
CREATE INDEX dw_events_rep_agen_contact_event_ix
    ON dw_events_reporting_agencies (dw_contact_events_id);
CREATE INDEX dw_events_reporting_agencies_place_ix
    ON dw_events_reporting_agencies (place_id);

CREATE TABLE dw_events_reporters AS
SELECT
    p.id AS id,
    CASE
        WHEN events.type = 'MorbidityEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_morbidity_events_id,
    CASE
        WHEN events.type = 'ContactEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_contact_events_id,
    pl.first_name,
    pl.last_name,
    pl.middle_name
FROM
    events
    JOIN participations p
        ON (p.event_id = events.id)
    JOIN people pl
        ON (pl.entity_id = p.secondary_entity_id)
WHERE
    p.type = 'Reporter' AND
    events.deleted_at IS NULL
;

ALTER TABLE dw_events_reporters
    ADD CONSTRAINT pk_dw_events_reporters PRIMARY KEY (id);
CREATE INDEX dw_events_reporters_morbidity_event_ix
    ON dw_events_reporters (dw_morbidity_events_id);
CREATE INDEX dw_events_reporters_contact_event_ix
    ON dw_events_reporters (dw_contact_events_id);

CREATE TABLE dw_place_events AS
SELECT
    events.id,
    events.parent_id AS dw_morbidity_events_id,
    p.name,
    c.code_description AS place_type,
    ad.street_number,
    ad.street_name,
    ad.unit_number,
    ad.city,
    state_ec.code_description AS state,
    county_ec.code_description AS county,
    ad.postal_code,
    ad.latitude,
    ad.longitude
FROM
    events
    LEFT JOIN addresses ad
        ON (ad.event_id = events.id)
    LEFT JOIN external_codes state_ec
        ON (state_ec.id = ad.state_id AND state_ec.deleted_at IS NULL)
    LEFT JOIN external_codes county_ec
        ON (county_ec.id = ad.county_id AND county_ec.deleted_at IS NULL)
    JOIN participations part
        ON (part.event_id = events.id AND part.type = 'InterestedPlace')
    JOIN places p
        ON (p.entity_id = part.primary_entity_id)
    LEFT JOIN places_types pt
        ON (pt.place_id = p.id)
    LEFT JOIN codes c
        ON (c.id = pt.type_id AND c.deleted_at IS NULL)
WHERE
    events.type = 'PlaceEvent' AND
    events.deleted_at IS NULL
;

ALTER TABLE dw_place_events
    ADD CONSTRAINT pk_dw_place_events PRIMARY KEY (id);
CREATE INDEX dw_place_events_parent ON dw_place_events (dw_morbidity_events_id);

CREATE TABLE dw_encounters AS
SELECT
    events.id,
    events.parent_id AS dw_morbidity_events_id,
    events.id AS encounter_event_id,
    u.first_name || ' ' || u.last_name AS investigator_id,
    upsert_date(pe.encounter_date) AS encounter_date,
    pe.encounter_location_type AS location,
    pe.description
FROM
    participations_encounters pe
    JOIN events
        ON (events.participations_encounter_id = pe.id AND events.deleted_at IS NULL)
    JOIN users u
        ON (pe.user_id = u.id)
;

ALTER TABLE dw_encounters
    ADD CONSTRAINT pk_dw_encounters PRIMARY KEY (id);
CREATE INDEX dw_encounters_parent ON dw_encounters (dw_morbidity_events_id);
CREATE INDEX dw_encounters_event_id_ix ON dw_encounters (encounter_event_id);
CREATE INDEX dw_encounters_investigator_id_ix ON dw_encounters (investigator_id);
CREATE INDEX dw_encounters_encounter_date_ix ON dw_encounters (encounter_date);
CREATE INDEX dw_encounters_location_ix ON dw_encounters (location);

-- CREATE TABLE dw_encounters_labs AS
-- SELECT
--     p.id,
--     events.id AS dw_encounters_id,
--     lr.id AS dw_lab_results_id
-- FROM
--     lab_results lr
--     JOIN participations p
--         ON (p.id = lr.participation_id)
--     JOIN events
--         ON (events.id = p.event_id)
-- WHERE
--     events.type = 'EncounterEvent'
-- ;
-- 
-- ALTER TABLE dw_encounters_labs
--     ADD CONSTRAINT pk_dw_encounters_labs PRIMARY KEY (id);
-- CREATE INDEX dw_encounters_labs_encounter_id_ix
--     ON dw_encounters_labs (dw_encounters_id);
-- CREATE INDEX dw_encounters_labs_results_ix
--     ON dw_encounters_labs (dw_lab_results_id);

-- TODO: is this table useful?
CREATE TABLE dw_encounters_treatments AS
SELECT
    pt.id,
    events.id AS dw_encounters_id,
    pt.id AS dw_events_treatments_id
FROM
    participations_treatments pt
    LEFT JOIN participations p
        ON (p.id = pt.participation_id)
    LEFT JOIN events
        ON (events.id = p.event_id AND events.deleted_at IS NULL)
WHERE
    events.type = 'EncounterEvent'
;

ALTER TABLE dw_encounters_treatments
    ADD CONSTRAINT pk_dw_encounters_treatments PRIMARY KEY (id);
CREATE INDEX dw_encounters_treatments_encounter_ix
    ON dw_encounters_treatments (dw_encounters_id);
CREATE INDEX dw_enc_treat_events_treatments_id_ix
    ON dw_encounters_treatments (dw_events_treatments_id);

CREATE TABLE dw_morbidity_questions AS
SELECT
    q.*
FROM
    questions q
    INNER JOIN (
        SELECT
            DISTINCT questions.id
        FROM
            questions
            INNER JOIN answers a
                ON (a.question_id = questions.id)
            INNER JOIN events e
                ON (a.event_id = e.id AND e.type = 'MorbidityEvent' AND e.deleted_at IS NULL)
    ) f
        ON (f.id = q.id)
;

ALTER TABLE dw_morbidity_questions
    ADD CONSTRAINT dw_morbidity_questions_pkey PRIMARY KEY (id);
CREATE INDEX dw_morbidity_questions_form_element_ix
    ON dw_morbidity_questions (form_element_id);

CREATE TABLE dw_contact_questions AS
SELECT
    q.*
FROM
    questions q
    INNER JOIN (
        SELECT
            DISTINCT questions.id
        FROM
            questions
            INNER JOIN answers a
                ON (a.question_id = questions.id)
            INNER JOIN events e
                ON (a.event_id = e.id AND e.type = 'ContactEvent' AND e.deleted_at IS NULL)
    ) f
        ON (f.id = q.id)
;

ALTER TABLE dw_contact_questions
    ADD CONSTRAINT dw_contact_questions_pkey PRIMARY KEY (id);
CREATE INDEX dw_contact_questions_form_element_ix
    ON dw_contact_questions (form_element_id);

CREATE TABLE dw_encounter_questions AS
SELECT
    q.*
FROM
    questions q
    INNER JOIN (
        SELECT
            DISTINCT questions.id
        FROM
            questions
            INNER JOIN answers a
                ON (a.question_id = questions.id)
            INNER JOIN events e
                ON (a.event_id = e.id AND e.type = 'EncounterEvent' AND e.deleted_at IS NULL)
    ) f
        ON (f.id = q.id)
;

ALTER TABLE dw_encounter_questions
    ADD CONSTRAINT dw_encounter_questions_pkey PRIMARY KEY (id);
CREATE INDEX dw_encounter_questions_form_element_ix
    ON dw_encounter_questions (form_element_id);

CREATE TABLE dw_place_questions AS
SELECT
    q.*
FROM
    questions q
    INNER JOIN (
        SELECT
            DISTINCT questions.id
        FROM
            questions
            INNER JOIN answers a
                ON (a.question_id = questions.id)
            INNER JOIN events e
                ON (a.event_id = e.id AND e.type = 'PlaceEvent' AND e.deleted_at IS NULL)
    ) f
        ON (f.id = q.id)
;

ALTER TABLE dw_place_questions
    ADD CONSTRAINT dw_place_questions_pkey PRIMARY KEY (id);
CREATE INDEX dw_place_questions_form_element_ix
    ON dw_place_questions (form_element_id);

CREATE TABLE dw_morbidity_answers AS
SELECT
    a.*
FROM
    answers a
    INNER JOIN events e
        ON (e.id = a.event_id AND e.deleted_at IS NULL)
WHERE
    e.type = 'MorbidityEvent'
;

ALTER TABLE dw_morbidity_answers
    ADD CONSTRAINT dw_morbidity_answers_pkey PRIMARY KEY (id);
CREATE INDEX dw_morbidity_answers_event_id
    ON dw_morbidity_answers (event_id);
CREATE INDEX dw_morbidity_answers_question_id
    ON dw_morbidity_answers (question_id);

CREATE TABLE dw_contact_answers AS
SELECT
    a.*
FROM
    answers a
    INNER JOIN events e
        ON (e.id = a.event_id AND e.deleted_at IS NULL)
WHERE
    e.type = 'ContactEvent'
;

ALTER TABLE dw_contact_answers
    ADD CONSTRAINT dw_contact_answers_pkey PRIMARY KEY (id);
CREATE INDEX dw_contact_answers_event_id
    ON dw_contact_answers (event_id);
CREATE INDEX dw_contact_answers_question_id
    ON dw_contact_answers (question_id);

CREATE TABLE dw_encounter_answers AS
SELECT
    a.*
FROM
    answers a
    INNER JOIN events e
        ON (e.id = a.event_id AND e.deleted_at IS NULL)
WHERE
    e.type = 'EncounterEvent'
;

ALTER TABLE dw_encounter_answers
    ADD CONSTRAINT dw_encounter_answers_pkey PRIMARY KEY (id);
CREATE INDEX dw_encounter_answers_event_id
    ON dw_encounter_answers (event_id);
CREATE INDEX dw_encounter_answers_question_id
    ON dw_encounter_answers (question_id);

CREATE TABLE dw_place_answers AS
SELECT
    a.*
FROM
    answers a
    INNER JOIN events e
        ON (e.id = a.event_id AND e.deleted_at IS NULL)
WHERE
    e.type = 'PlaceEvent'
;

ALTER TABLE dw_place_answers
    ADD CONSTRAINT dw_place_answers_pkey PRIMARY KEY (id);
CREATE INDEX dw_place_answers_event_id
    ON dw_place_answers (event_id);
CREATE INDEX dw_place_answers_question_id
    ON dw_place_answers (question_id);

CREATE TABLE dw_morbidity_diseases AS
SELECT
    d.*
FROM
    diseases d
    INNER JOIN (
        SELECT
            DISTINCT diseases.id
        FROM
            diseases
            INNER JOIN dw_morbidity_events dme
                ON (dme.disease_id = diseases.id)
    ) f
        ON (f.id = d.id)
;

ALTER TABLE dw_morbidity_diseases
    ADD CONSTRAINT dw_morbidity_diseases_pkey PRIMARY KEY (id);

CREATE TABLE dw_contact_diseases AS
SELECT
    d.*
FROM
    diseases d
    INNER JOIN (
        SELECT
            DISTINCT diseases.id
        FROM
            diseases
            INNER JOIN dw_contact_events dme
                ON (dme.disease_id = diseases.id)
    ) f
        ON (f.id = d.id)
;

ALTER TABLE dw_contact_diseases
    ADD CONSTRAINT dw_contact_diseases_pkey PRIMARY KEY (id);

ANALYZE;

TRUNCATE trisano.etl_success;
INSERT INTO trisano.etl_success (success) VALUES (TRUE);


COMMIT;
