-- This script creates new denormalized tables from a freshly dumped OLTP
-- database, using a schema called "staging".

BEGIN;
    DROP SCHEMA IF EXISTS staging;
    ALTER SCHEMA public RENAME TO staging;
    CREATE SCHEMA public;
COMMIT;

BEGIN;

SET search_path = staging, public;

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
        'dw_place_events',
        'dw_patients',
        'dw_events_hospitals',
        'dw_addresses',				-- Consider altering the table instead of creating a new one
        'dw_email_addresses',			-- Consider altering the table instead of creating a new one
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
        'dw_encounters_treatments'
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
        'dw_patients_races_seq'
    ) AND
    n.nspname = 'public' ;
COMMIT;

BEGIN;
CREATE TABLE dw_patients AS			-- "patient" may well be the wrong name for it
SELECT
	people.id,
	people.entity_id,			-- Keeping this just in case
--	race_ec.code_description AS race,					-- code_description?
	birth_gender_ec.code_description AS birth_gender,			-- code_description?
--	current_gender_ec.code_description AS current_gender,			-- code_description?
	ethnicity_ec.code_description AS ethnicity,				-- code_description?
	primary_language_ec.code_description AS primary_language,		-- code_description?
	people.first_name,
	people.middle_name,
	people.last_name,
	people.birth_date,
	people.date_of_death,
--	food_handler_ec.code_description AS food_handler,			-- code_description?
--	healthcare_worker_ec.code_description AS healthcare_worker,		-- code_description?
--	group_living_ec.code_description AS group_living,			-- code_description?
--	day_care_association_ec.code_description AS day_care_association,	-- code_description?
--	age_type_ec.code_description AS age_type,				-- code_description?
--	people.risk_factors,
--	people.risk_factors_notes,
--	people.approximate_age_no_birthday,
	people.first_name_soundex,
	people.last_name_soundex
FROM
	people
	LEFT JOIN external_codes birth_gender_ec
		ON (birth_gender_ec.id = people.age_type_id)
	LEFT JOIN external_codes ethnicity_ec
		ON (ethnicity_ec.id = people.age_type_id)
	LEFT JOIN external_codes primary_language_ec
		ON (primary_language_ec.id = people.age_type_id)
WHERE
	EXISTS (
		SELECT 1
		FROM participations part
		WHERE 
			part.type = 'InterestedParty' AND
			part.primary_entity_id = people.entity_id
	)
;


CREATE TABLE dw_morbidity_events AS
SELECT
	events.id,
	events.parent_id,               -- Reporting tool might provide a field "was_a_contact" == parent_id IS NOT NULL
	ppl.id AS dw_patients_id,

	ds.id AS disease_id,
	ijpl.name AS investigating_jurisdiction,
    jorpl.name AS jurisdiction_of_residence,
	scsi.code_description AS state_case_status_code, 	-- code_description?
	lcsi.code_description AS lhd_case_status_code,		-- code_description?
	events."MMWR_week",
	events."MMWR_year",

	events.event_name,
	events.record_number,

    events.age_at_onset AS actual_age_at_onset,
	agetypeec.code_description AS actual_age_type,
    ppl.approximate_age_no_birthday AS estimated_age_at_onset,
    est_ec.code_description AS estimated_age_type,
	events.parent_guardian,

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
	disevhosp.code_description AS disease_event_hospitalized,	-- code description?

	oaci.code_description AS outbreak_associated_code,	-- code_description?
	events.outbreak_name,

	-- events.event_status,					-- Change this from a code to a text value?
	inv.first_name || ' ' || inv.last_name AS investigator,
	events.event_queue_id,
	events.acuity,

    pataddr.street_number,
    pataddr.street_name,
    pataddr.unit_number,
    pataddr.city,
    jorec.code_description AS county,
    stateec.code_description AS state,
    pataddr.postal_code,

	disev.disease_onset_date AS date_disease_onset,
	disev.date_diagnosed AS date_disease_diagnosed,
	events.results_reported_to_clinician_date,
	events."first_reported_PH_date" AS date_reported_to_public_health,

	events.event_onset_date AS date_entered_into_system,
	events.investigation_started_date AS date_investigation_started,
	events."investigation_completed_LHD_date" AS date_investigation_completed,
	events.review_completed_by_state_date,

	events.created_at AS date_created,
	events.updated_at AS date_updated,
	events.deleted_at AS date_deleted,

	events.sent_to_cdc,

	partcon_disp_ec.code_description AS disposition_if_once_a_contact,		-- the_code?
	partcon_cont_ec.code_description AS contact_type_if_once_a_contact,		-- the_code?

