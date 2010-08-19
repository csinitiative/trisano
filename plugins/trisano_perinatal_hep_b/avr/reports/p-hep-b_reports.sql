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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

BEGIN;

DROP SCHEMA IF EXISTS phepb_reports CASCADE;

CREATE SCHEMA phepb_reports;

GRANT USAGE ON SCHEMA phepb_reports TO trisano_ro;

SET SEARCH_PATH = phepb_reports;

CREATE TABLE report1 AS
                SELECT
                    id,
                    COALESCE(first_name || ' ', '') || COALESCE(last_name, '') AS name,
                    record_number,
                    expected_delivery_facility,
                    expected_delivery_facility_phone,
                    pregnancy_due_date,
                    investigating_jurisdiction
                FROM 
                    trisano.dw_morbidity_events_view
                WHERE
                    disease_name = 'Hepatitis B Pregnancy Event'
                    ;

CREATE TABLE report2 AS
                SELECT
                    id, investigating_jurisdiction,
                    date_entered_into_system,
                    extract(year from date_entered_into_system)::INTEGER AS year,
                    CASE
                        WHEN pregnancy_due_date IS NOT NULL THEN 1
                        ELSE 0
                    END AS prospective_infants,
                    CASE
                        WHEN pregnancy_due_date IS NULL THEN 1
                        ELSE 0
                    END AS retrospective_infants,
                    (
                        SELECT count(*) FROM trisano.dw_contact_events_view c
                        WHERE dmev.id = c.id AND contact_type = 'Infant'
                    ) AS contact_infants,
                    CASE
                        WHEN disposition_date IS NULL THEN 1
                        -- This is also probably not what we want
                        ELSE 0
                    END AS currently_active
                FROM
                    trisano.dw_morbidity_events_view dmev
                WHERE
                    -- This again may not be what we want
                    disease_name = 'Hepatitis B Pregnancy Event' AND
                    pregnant = 'Yes' AND
                    actual_delivery_date IS NOT NULL
;