-- Stuff that didn't show up in Pete's model
	ifi.code_description AS imported_from_code, 		-- code_description? 
--  	events."investigation_LHD_status_id",  Can be ignored, as it's never used
	events.sent_to_ibis,
	events.ibis_updated_at,
	disevdied.code_description AS disease_event_died		-- code description?
FROM events
	LEFT JOIN participations pplpart
		ON (events.id = pplpart.event_id)
    LEFT JOIN participations_risk_factors prf
        ON (prf.participation_id = pplpart.id)
	LEFT JOIN entities pplent
		ON (pplpart.primary_entity_id = pplent.id)
	LEFT JOIN people ppl
		ON (ppl.entity_id = pplent.id)
	LEFT JOIN external_codes ifi
		ON (events.imported_from_id = ifi.id)
	LEFT JOIN external_codes scsi
		ON (events.state_case_status_id = scsi.id)
	LEFT JOIN external_codes oaci
		ON (events.outbreak_associated_id = oaci.id)
	LEFT JOIN external_codes lcsi
		ON (events.lhd_case_status_id = lcsi.id)
	LEFT JOIN users inv
		ON (events.investigator_id = inv.id)
	LEFT JOIN disease_events disev
		ON (events.id = disev.event_id)
	LEFT JOIN diseases ds
		ON (disev.disease_id = ds.id)
	LEFT JOIN external_codes disevhosp
		ON (disevhosp.id = disev.hospitalized_id)
	LEFT JOIN external_codes disevdied
		ON (disevdied.id = disev.died_id)
	LEFT JOIN participations pa
		ON (pa.event_id = events.id)
	LEFT JOIN places ijpl
		ON (ijpl.entity_id = pa.secondary_entity_id)
    LEFT JOIN external_codes fhec
        ON (prf.food_handler_id = fhec.id)
    LEFT JOIN external_codes hcwec
        ON (hcwec.id = prf.healthcare_worker_id)
    LEFT JOIN external_codes glec
        ON (glec.id = prf.group_living_id)
    LEFT JOIN external_codes dcaec
        ON (dcaec.id = prf.day_care_association_id)
    LEFT JOIN external_codes pregec
        ON (pregec.id = prf.pregnant_id)
    LEFT JOIN addresses pataddr
        ON (pataddr.event_id = events.id)
    LEFT JOIN external_codes jorec
        ON (jorec.id = pataddr.county_id)
    LEFT JOIN places jorpl
        ON (jorpl.entity_id = jorec.jurisdiction_id)
    LEFT JOIN external_codes stateec
        ON (stateec.id = pataddr.state_id)
    LEFT JOIN external_codes agetypeec
        ON (agetypeec.id = events.age_type_id)
    LEFT JOIN external_codes est_ec
        ON (est_ec.id = ppl.age_type_id)
	LEFT JOIN participations_contacts partcon
		ON (partcon.id = events.participations_contact_id)
	LEFT JOIN external_codes partcon_disp_ec
		ON (partcon.disposition_id = partcon_disp_ec.id)
	LEFT JOIN external_codes partcon_cont_ec
		ON (partcon.contact_type_id = partcon_cont_ec.id)
WHERE
	events.type = 'MorbidityEvent' AND
	pa.type = 'Jurisdiction' AND
	pplpart.secondary_entity_id IS NULL AND
	pplpart.type = 'InterestedParty'
;

CREATE TABLE dw_contact_events AS
SELECT
	events.id,
	events.parent_id,               -- Reporting tool might provide a field "was_a_contact" == parent_id IS NOT NULL
	ppl.id AS dw_patients_id,

	ds.id AS disease_id,
	ijpl.name AS investigating_jurisdiction,
    jorpl.name AS jurisdiction_of_residence,

    events.age_at_onset AS actual_age_at_onset,
	agetypeec.code_description AS actual_age_type,
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
	disevhosp.code_description AS disease_event_hospitalized,	-- code description?

	-- events.event_status,					-- Change this from a code to a text value?
	inv.first_name || ' ' || inv.last_name AS investigator,
	events.event_queue_id,					-- do something w/ event queues?

    pataddr.street_number,
    pataddr.street_name,
    pataddr.unit_number,
    pataddr.city,
    jorec.code_description AS county,
    stateec.code_description AS state,
    pataddr.postal_code,

	disev.disease_onset_date AS date_disease_onset,
	disev.date_diagnosed AS date_disease_diagnosed,

	events.event_onset_date AS date_entered_into_system,
	events.investigation_started_date AS date_investigation_started,
	events."investigation_completed_LHD_date" AS date_investigation_completed,
	events.review_completed_by_state_date,

	events.created_at AS date_created,
	events.updated_at AS date_updated,
	events.deleted_at AS date_deleted,

	partcon_disp_ec.code_description AS disposition,		-- the_code?
	partcon_cont_ec.code_description AS contact_type,		-- the_code?

-- Stuff that didn't show up in Pete's model
	ifi.code_description AS imported_from_code, 		-- code_description? 
--  	events."investigation_LHD_status_id",  Can be ignored, as it's never used
	events.sent_to_ibis,
	events.ibis_updated_at,
	disevdied.code_description AS disease_event_died		-- code description?
FROM events
	LEFT JOIN participations pplpart
		ON (events.id = pplpart.event_id)
    LEFT JOIN participations_risk_factors prf
        ON (prf.participation_id = pplpart.id)
	LEFT JOIN entities pplent
		ON (pplpart.primary_entity_id = pplent.id)
	LEFT JOIN people ppl
		ON (ppl.entity_id = pplent.id)
	LEFT JOIN external_codes ifi
		ON (events.imported_from_id = ifi.id)
	LEFT JOIN external_codes scsi
		ON (events.state_case_status_id = scsi.id)
	LEFT JOIN external_codes oaci
		ON (events.outbreak_associated_id = oaci.id)
	LEFT JOIN external_codes lcsi
		ON (events.lhd_case_status_id = lcsi.id)
	LEFT JOIN users inv
		ON (events.investigator_id = inv.id)
	LEFT JOIN disease_events disev
		ON (events.id = disev.event_id)
	LEFT JOIN diseases ds
		ON (disev.disease_id = ds.id)
	LEFT JOIN external_codes disevhosp
		ON (disevhosp.id = disev.hospitalized_id)
	LEFT JOIN external_codes disevdied
		ON (disevdied.id = disev.died_id)
	LEFT JOIN participations pa
		ON (pa.event_id = events.id)
	LEFT JOIN places ijpl
		ON (ijpl.entity_id = pa.secondary_entity_id)
    LEFT JOIN external_codes fhec
        ON (prf.food_handler_id = fhec.id)
    LEFT JOIN external_codes hcwec
        ON (hcwec.id = prf.healthcare_worker_id)
    LEFT JOIN external_codes glec
        ON (glec.id = prf.group_living_id)
    LEFT JOIN external_codes dcaec
        ON (dcaec.id = prf.day_care_association_id)
    LEFT JOIN external_codes pregec
        ON (pregec.id = prf.pregnant_id)
    LEFT JOIN addresses pataddr
        ON (pataddr.event_id = events.id)
    LEFT JOIN external_codes jorec
        ON (jorec.id = pataddr.county_id)
    LEFT JOIN places jorpl
        ON (jorpl.entity_id = jorec.jurisdiction_id)
    LEFT JOIN external_codes stateec
        ON (stateec.id = pataddr.state_id)
    LEFT JOIN external_codes agetypeec
        ON (agetypeec.id = events.age_type_id)
    LEFT JOIN external_codes est_ec
        ON (est_ec.id = ppl.age_type_id)
	LEFT JOIN participations_contacts partcon
		ON (partcon.id = events.participations_contact_id)
	LEFT JOIN external_codes partcon_disp_ec
		ON (partcon.disposition_id = partcon_disp_ec.id)
	LEFT JOIN external_codes partcon_cont_ec
		ON (partcon.contact_type_id = partcon_cont_ec.id)