CREATE TABLE report3 AS
                SELECT
                    name_addr.id,
                    name_addr.name,
                    name_addr.address,
                    name_addr.phone,
                    name_addr.investigating_jurisdiction AS morb_juris,
                    contact_stuff.contact_type,
                    contact_stuff.name AS contact_name,
                    to_char(contact_stuff.birth_date, 'MM/DD/YYYY') AS contact_birth_date,
                    contact_stuff.age AS contact_age,
                    to_char(contact_stuff.first_due_date, 'MM/DD/YYYY') AS first_due_date,
                    contact_stuff.action
                FROM
                    (
                        SELECT
                            id,
                            COALESCE(dme.first_name || ' ', '') || COALESCE(dme.last_name, '') AS name,
                            COALESCE(dme.street_number || ' ', '') ||
                            COALESCE(dme.street_name || ' ', '') ||
                            COALESCE(dme.unit_number, '') ||
                            COALESCE(dme.city || ', ', '') ||
                            COALESCE(dme.state || ' ', '') ||
                            COALESCE(dme.postal_code, '') AS address,
                            trisano.text_join_agg(
                                CASE WHEN dt.area_code IS NULL OR dt.area_code = '' THEN '' ELSE dt.area_code || '-' END
                                    ||
                                CASE WHEN dt.phone_number IS NULL OR dt.phone_number = '' THEN '' ELSE dt.phone_number END
                                    ||
                                CASE WHEN dt.extension IS NULL OR dt.extension = '' THEN '' ELSE ' Ext. ' || dt.extension END
                            , ', ') AS phone,
                            dme.investigating_jurisdiction
                        FROM
                            trisano.dw_morbidity_events_view dme
                            LEFT JOIN trisano.dw_morbidity_telephones_view dt
                                ON (dme.patient_entity_id = dt.entity_id)
                        WHERE
                            dme.disease_name = 'Hepatitis B Pregnancy Event' AND
                            dme.pregnant = 'Yes' AND
                            EXISTS (SELECT 1 FROM trisano.dw_contact_events_view WHERE parent_id = dme.id)
                        GROUP BY
                            id, name, address, investigating_jurisdiction
                    ) name_addr
                    LEFT JOIN (
                        SELECT
                            parent_id,
                            contact_type,
                            name,
                            birth_date,
                            age,
                            CASE
                                WHEN fdd_act_code = -1 THEN NULL
                                WHEN fdd_act_code =  1 THEN birth_date
                                WHEN fdd_act_code =  2 THEN birth_date
                                WHEN fdd_act_code =  3 THEN birth_date
                                WHEN fdd_act_code =  4 THEN birth_date + (INTERVAL '30 days' * 1)
                                WHEN fdd_act_code =  5 THEN birth_date + (INTERVAL '30 days' * 6)
                                WHEN fdd_act_code =  6 THEN birth_date + (INTERVAL '30 days' * 9)
                                WHEN fdd_act_code =  7 THEN birth_date + (INTERVAL '30 days' * 24)
                                WHEN fdd_act_code =  8 THEN now()::DATE
                                WHEN fdd_act_code =  9 THEN now()::DATE
                                WHEN fdd_act_code = 10 THEN hepb_dose1_date + (INTERVAL '30 days' * 1)
                                WHEN fdd_act_code = 11 THEN hepb_dose1_date + (INTERVAL '30 days' * 6)
                                WHEN fdd_act_code = 12 THEN hepb_dose3_date + (INTERVAL '30 days' * 1)
                                WHEN fdd_act_code = 13 THEN NULL::DATE
                                ELSE NULL -- If we get here, there's a problem
                            END AS first_due_date,
                            CASE
                                WHEN fdd_act_code = -1 THEN 'Something strange happened'
                                WHEN fdd_act_code =  1 THEN 'Needs HBIG and Vaccine #1'
                                WHEN fdd_act_code =  2 THEN 'Needs Vaccine #1'
                                WHEN fdd_act_code =  3 THEN 'Needs HBIG'
                                WHEN fdd_act_code =  4 THEN 'Needs Vaccine #2'
                                WHEN fdd_act_code =  5 THEN 'Needs 6-month vaccine dose'
                                WHEN fdd_act_code =  6 THEN 'Needs serology 3 months after 9-month dose'
                                WHEN fdd_act_code =  7 THEN 'Close Newborn Contact'
                                WHEN fdd_act_code =  8 THEN 'Needs Pre-Immunization Serology'
                                WHEN fdd_act_code =  9 THEN 'Needs Vaccine #1'
                                WHEN fdd_act_code = 10 THEN 'Needs Vaccine #2'
                                WHEN fdd_act_code = 11 THEN 'Needs Vaccine #3'
                                WHEN fdd_act_code = 12 THEN 'Needs Post Immunization Serology'
                                WHEN fdd_act_code = 13 THEN 'Close Contact'
                                ELSE 'Something went seriously wrong' -- If we get here, there's a problem
                            END AS action
                        FROM (
                            SELECT
                                dce.parent_id,
                                dce.contact_type,
                                CASE WHEN dce.first_name IS NULL OR dce.first_name = '' THEN '' ELSE dce.first_name || ' ' END ||
                                CASE WHEN dce.middle_name IS NULL OR dce.middle_name = '' THEN '' ELSE dce.middle_name || ' ' END ||
                                CASE WHEN dce.last_name IS NULL OR dce.last_name = '' THEN '' ELSE dce.last_name || ' ' END AS name,
                                dce.birth_date,
                                hepb_dose1_date::TIMESTAMPTZ,
                                hepb_dose3_date::TIMESTAMPTZ,
                                CASE
                                    WHEN dce.birth_date IS NOT NULL THEN
                                        CASE
                                            WHEN to_char(now() - dce.birth_date, 'DD')::INTEGER / 365 > 1 THEN
                                                (to_char(now() - dce.birth_date, 'DD')::INTEGER / 365)::TEXT || ' years'
                                            WHEN to_char(now() - dce.birth_date, 'DD')::INTEGER / 365 = 1 THEN
                                                (to_char(now() - dce.birth_date, 'DD')::INTEGER / 365)::TEXT || ' year'
                                            WHEN to_char(now() - dce.birth_date, 'DD')::INTEGER > 1 THEN
                                                to_char(now() - dce.birth_date, 'DD') || ' days'
                                            ELSE '1 day'
                                        END
                                    WHEN dce.age_in_years IS NOT NULL THEN
                                        CASE
                                            WHEN dce.age_in_years != 1 THEN dce.age_in_years::TEXT || ' years'
                                            ELSE '1 year'
                                        END
                                    ELSE ''
                                END AS age,
                                CASE
                                    WHEN dce.contact_type = 'Infant' THEN
                                        CASE
                                            WHEN hbig IS NULL AND hepb_dose1_date IS NULL THEN
                                                1 -- fdd = dob, act = 'Needs HBIG and Vaccine #1'
                                            WHEN hbig IS NOT NULL AND hepb_dose1_date IS NULL THEN
                                                2 -- fdd = dob, act = 'Needs Vaccine #1'
                                            WHEN hbig IS NULL AND hepb_dose1_date IS NOT NULL THEN
                                                3 -- fdd = dob, act = 'Needs HBIG'
                                            WHEN hbig IS NOT NULL AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NULL THEN
                                                4 -- fdd = dob + 1 mo., act = 'Needs Vaccine #2'
                                            WHEN hbig IS NOT NULL AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NULL THEN
                                                5 -- fdd = dob + 6 mo., act = 'Needs 6-month vaccine dose'
                                            WHEN
                                                COALESCE(
                                                    (now() - dce.birth_date) BETWEEN (interval '30 days' * 9) AND (interval '30 days' * 18),
                                                    dce.age_in_years BETWEEN .6 AND 1.5
                                                ) AND
                                                (trisano.get_contact_hbsag_after(dce.id, hepb_dose1_date)).lab_test_date IS NULL
                                                    THEN 6 -- fdd = dob + 9 mo., act = 'Needs serology 3 months after 9-month dose'
                                            WHEN COALESCE((now() - dce.birth_date) >= INTERVAL '365 days' * 2, dce.age_in_years >= 2) THEN
                                                7 -- fdd = dob + 24 mo., act = 'Close Newborn Contact'
                                            ELSE
                                                -1 -- This contact doesn't need to show up on the report
                                        END
                                    ELSE -- Not a newborn contact
                                        CASE
                                            WHEN
                                                (trisano.get_contact_hbsag_before(dce.id, hepb_dose1_date)).lab_test_date IS NULL OR
                                                (trisano.get_contact_antihb_before(dce.id, hepb_dose1_date)).lab_test_date IS NULL
                                                    THEN 8 -- fdd = report date, act = 'Needs Pre-Immunization Serology'
                                            WHEN
                                                hepb_dose1_date IS NULL AND
                                                (trisano.get_contact_hbsag_before(dce.id, hepb_dose1_date)).test_result !~ 'Positive' AND
                                                (trisano.get_contact_antihb_before(dce.id, hepb_dose1_date)).test_result !~ 'Positive'
                                                    THEN 9 -- fdd = report date, act = 'Needs Vaccine #1'
                                            WHEN
                                                hepb_dose1_date IS NOT NULL AND
                                                hepb_dose2_date IS NULL AND
                                                (trisano.get_contact_hbsag_before(dce.id, hepb_dose1_date)).test_result !~ 'Positive' AND
                                                (trisano.get_contact_antihb_before(dce.id, hepb_dose1_date)).test_result !~ 'Positive'
                                                    THEN 10 -- fdd = 'hepb_dose1_date' + 1 mo., act = 'Needs Vaccine #2'
                                            WHEN
                                                hepb_dose1_date IS NOT NULL AND
                                                hepb_dose2_date IS NOT NULL AND
                                                hepb_dose3_date IS NULL AND
                                                (trisano.get_contact_hbsag_before(dce.id, hepb_dose1_date)).test_result !~ 'Positive' AND
                                                (trisano.get_contact_antihb_before(dce.id, hepb_dose1_date)).test_result !~ 'Positive'
                                                    THEN 11 -- fdd = 'hepb_dose1_date' + 6 mo., act = 'Needs Vaccine #3'
                                            WHEN
                                                hepb_dose1_date IS NOT NULL AND
                                                hepb_dose2_date IS NOT NULL AND
                                                hepb_dose3_date IS NOT NULL AND
                                                (trisano.get_contact_hbsag_before(dce.id, hepb_dose1_date)).test_result !~ 'Positive' AND
                                                (trisano.get_contact_antihb_before(dce.id, hepb_dose1_date)).test_result !~ 'Positive'
                                                    THEN 12 -- fdd = 'hepb_dose3_date' + 1 mo., act = 'Needs Post Immunization Serology'
                                            WHEN disposition_date IS NOT NULL
                                                -- XXX This should possibly be the *first* non-newborn check
                                                THEN 13 -- fdd = report date, act = 'Close Contact'
                                            ELSE
                                                -1 -- XXX What do we do here?
                                        END
                                END AS fdd_act_code
                            FROM
                                trisano.dw_contact_events_view dce
                                LEFT JOIN (
                                    SELECT
                                        dw_contact_events_id AS contact_event_id,
                                        trisano.earliest_date(trisano.array_accum(hbig_vacc_date )) AS hbig,
                                        trisano.earliest_date(trisano.array_accum(hebp_dose1_date)) AS hepb_dose1_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose2_date)) AS hepb_dose2_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose3_date)) AS hepb_dose3_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose4_date)) AS hepb_dose4_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose5_date)) AS hepb_dose5_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose6_date)) AS hepb_dose6_date
                                    FROM (
                                        SELECT
                                            dw_contact_events_id,
                                            CASE WHEN treatment_name = 'HBIG' THEN date_of_treatment ELSE NULL END AS hbig_vacc_date,
                                            CASE WHEN treatment_name = 'Hep B Dose 1 Vaccination' THEN date_of_treatment ELSE NULL END AS hebp_dose1_date,
                                            CASE WHEN treatment_name = 'Hep B Dose 2 Vaccination' THEN date_of_treatment ELSE NULL END AS hepb_dose2_date,
                                            -- The ~ instead of = is intentional
                                            CASE WHEN treatment_name ~ 'Hep B Dose 3 Vaccination' THEN date_of_treatment ELSE NULL END AS hepb_dose3_date,
                                            CASE WHEN treatment_name = 'Hep B Dose 4 Vaccination' THEN date_of_treatment ELSE NULL END AS hepb_dose4_date,
                                            CASE WHEN treatment_name = 'Hep B Dose 5 Vaccination' THEN date_of_treatment ELSE NULL END AS hepb_dose5_date,
                                            CASE WHEN treatment_name = 'Hep B Dose 6 Vaccination' THEN date_of_treatment ELSE NULL END AS hepb_dose6_date
                                        FROM
                                            trisano.dw_contact_treatments_events_view dct
                                        WHERE
                                            treatment_given = 'Yes'
                                    ) treatments_split
                                    GROUP BY 1
                                ) treatments_agg
                                    ON (treatments_agg.contact_event_id = dce.id)
                        ) foo
                    ) contact_stuff
                        ON (name_addr.id = contact_stuff.parent_id)