WHERE
	events.type = 'ContactEvent' AND
	pa.type = 'Jurisdiction' AND
	pplpart.secondary_entity_id IS NULL AND
	pplpart.type = 'InterestedParty'
;

CREATE TABLE dw_secondary_jurisdictions AS
SELECT
    -- TODO: Test this with contact events with secondary jurisdictions
    events.id,
    CASE
        WHEN events.type = 'MorbidityEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_morbidity_events_id,
    CASE
        WHEN events.type = 'ContactEvent' THEN events.id
        ELSE NULL::INTEGER
    END AS dw_contact_events_id,
    pl.short_name AS jurisdiction_short_name
FROM
    events
    LEFT JOIN participations pr
        ON (pr.event_id = events.id)
    LEFT JOIN places pl
        ON (pl.entity_id = pr.secondary_entity_id)
WHERE
    pr.type = 'AssociatedJurisdiction' AND
    (
        events.type = 'ContactEvent' OR
        events.type = 'MorbidityEvent'
    )
;

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
    hpart.admission_date,
    hpart.discharge_date,
    hpart.medical_record_number,
    hpart.hospital_record_number
FROM
	events
	LEFT JOIN participations p
		ON (p.event_id = events.id)
	LEFT JOIN places pl
		ON (pl.entity_id = p.secondary_entity_id)
    LEFT JOIN hospitals_participations hpart
        ON (hpart.participation_id = p.id)
WHERE
	p.type = 'HospitalizationFacility'
;

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
    places.name,
    lr.test_type,
    lr.test_detail,
    lr.lab_result_text,
    lr.reference_range,
    intec.code_description AS interpretation,
    ssec.code_description AS specimen_source,
    lr.collection_date,
    lr.lab_test_date,
    uphlec.code_description AS specimen_sent_to_uphl
FROM
	lab_results lr
    LEFT JOIN external_codes intec
        ON (intec.id = lr.interpretation_id)
    LEFT JOIN external_codes ssec
        ON (ssec.id = lr.specimen_source_id)
    LEFT JOIN external_codes uphlec
        ON (uphlec.id = lr.specimen_sent_to_uphl_yn_id)
	LEFT JOIN participations p
		ON (p.id = lr.participation_id)
    LEFT JOIN events
        ON (p.event_id = events.id)
	LEFT JOIN places
		ON (places.entity_id = p.secondary_entity_id)
;

INSERT INTO dw_lab_results
(
    id, dw_morbidity_events_id, dw_contact_events_id,
    name, test_type, test_detail, lab_result_text,
    reference_range, interpretation, specimen_source,
    collection_date, lab_test_date, specimen_sent_to_uphl
)
SELECT
    lr.id,
    morbev.id,
    NULL,
    places.name,
    lr.test_type,
    lr.test_detail,
    lr.lab_result_text,
    lr.reference_range,
    intec.code_description AS interpretation,
    ssec.code_description AS specimen_source,
    lr.collection_date,
    lr.lab_test_date,
    uphlec.code_description AS specimen_sent_to_uphl
FROM
	lab_results lr
    LEFT JOIN external_codes intec
        ON (intec.id = lr.interpretation_id)
    LEFT JOIN external_codes ssec
        ON (ssec.id = lr.specimen_source_id)
    LEFT JOIN external_codes uphlec
        ON (uphlec.id = lr.specimen_sent_to_uphl_yn_id)
	LEFT JOIN participations p
		ON (p.id = lr.participation_id)
    LEFT JOIN events contev
        ON (p.event_id = contev.id)
    LEFT JOIN events morbev
        ON (morbev.id = contev.parent_id)
	LEFT JOIN places
		ON (places.entity_id = p.secondary_entity_id)
WHERE
    contev.type = 'EncounterEvent' AND
    morbev.type = 'MorbidityEvent'
;

CREATE SEQUENCE dw_patients_races_seq;

CREATE TABLE dw_patients_races AS
SELECT
    NEXTVAL('dw_patients_races_seq'),
	ex.code_description AS race,
	p.id AS person_id
FROM
	people_races pr
	LEFT JOIN external_codes ex
		ON (pr.race_id = ex.id)
	LEFT JOIN people p
		ON (p.entity_id = pr.entity_id)
;

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
    pt.treatment_id,
    tgec.code_description AS treatment_given,
    pt.treatment_date AS date_of_treatment,
    pt.treatment AS treatment_notes
FROM
	participations_treatments pt
	LEFT JOIN participations p
		ON (p.id = pt.participation_id)
	LEFT JOIN events
		ON (events.id = p.event_id)
    LEFT JOIN external_codes tgec
        ON (tgec.id = pt.treatment_given_yn_id)
WHERE
    events.type IN ('ContactEvents', 'MorbidityEvents')
;

INSERT INTO dw_events_treatments 
(
    id, dw_morbidity_events_id, dw_contact_events_id,
    treatment_id, treatment_given, date_of_treatment,
    treatment_notes
)
SELECT
    pt.id,
    morbev.id,
    NULL,
    pt.treatment_id,
    tgec.code_description AS treatment_given,
    pt.treatment_date AS date_of_treatment,
    pt.treatment AS treatment_notes
FROM
    participations_treatments pt
	LEFT JOIN participations p
		ON (p.id = pt.participation_id)
	LEFT JOIN events contev
		ON (contev.id = p.event_id)
    LEFT JOIN events morbev
        ON (morbev.id = contev.parent_id)
    LEFT JOIN external_codes tgec
        ON (tgec.id = pt.treatment_given_yn_id)
WHERE
    contev.type = 'EncounterEvent'
;

CREATE TABLE dw_events_clinicians AS
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
	LEFT JOIN participations p
		ON (p.event_id = events.id)
	LEFT JOIN people pl
		ON (pl.entity_id = p.secondary_entity_id)
WHERE
	p.type = 'Clinician'
;

CREATE TABLE dw_events_diagnostic_facilities AS
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
    pl.name AS name,
    pl.id AS place_id
FROM
	events
	LEFT JOIN participations p
		ON (p.event_id = events.id)
	LEFT JOIN places pl
		ON (pl.entity_id = p.secondary_entity_id)
WHERE
	p.type = 'DiagnosticFacility'
;

CREATE TABLE dw_events_reporting_agencies AS
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
    pl.name AS name,
    pl.id AS place_id
FROM
	events
	LEFT JOIN participations p
		ON (p.event_id = events.id)
	LEFT JOIN places pl
		ON (pl.entity_id = p.secondary_entity_id)
WHERE
	p.type = 'ReportingAgency'
;

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
	LEFT JOIN participations p
		ON (p.event_id = events.id)
	LEFT JOIN people pl
		ON (pl.entity_id = p.secondary_entity_id)
WHERE
	p.type = 'Reporter'
;

CREATE TABLE dw_place_events AS
SELECT
    events.id,
    events.parent_id AS dw_morbidity_events_id,
    ad.street_number,
    ad.street_name,
    ad.unit_number,
    ad.city,
    state_ec.code_description AS state,
    county_ec.code_description AS county,
    ad.postal_code
FROM
    events
    LEFT JOIN addresses ad
        ON (ad.event_id = events.id)
    LEFT JOIN external_codes state_ec
        ON (state_ec.id = ad.state_id)
    LEFT JOIN external_codes county_ec
        ON (county_ec.id = ad.county_id)
WHERE
    events.type = 'PlaceEvent'
;

CREATE TABLE dw_encounters AS
SELECT
    pe.id,
    events.parent_id AS dw_morbidity_events_id,
    pe.user_id AS investigator_id,
    pe.encounter_date,
    pe.encounter_location_type AS location,
    pe.description
FROM
    participations_encounters pe
    LEFT JOIN events
        ON (events.participations_encounter_id = pe.id)
;

CREATE TABLE dw_encounters_labs AS
SELECT
    events.id,
    events.id AS dw_encounters_id,
    lr.id AS dw_lab_results_id
FROM
    lab_results lr
    LEFT JOIN participations p
        ON (p.id = lr.participation_id)
    LEFT JOIN events
        ON (events.id = p.event_id)
WHERE
    events.type = 'EncounterEvent'
;

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
        ON (events.id = p.event_id)
WHERE
    events.type = 'EncounterEvent'
;

COMMIT;