;

CREATE TABLE report4 AS
                SELECT
                    1 AS total,
                    dme.id,
                    dme.investigating_jurisdiction,
                    CASE WHEN contact_type = 'infant' AND disposition IS NULL THEN 1 ELSE NULL END AS active,
                    CASE WHEN contact_type = 'infant' AND disposition = 'completed' THEN 1 ELSE NULL END AS completed,
                    CASE WHEN contact_type = 'infant' AND disposition = 'provider refusal' THEN 1 ELSE NULL END AS provider_refusal,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Mother/family refusal' THEN 1 ELSE NULL END AS mother_fam_refusal,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Moved' THEN 1 ELSE NULL END AS moved,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Unable to locate' THEN 1 ELSE NULL END AS unable_locate,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Died' THEN 1 ELSE NULL END AS infant_died,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Adopted' THEN 1 ELSE NULL END AS infant_adopted,
                    CASE WHEN contact_type = 'infant' AND disposition = 'False positive mother/case' THEN 1 ELSE NULL END AS false_pos,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Miscarriage or termination' THEN 1 ELSE NULL END AS miscarriage,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Other' THEN 1 ELSE NULL END AS other,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '1 day' AND hbig_vacc_date <= dce.birth_date + INTERVAL '1 day' THEN 1 ELSE NULL END AS both_24,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '1 day' THEN 1 ELSE NULL END AS dose1_24,
                    CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= dce.birth_date + INTERVAL '1 day' THEN 1 ELSE NULL END AS hbig_24,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > dce.birth_date + INTERVAL '1 day' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END AS neither_24,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '2 days' AND hbig_vacc_date <= dce.birth_date + INTERVAL '2 days' THEN 1 ELSE NULL END AS both_48,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '2 days' THEN 1 ELSE NULL END AS dose1_48,
                    CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= dce.birth_date + interval '2 days' THEN 1 ELSE NULL END AS hbig_48,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > dce.birth_date + INTERVAL '2 days' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END AS neither_48,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '7 days' AND hbig_vacc_date <= dce.birth_date + INTERVAL '7 days' THEN 1 ELSE NULL END AS both_7d,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '7 days' THEN 1 ELSE NULL END AS dose1_7d,
                    CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= dce.birth_date + interval '7 days' THEN 1 ELSE NULL END AS hbig_7d,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > dce.birth_date + INTERVAL '7 days' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END AS neither_7d,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '2 months' AND hbig_vacc_date <= dce.birth_date + INTERVAL '7 days' THEN 1 ELSE NULL END AS both_2m,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '2 months' THEN 1 ELSE NULL END AS dose1_2m,
                    CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= dce.birth_date + interval '2 months' THEN 1 ELSE NULL END AS hbig_2m,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > dce.birth_date + INTERVAL '2 months' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END AS neither_2m,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '8 months' AND hbig_vacc_date <= dce.birth_date + INTERVAL '7 days' THEN 1 ELSE NULL END AS both_8m,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '8 months' THEN 1 ELSE NULL END AS dose1_8m,
                    CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= dce.birth_date + interval '8 months' THEN 1 ELSE NULL END AS hbig_8m,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > dce.birth_date + INTERVAL '8 months' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END AS neither_8m,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '12 months' AND hbig_vacc_date <= dce.birth_date + INTERVAL '7 days' THEN 1 ELSE NULL END AS both_12m,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= dce.birth_date + interval '12 months' THEN 1 ELSE NULL END AS dose1_12m,
                    CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= dce.birth_date + interval '12 months' THEN 1 ELSE NULL END AS hbig_12m,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > dce.birth_date + INTERVAL '12 months' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END AS neither_12m,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NOT NULL AND hepb_dose4_date IS NOT NULL THEN 1 ELSE NULL END AS four_dose,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NOT NULL AND hepb_dose4_date IS NOT NULL AND hepb_dose5_date IS NOT NULL THEN 1 ELSE NULL END AS five_dose,
                    CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NOT NULL AND hepb_dose4_date IS NOT NULL AND hepb_dose5_date IS NOT NULL AND hepb_dose6_date IS NOT NULL THEN 1 ELSE NULL END AS six_dose,
                    CASE WHEN contact_type = 'infant' AND (trisano.get_contact_hbsag_before(dce.id, hepb_dose1_date)).lab_test_date <= dce.birth_date + INTERVAL '12 months' AND (trisano.get_contact_antihb_after(dce.id, hepb_dose1_date)).lab_test_date <= dce.birth_date + INTERVAL '12 months' THEN 1 ELSE NULL END AS serotest_12m,
                    CASE WHEN contact_type = 'infant' AND (trisano.get_contact_hbsag_before(dce.id, hepb_dose1_date)).lab_test_date <= dce.birth_date + INTERVAL '15 months' AND (trisano.get_contact_antihb_after(dce.id, hepb_dose1_date)).lab_test_date <= dce.birth_date + INTERVAL '15 months' THEN 1 ELSE NULL END AS serotest_15m,
                    CASE WHEN contact_type = 'infant' AND ((trisano.get_contact_hbsag_after(dce.id, hepb_dose1_date)).lab_test_date IS NULL OR (trisano.get_contact_antihb_after(dce.id, hepb_dose1_date)).lab_test_date IS NULL) THEN 1 ELSE NULL END AS total_serotest,
                    CASE WHEN contact_type = 'infant' AND (trisano.get_contact_hbsag_after(dce.id, hepb_dose1_date)).test_result ~ 'Positive' THEN 1 ELSE NULL END AS positive_antihb,
                    CASE WHEN contact_type = 'infant' AND (trisano.get_contact_antihb_after(dce.id, hepb_dose1_date)).test_result ~ 'Positive' THEN 1 ELSE NULL END AS positive_hbsag,
                    -- XXX Still have com vax vacc date here, to fix
                    CASE WHEN contact_type = 'infant' AND 'com_vax_vacc_date' IS NOT NULL THEN 1 ELSE NULL END AS received_comvax,
                    CASE WHEN contact_type IN ('Sexual', 'Household') THEN 1 ELSE NULL END AS total_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition IS NULL THEN 1 ELSE NULL END AS active_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Completed' THEN 1 ELSE NULL END AS completed_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Provider refusal' THEN 1 ELSE NULL END AS provider_refusal_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Refused preventative treatment' THEN 1 ELSE NULL END AS refused_treatment_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Moved' THEN 1 ELSE NULL END AS moved_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Unable to locate' THEN 1 ELSE NULL END AS unable_to_locate_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Died' THEN 1 ELSE NULL END AS died_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'False positive mother/case' THEN 1 ELSE NULL END AS false_positive_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Other' THEN 1 ELSE NULL END AS other_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND ((trisano.get_contact_hbsag_before(dce.id, hepb_dose1_date)).test_result IS NOT NULL OR (trisano.get_contact_antihb_before(dce.id, hepb_dose1_date)).test_result IS NOT NULL) THEN 1 ELSE NULL END AS total_hs_tested,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND (trisano.get_contact_hbsag_after(dce.id, hepb_dose1_date)).test_result ~ 'Positive' THEN 1 ELSE NULL END AS hbsag_pos_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND (trisano.get_contact_antihb_after(dce.id, hepb_dose1_date)).test_result ~ 'Positive' THEN 1 ELSE NULL END AS antihb_pos_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND hepb_dose1_date IS NOT NULL THEN 1 ELSE NULL END AS dose1_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL THEN 1 ELSE NULL END AS dose2_hs,
                    CASE WHEN contact_type IN ('Sexual', 'Household') AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NOT NULL THEN 1 ELSE NULL END AS dose3_hs,
                    -- This labels field 62 as '<6>', suggesting it's a copy of field 6.
                    CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date IS NOT NULL AND hbig_vacc_date IS NOT NULL THEN 1 ELSE NULL END AS dose1_hbig_trans,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date IS NULL AND hbig_vacc_date IS NOT NULL THEN 1 ELSE NULL END AS hbig_trans,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date IS NOT NULL AND hbig_vacc_date IS NULL THEN 1 ELSE NULL END AS dose1_trans,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date IS NULL AND hbig_vacc_date IS NULL THEN 1 ELSE NULL END AS neither_trans,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date < dce.birth_date + INTERVAL '8 months' AND hepb_dose2_date < dce.birth_date + INTERVAL '8 months' AND hepb_dose3_date < dce.birth_date + INTERVAL '8 months' AND hbig_vacc_date < dce.birth_date + INTERVAL '8 months' THEN 1 ELSE NULL END AS all_8m_trans,
                    CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date < dce.birth_date + INTERVAL '8 months' AND hepb_dose2_date < dce.birth_date + INTERVAL '12 months' AND hepb_dose3_date < dce.birth_date + INTERVAL '12 months' AND hbig_vacc_date < dce.birth_date + INTERVAL '12 months' THEN 1 ELSE NULL END AS all_12m_trans
                FROM
                    trisano.dw_contact_events_view dce
                    JOIN trisano.dw_morbidity_events_view dme
                        ON (dce.parent_id = dme.id)
                    LEFT JOIN (
                        SELECT
                            dw_contact_events_id AS contact_event_id,
                            trisano.earliest_date(trisano.array_accum(hbig_vacc_date )) AS hbig_vacc_date,
                            trisano.earliest_date(trisano.array_accum(hebp_dose1_date)) AS hepb_dose1_date,
                            trisano.earliest_date(trisano.array_accum(hepb_dose2_date)) AS hepb_dose2_date,
                            trisano.earliest_date(trisano.array_accum(hepb_dose3_date)) AS hepb_dose3_date,
                            trisano.earliest_date(trisano.array_accum(hepb_dose4_date)) AS hepb_dose4_date,
                            trisano.earliest_date(trisano.array_accum(hepb_dose5_date)) AS hepb_dose5_date,
                            trisano.earliest_date(trisano.array_accum(hepb_dose6_date)) AS hepb_dose6_date
                        FROM (
                            SELECT
                                dw_contact_events_id,
                                CASE WHEN treatment_name = 'HBIG' THEN date_of_treatment ELSE NULL END AS hbig_vacc_date,
                                CASE WHEN treatment_name = 'Hep B Dose 1 Vaccination' THEN date_of_treatment ELSE NULL END AS hebp_dose1_date,
                                CASE WHEN treatment_name = 'Hep B Dose 2 Vaccination' THEN date_of_treatment ELSE NULL END AS hepb_dose2_date,
                                -- The ~ is intentional
                                CASE WHEN treatment_name ~ 'Hep B Dose 3 Vaccination' THEN date_of_treatment ELSE NULL END AS hepb_dose3_date,
                                CASE WHEN treatment_name = 'Hep B Dose 4 Vaccination' THEN date_of_treatment ELSE NULL END AS hepb_dose4_date,
                                CASE WHEN treatment_name = 'Hep B Dose 5 Vaccination' THEN date_of_treatment ELSE NULL END AS hepb_dose5_date,
                                CASE WHEN treatment_name = 'Hep B Dose 6 Vaccination' THEN date_of_treatment ELSE NULL END AS hepb_dose6_date
                            FROM
                                trisano.dw_contact_treatments_events_view dct
                            WHERE
                                treatment_given = 'Yes'
                        ) treatments_split
                        GROUP BY dw_contact_events_id
                    ) treatments_agg
                        ON (treatments_agg.contact_event_id = dce.id)
                WHERE
                    dce.disease_name = 'Hepatitis B Pregnancy Event'
;

CREATE TABLE morb_sec_juris AS
    SELECT dw_morbidity_events_id, name FROM trisano.dw_morbidity_secondary_jurisdictions_view;

GRANT SELECT ON report1 TO trisano_ro;
GRANT SELECT ON report2 TO trisano_ro;
GRANT SELECT ON report3 TO trisano_ro;
GRANT SELECT ON report4 TO trisano_ro;
GRANT SELECT ON morb_sec_juris TO trisano_ro;

COMMIT;
