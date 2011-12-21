-- Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

-- Functions used by perinatal hep b reports (eventually move this to plugin-specific stuff)
CREATE OR REPLACE FUNCTION trisano.get_contact_lab_before(INTEGER, TEXT, DATE)
    RETURNS trisano.dw_contact_lab_results_view LANGUAGE sql STABLE
    CALLED ON NULL INPUT AS
$$
    SELECT * FROM trisano.dw_contact_lab_results_view
    WHERE
        dw_contact_events_id = $1 AND test_type = $2 AND
        (lab_test_date < $3 OR $3 IS NULL)
    ORDER BY lab_test_date DESC LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION trisano.get_contact_hbsag_before(INTEGER, DATE)
    RETURNS trisano.dw_contact_lab_results_view LANGUAGE sql STABLE
    CALLED ON NULL INPUT AS
$$
    SELECT * FROM trisano.get_contact_lab_before($1, 'Surface Antigen (HBsAg)', $2);
$$;

CREATE OR REPLACE FUNCTION trisano.get_contact_antihb_before(INTEGER, DATE)
    RETURNS trisano.dw_contact_lab_results_view LANGUAGE sql STABLE
    CALLED ON NULL INPUT AS
$$
    SELECT * FROM trisano.get_contact_lab_before($1, 'Surface Antibody (HBsAb)', $2);
$$;

CREATE OR REPLACE FUNCTION trisano.get_contact_lab_after(INTEGER, TEXT, DATE)
    RETURNS trisano.dw_contact_lab_results_view LANGUAGE sql STABLE
    CALLED ON NULL INPUT AS
$$
    SELECT * FROM trisano.dw_contact_lab_results_view
    WHERE
        dw_contact_events_id = $1 AND test_type = $2 AND
        (lab_test_date > $3 OR $3 IS NULL)
    ORDER BY lab_test_date ASC LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION trisano.get_contact_hbsag_after(INTEGER, DATE)
    RETURNS trisano.dw_contact_lab_results_view LANGUAGE sql STABLE
    CALLED ON NULL INPUT AS
$$
    SELECT * FROM trisano.get_contact_lab_after($1, 'Surface Antigen (HBsAg)', $2);
$$;

CREATE OR REPLACE FUNCTION trisano.get_contact_antihb_after(INTEGER, DATE)
    RETURNS trisano.dw_contact_lab_results_view LANGUAGE sql STABLE
    CALLED ON NULL INPUT AS
$$
    SELECT * FROM trisano.get_contact_lab_after($1, 'Surface Antibody (HBsAb)', $2);
$$;

COMMIT;

BEGIN;

DROP SCHEMA IF EXISTS phepb_reports CASCADE;

CREATE SCHEMA phepb_reports;

GRANT USAGE ON SCHEMA phepb_reports TO trisano_ro;

SET SEARCH_PATH = phepb_reports;

-- Canonical list of contact dispositions
CREATE TABLE dispositions (
    disposition TEXT,
    ordering INTEGER
);

INSERT INTO dispositions VALUES
    ('<None>', 1),
    ('Active follow up', 2),
    ('Closed: Completed', 3),
    ('Closed: Unable to locate', 4),
    ('Closed: False positive mother', 5),
    ('Closed: Refusal to participate', 6),
    ('Closed: Noncompliance', 7),
    ('Closed: Transferred to another state', 8),
    ('Closed: Left state (unable to transfer)', 9),
    ('Closed: Moved out of country', 10),
    ('Closed: Infant adopted', 11),
    ('Closed: Infant died', 12),
    ('Closed: Miscarriage/terminated', 13),
    ('Closed: Other', 14)
;


-- Delivery action report
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
                    disease_name = 'Hepatitis B Pregnancy Event' AND
                    actual_delivery_date IS NULL
                    ;

-- Event Summary report
CREATE TABLE report2 AS
                SELECT
                    id, investigating_jurisdiction, record_number,
                    contacts.contact_birth_date AS actual_delivery_date,
                    EXTRACT(year FROM
                        COALESCE(contacts.contact_birth_date, actual_delivery_date)
                    )::INTEGER AS year,
                    CASE
                        WHEN pregnancy_due_date IS NOT NULL THEN 1
                        ELSE 0
                    END AS prospective_infants,
                    CASE
                        WHEN pregnancy_due_date IS NULL THEN 1
                        ELSE 0
                    END AS retrospective_infants,
                    COALESCE(contact_infants, 0) AS contact_infants,
--                    (
--                        SELECT count(*) FROM trisano.dw_contact_events_view c
--                        WHERE dmev.id = c.parent_id AND contact_type = 'Infant'
--                    ) AS contact_infants,
                    COALESCE(currently_active, 0) AS currently_active
--                    (
--                        SELECT count(*) FROM trisano.dw_contact_events_view c
--                        WHERE dmev.id = c.parent_id AND contact_type = 'Infant'
--                        AND (
--                            c.disposition = 'Active follow up' OR
--                            c.disposition IS NULL
--                        )
--                    ) AS currently_active
                FROM
                    trisano.dw_morbidity_events_view dmev
                    INNER JOIN (
                        SELECT
                            parent_id,
                            MIN(birth_date) AS contact_birth_date,
                            SUM(
                                CASE WHEN contact_type = 'Infant' THEN 1 ELSE 0 END
                            ) AS contact_infants,
                            SUM(
                                CASE WHEN contact_type = 'Infant' AND
                                    (
                                        disposition = 'Active follow up' OR
                                        disposition IS NULL
                                    ) THEN 1
                                ELSE 0 END
                            ) AS currently_active
                        FROM trisano.dw_contact_events_view
                        WHERE birth_date IS NOT NULL
                        GROUP BY parent_id
                    ) contacts
                        ON (contacts.parent_id = dmev.id)
                WHERE
                    -- This again may not be what we want
                    disease_name = 'Hepatitis B Pregnancy Event' AND
                    -- pregnant = 'Yes' AND
                    actual_delivery_date IS NOT NULL AND
                    lhd_case_status_code NOT IN ('Discarded', 'Not a Case')
;

-- Event Action report
CREATE TABLE report3 AS
                SELECT
                    name_addr.id,
                    name_addr.record_number,
                    name_addr.name,
                    name_addr.address,
                    name_addr.phone,
                    name_addr.investigating_jurisdiction AS morb_juris,
                    contact_stuff.contact_type,
                    contact_stuff.name AS contact_name,
                    to_char(contact_stuff.birth_date, 'MM/DD/YYYY') AS contact_birth_date,
                    contact_stuff.age AS contact_age,
                    contact_stuff.first_due_date::DATE,
                    contact_stuff.action
                FROM
                    (
                        SELECT
                            id,
                            record_number,
                            COALESCE(dme.first_name || ' ', '') || COALESCE(dme.last_name, '') AS name,
                            trim(' ' from
                                COALESCE(dme.street_number || ' ', '') ||
                                COALESCE(dme.street_name || ' ', '') ||
                                COALESCE(dme.unit_number || ' ', '') ||
                                COALESCE(dme.city || ', ', '') ||
                                COALESCE(dme.state || ' ', '') ||
                                COALESCE(dme.postal_code, '')
                            ) AS address,
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
                            -- dme.pregnant = 'Yes' AND
                            EXISTS (SELECT 1 FROM trisano.dw_contact_events_view WHERE parent_id = dme.id)
                        GROUP BY
                            id, record_number, name, address, investigating_jurisdiction
                    ) name_addr
                    JOIN (
                        SELECT
                            parent_id,
                            contact_type,
                            name,
                            birth_date,
                            age,
                            CASE
                                WHEN fdd_act_code = 1 THEN birth_date
                                WHEN fdd_act_code = 2 THEN birth_date
                                WHEN fdd_act_code = 3 THEN birth_date
                                WHEN fdd_act_code = 4 THEN dose1_recvd + INTERVAL '6 months'
                                WHEN fdd_act_code = 5 THEN dose2_recvd + INTERVAL '6 months'
                                WHEN fdd_act_code = 6 THEN birth_date + INTERVAL '9 months'
                                WHEN fdd_act_code = 7 THEN NULL
                                WHEN fdd_act_code = 8 THEN NULL
                                WHEN fdd_act_code = 9 THEN NULL
                                WHEN fdd_act_code = 10 THEN dose4_recvd + INTERVAL '1 month'
                                WHEN fdd_act_code = 11 THEN dose4_recvd + INTERVAL '6 months'
                                WHEN fdd_act_code = 12 THEN COALESCE(dose8_recvd, COALESCE(dose7_recvd, dose6_recvd)) + INTERVAL '1 month'
                                WHEN fdd_act_code = 13 THEN NULL
                                WHEN fdd_act_code = 14 THEN NULL
                                WHEN fdd_act_code = 15 THEN NULL
                            END AS first_due_date,
                            CASE
                                WHEN fdd_act_code = 1 THEN 'Needs HBIG and Hepatitis B Dose 1'
                                WHEN fdd_act_code = 2 THEN 'Needs HBIG'
                                WHEN fdd_act_code = 3 THEN 'Needs Hepatitis B Dose 1'
                                WHEN fdd_act_code = 4 THEN 'Needs Hepatitis B Dose 2'
                                WHEN fdd_act_code = 5 THEN 'Needs Hepatitis B Dose 3'
                                WHEN fdd_act_code = 6 THEN 'Needs Serology 3 months after Hepatitis B Dose 3 / Hepatitis B – Comvax Dose 3'
                                WHEN fdd_act_code = 7 THEN 'Check vaccination history; Test or Vaccinate'
                                WHEN fdd_act_code = 8 THEN 'Enter Infant''s Date of Birth'
                                WHEN fdd_act_code = 9 THEN 'Close Contact'
                                WHEN fdd_act_code = 10 THEN 'Needs Hepatitis B Dose 5'
                                WHEN fdd_act_code = 11 THEN 'Needs Hepatitis B Dose 6'
                                WHEN fdd_act_code = 12 THEN 'Needs serology after final dose of 2nd Hepatitis B series'
                                WHEN fdd_act_code = 13 THEN 'Needs to complete 2nd Hepatits B series'
                                WHEN fdd_act_code = 14 THEN 'Close contact after completion of 2nd Hepatits B series'
                                WHEN fdd_act_code = 15 THEN 'Needs Hepatitis B Dose 4'
                            END AS action
                        FROM (
                            SELECT
                                dce.parent_id,
                                dce.contact_type,
                                CASE WHEN dce.first_name IS NULL OR dce.first_name = '' THEN '' ELSE dce.first_name || ' ' END ||
                                CASE WHEN dce.middle_name IS NULL OR dce.middle_name = '' THEN '' ELSE dce.middle_name || ' ' END ||
                                CASE WHEN dce.last_name IS NULL OR dce.last_name = '' THEN '' ELSE dce.last_name || ' ' END AS name,
                                COALESCE(dce.birth_date, dme_2.actual_delivery_date) AS birth_date,
                                hepb_dose1_date::TIMESTAMPTZ,
                                hepb_dose2_date::TIMESTAMPTZ,
                                hepb_comvax1_date::TIMESTAMPTZ,
                                hepb_comvax2_date::TIMESTAMPTZ,
                                dose1_recvd, dose2_recvd, dose3_recvd,
                                dose4_recvd, dose5_recvd, dose6_recvd,
                                dose7_recvd, dose8_recvd,
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
                                    WHEN dme_2.actual_delivery_date IS NOT NULL THEN
                                        CASE
                                            WHEN to_char(now() - dme_2.actual_delivery_date, 'DD')::INTEGER / 365 > 1 THEN
                                                (to_char(now() - dme_2.actual_delivery_date, 'DD')::INTEGER / 365)::TEXT || ' years'
                                            WHEN to_char(now() - dme_2.actual_delivery_date, 'DD')::INTEGER / 365 = 1 THEN
                                                (to_char(now() - dme_2.actual_delivery_date, 'DD')::INTEGER / 365)::TEXT || ' year'
                                            WHEN to_char(now() - dme_2.actual_delivery_date, 'DD')::INTEGER > 1 THEN
                                                to_char(now() - dme_2.actual_delivery_date, 'DD') || ' days'
                                            ELSE '1 day'
                                        END
                                    WHEN dce.age_in_years IS NOT NULL THEN
                                        CASE
                                            WHEN dce.age_in_years != 1 THEN dce.age_in_years::TEXT || ' years'
                                            ELSE '1 year'
                                        END
                                    ELSE ''
                                END AS age,
                                -- fdd_act_code values are described in
                                -- comments inline. The current maximum value
                                -- is 9
                                CASE
                                    WHEN dce.disposition LIKE 'Closed: %' THEN -1
                                    WHEN (trisano.get_contact_hbsag_before(dce.id, CURRENT_DATE)).test_result = 'Positive / Reactive' THEN 9
                                    WHEN dce.contact_type = 'Infant' THEN
                                        CASE
                                            WHEN dce.birth_date IS NULL THEN 8 -- Enter date of birth
                                            WHEN hbig IS NULL AND CURRENT_DATE - dce.birth_date < 7 THEN 2 -- "Needs HBIG"
                                            WHEN dose1_recvd IS NULL THEN 3 -- Needs dose1
                                            WHEN dose2_recvd IS NULL THEN 4 -- Needs dose2
                                            WHEN dose3_recvd IS NULL THEN 5 -- Needs dose3
                                            WHEN 
                                                now() - dce.birth_date BETWEEN (interval '30 days' * 9) AND (interval '30 days' * 18) AND (
                                                    (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).lab_test_date IS NULL OR
                                                    (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).test_result IS NULL
                                                ) THEN 6 -- Needs serology
                                            WHEN dose4_recvd IS NULL AND (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).test_result = 'Negative / Non-reactive' THEN 15 -- Needs dose 4
                                            WHEN dose5_recvd IS NULL AND (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).test_result = 'Negative / Non-reactive' THEN 10 -- Needs dose 5
                                            WHEN dose6_recvd IS NULL AND (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).test_result = 'Negative / Non-reactive' THEN 11 -- Needs dose 6
                                            WHEN
                                                COALESCE(dose8_recvd, COALESCE(dose7_recvd, dose6_recvd)) IS NOT NULL AND (
                                                    (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).lab_test_date IS NULL OR
                                                    (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).collection_date - COALESCE(dose8_recvd, COALESCE(dose7_recvd, dose6_recvd)) >= 30 --days
                                                ) THEN 12 -- Needs Serology after Final Dose of 2nd Hepatitis B Series
                                            WHEN
                                                dose6_recvd IS NOT NULL AND 
                                                (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).collection_date - dose6_recvd >= 30 -- days
                                                THEN 9
                                            ELSE -1
                                        END
                                    WHEN
                                        COALESCE(dose1_recvd, COALESCE(dose2_recvd, dose3_recvd)) IS NULL OR
                                        (
                                            dose3_recvd IS NOT NULL AND
                                            (
                                                (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).collection_date IS NULL OR
                                                (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).collection_date < dose3_recvd
                                            )
                                        ) THEN 7 -- Check history. test or vaccinate
                                    WHEN
                                        dose3_recvd IS NOT NULL AND dose6_recvd IS NULL AND
                                        (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).test_result = 'Negative / Non-reactive' AND
                                        (trisano.get_contact_antihb_before(dce.id, CURRENT_DATE)).collection_date > dose3_recvd
                                        THEN 13 -- Complete 2nd Hep B series
                                    WHEN dose6_recvd IS NOT NULL THEN 14 -- Close after completing 2nd
                                    ELSE -1
                                END AS fdd_act_code
                            FROM
                                trisano.dw_contact_events_view dce
                                LEFT JOIN trisano.dw_morbidity_events_view dme_2
                                    ON (dme_2.id = dce.parent_id)
                                LEFT JOIN (
                                    SELECT
                                        dw_contact_events_id AS contact_event_id,
                                        trisano.earliest_date(trisano.array_accum(hbig_vacc_date )) AS hbig,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose1_date)) AS hepb_dose1_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose2_date)) AS hepb_dose2_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose3_date)) AS hepb_dose3_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose4_date)) AS hepb_dose4_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose5_date)) AS hepb_dose5_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose6_date)) AS hepb_dose6_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose7_date)) AS hepb_dose7_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_dose8_date)) AS hepb_dose8_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_comvax1_date)) AS hepb_comvax1_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_comvax2_date)) AS hepb_comvax2_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_comvax3_date)) AS hepb_comvax3_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_comvax4_date)) AS hepb_comvax4_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_comvax5_date)) AS hepb_comvax5_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_comvax6_date)) AS hepb_comvax6_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_comvax7_date)) AS hepb_comvax7_date,
                                        trisano.earliest_date(trisano.array_accum(hepb_comvax8_date)) AS hepb_comvax8_date,
                                        COALESCE(trisano.earliest_date(trisano.array_accum(hepb_dose1_date)), trisano.earliest_date(trisano.array_accum(hepb_comvax1_date))) AS dose1_recvd,
                                        COALESCE(trisano.earliest_date(trisano.array_accum(hepb_dose2_date)), trisano.earliest_date(trisano.array_accum(hepb_comvax2_date))) AS dose2_recvd,
                                        COALESCE(trisano.earliest_date(trisano.array_accum(hepb_dose3_date)), trisano.earliest_date(trisano.array_accum(hepb_comvax3_date))) AS dose3_recvd,
                                        COALESCE(trisano.earliest_date(trisano.array_accum(hepb_dose4_date)), trisano.earliest_date(trisano.array_accum(hepb_comvax4_date))) AS dose4_recvd,
                                        COALESCE(trisano.earliest_date(trisano.array_accum(hepb_dose5_date)), trisano.earliest_date(trisano.array_accum(hepb_comvax5_date))) AS dose5_recvd,
                                        COALESCE(trisano.earliest_date(trisano.array_accum(hepb_dose6_date)), trisano.earliest_date(trisano.array_accum(hepb_comvax6_date))) AS dose6_recvd,
                                        COALESCE(trisano.earliest_date(trisano.array_accum(hepb_dose7_date)), trisano.earliest_date(trisano.array_accum(hepb_comvax7_date))) AS dose7_recvd,
                                        COALESCE(trisano.earliest_date(trisano.array_accum(hepb_dose8_date)), trisano.earliest_date(trisano.array_accum(hepb_comvax8_date))) AS dose8_recvd
                                    FROM (
                                        SELECT
                                            dw_contact_events_id,
                                            CASE WHEN treatment_name = 'HBIG' THEN date_of_treatment ELSE NULL END AS hbig_vacc_date,
                                            CASE WHEN treatment_name = 'Hepatitis B Dose 1' THEN date_of_treatment ELSE NULL END AS hepb_dose1_date,
                                            CASE WHEN treatment_name = 'Hepatitis B Dose 2' THEN date_of_treatment ELSE NULL END AS hepb_dose2_date,
                                            CASE WHEN treatment_name = 'Hepatitis B Dose 3' THEN date_of_treatment ELSE NULL END AS hepb_dose3_date,
                                            CASE WHEN treatment_name = 'Hepatitis B Dose 4' THEN date_of_treatment ELSE NULL END AS hepb_dose4_date,
                                            CASE WHEN treatment_name = 'Hepatitis B Dose 5' THEN date_of_treatment ELSE NULL END AS hepb_dose5_date,
                                            CASE WHEN treatment_name = 'Hepatitis B Dose 6' THEN date_of_treatment ELSE NULL END AS hepb_dose6_date,
                                            CASE WHEN treatment_name = 'Hepatitis B Dose 7' THEN date_of_treatment ELSE NULL END AS hepb_dose7_date,
                                            CASE WHEN treatment_name = 'Hepatitis B Dose 8' THEN date_of_treatment ELSE NULL END AS hepb_dose8_date,
                                            CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 1' THEN date_of_treatment ELSE NULL END AS hepb_comvax1_date,
                                            CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 2' THEN date_of_treatment ELSE NULL END AS hepb_comvax2_date,
                                            CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 3' THEN date_of_treatment ELSE NULL END AS hepb_comvax3_date,
                                            CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 4' THEN date_of_treatment ELSE NULL END AS hepb_comvax4_date,
                                            CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 5' THEN date_of_treatment ELSE NULL END AS hepb_comvax5_date,
                                            CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 6' THEN date_of_treatment ELSE NULL END AS hepb_comvax6_date,
                                            CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 7' THEN date_of_treatment ELSE NULL END AS hepb_comvax7_date,
                                            CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 8' THEN date_of_treatment ELSE NULL END AS hepb_comvax8_date
                                        FROM
                                            trisano.dw_contact_treatments_events_view dct
                                    ) treatments_split
                                    GROUP BY 1
                                ) treatments_agg
                                    ON (treatments_agg.contact_event_id = dce.id)
-- XXX
--                            WHERE
--                                disposition NOT LIKE 'Closed:%'
                                -- disposition = 'Active follow up'
                        ) foo
                        WHERE fdd_act_code != -1
                    ) contact_stuff
                        ON (name_addr.id = contact_stuff.parent_id)
;

-- Program report
CREATE TABLE report4 AS
                SELECT
                    dme.id, dce.id AS contact_id, dce.record_number,
                    dme.investigating_jurisdiction,
                    COALESCE(dce.birth_date, dme.actual_delivery_date) AS actual_delivery_date,
                    1 AS total,
                    contact_type,
                    disposition,
                    -- XXX Should this be changed to support other dispositions? Probably...
                    CASE WHEN contact_type = 'Infant' AND disposition IN (
                        'Closed: Transferred to another state',
                        'Closed: Left state (unable to transfer)',
                        'Closed: Moved out of country'
                    ) THEN 1 ELSE 0 END AS out_of_jurisdiction,
                    CASE WHEN contact_type = 'Infant' THEN 1 ELSE 0 END AS infant_contacts,

                    -- Here, "24 hours" means the same day. If a dose is given
                    -- on a different date, it could be > 24 hours between
                    -- birth and dosage, which isn't how they want these
                    -- reports
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date = dce.birth_date OR
                            hepb_comvax1_date = dce.birth_date
                        ) AND
                        hbig_vacc_date = dce.birth_date THEN 1 ELSE 0
                    END AS both_24,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date = dce.birth_date OR
                            hepb_comvax1_date = dce.birth_date
                        ) AND (
                            hbig_vacc_date != dce.birth_date OR
                            hbig_vacc_date IS NULL
                        ) THEN 1 ELSE 0
                    END AS dose1_24,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date != dce.birth_date) AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date != dce.birth_date)
                        ) AND
                        hbig_vacc_date = dce.birth_date THEN 1 ELSE 0
                    END AS hbig_24,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date != dce.birth_date) AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date != dce.birth_date) AND
                            (hbig_vacc_date IS NULL OR hbig_vacc_date != dce.birth_date)
                        ) THEN 1 ELSE 0
                    END AS neither_24,

                    -- Same applies here as for 24 hours -- the next day counts
                    -- as 48 hours, but two days ahead is too long.
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date <= dce.birth_date + interval '1 day' OR
                            hepb_comvax1_date <= dce.birth_date + interval '1 day'
                        ) AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '1 day' THEN 1 ELSE 0
                    END AS both_48,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date <= dce.birth_date + interval '1 day' OR
                            hepb_comvax1_date <= dce.birth_date + interval '1 day'
                        ) AND (
                            hbig_vacc_date > dce.birth_date + INTERVAL '1 day' OR
                            hbig_vacc_date IS NULL
                        ) THEN 1 ELSE 0
                    END AS dose1_48,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date > dce.birth_date + interval '1 day') AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date > dce.birth_date + interval '1 day')
                        ) AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '1 day' THEN 1 ELSE 0
                    END AS hbig_48,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date > dce.birth_date + interval '1 day') AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date > dce.birth_date + interval '1 day') AND
                            (hbig_vacc_date IS NULL OR hbig_vacc_date > dce.birth_date + interval '1 day')
                        ) THEN 1 ELSE 0
                    END AS neither_48,

                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date <= dce.birth_date + interval '7 days' OR
                            hepb_comvax1_date <= dce.birth_date + interval '7 days'
                        ) AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '7 days' THEN 1 ELSE 0
                    END AS both_7d,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date <= dce.birth_date + interval '7 days' OR
                            hepb_comvax1_date <= dce.birth_date + interval '7 days'
                        ) AND (
                            hbig_vacc_date > dce.birth_date + INTERVAL '7 days' OR
                            hbig_vacc_date IS NULL
                        ) THEN 1 ELSE 0
                    END AS dose1_7d,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date > dce.birth_date + interval '7 days') AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date > dce.birth_date + interval '7 days')
                        ) AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '7 days' THEN 1 ELSE 0
                    END AS hbig_7d,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date > dce.birth_date + interval '7 days') AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date > dce.birth_date + interval '7 days') AND
                            (hbig_vacc_date IS NULL OR hbig_vacc_date > dce.birth_date + interval '7 days')
                        ) THEN 1 ELSE 0
                    END AS neither_7d,

                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date <= dce.birth_date + interval '2 months' OR
                            hepb_comvax1_date <= dce.birth_date + interval '2 months'
                        ) AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '2 months' THEN 1 ELSE 0
                    END AS both_2m,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date <= dce.birth_date + interval '2 months' OR
                            hepb_comvax1_date <= dce.birth_date + interval '2 months'
                        ) AND (
                            hbig_vacc_date > dce.birth_date + INTERVAL '2 months' OR
                            hbig_vacc_date IS NULL
                        ) THEN 1 ELSE 0
                    END AS dose1_2m,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date > dce.birth_date + interval '2 months') AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date > dce.birth_date + interval '2 months')
                        ) AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '2 months' THEN 1 ELSE 0
                    END AS hbig_2m,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date > dce.birth_date + interval '2 months') AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date > dce.birth_date + interval '2 months') AND
                            (hbig_vacc_date IS NULL OR hbig_vacc_date > dce.birth_date + interval '2 months')
                        ) THEN 1 ELSE 0
                    END AS neither_2m,

                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date <= dce.birth_date + interval '8 months' OR
                            hepb_comvax1_date <= dce.birth_date + interval '8 months'
                        ) AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '8 months' THEN 1 ELSE 0
                    END AS both_8m,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date <= dce.birth_date + interval '8 months' OR
                            hepb_comvax1_date <= dce.birth_date + interval '8 months'
                        ) AND (
                            hbig_vacc_date > dce.birth_date + INTERVAL '8 months' OR
                            hbig_vacc_date IS NULL
                        ) THEN 1 ELSE 0
                    END AS dose1_8m,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date > dce.birth_date + interval '8 months') AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date > dce.birth_date + interval '8 months')
                        ) AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '8 months' THEN 1 ELSE 0
                    END AS hbig_8m,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date > dce.birth_date + interval '8 months') AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date > dce.birth_date + interval '8 months') AND
                            (hbig_vacc_date IS NULL OR hbig_vacc_date > dce.birth_date + interval '8 months')
                        ) THEN 1 ELSE 0
                    END AS neither_8m,

                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date <= dce.birth_date + interval '12 months' OR
                            hepb_comvax1_date <= dce.birth_date + interval '12 months'
                        ) AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '12 months' THEN 1 ELSE 0
                    END AS both_12m,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            hepb_dose1_date <= dce.birth_date + interval '12 months' OR
                            hepb_comvax1_date <= dce.birth_date + interval '12 months'
                        ) AND (
                            hbig_vacc_date > dce.birth_date + INTERVAL '12 months' OR
                            hbig_vacc_date IS NULL
                        ) THEN 1 ELSE 0
                    END AS dose1_12m,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date > dce.birth_date + interval '12 months') AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date > dce.birth_date + interval '12 months')
                        ) AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '12 months' THEN 1 ELSE 0
                    END AS hbig_12m,
                    CASE WHEN
                        contact_type = 'Infant' AND
                        (
                            (hepb_dose1_date IS NULL OR hepb_dose1_date > dce.birth_date + interval '12 months') AND
                            (hepb_comvax1_date IS NULL OR hepb_comvax1_date > dce.birth_date + interval '12 months') AND
                            (hbig_vacc_date IS NULL OR hbig_vacc_date > dce.birth_date + interval '12 months')
                        ) THEN 1 ELSE 0
                    END AS neither_12m,

                    CASE WHEN contact_type = 'Infant' AND treatments_agg.total_doses >= 1 THEN 1 ELSE 0 END AS one_dose,
                    CASE WHEN contact_type = 'Infant' AND treatments_agg.total_doses >= 2 THEN 1 ELSE 0 END AS two_dose,
                    CASE WHEN contact_type = 'Infant' AND treatments_agg.total_doses >= 3 THEN 1 ELSE 0 END AS three_dose,
                    CASE WHEN contact_type = 'Infant' AND treatments_agg.total_doses >= 4 THEN 1 ELSE 0 END AS four_dose,
                    CASE WHEN contact_type = 'Infant' AND treatments_agg.total_doses >= 5 THEN 1 ELSE 0 END AS five_dose,
                    CASE WHEN contact_type = 'Infant' AND treatments_agg.total_doses >= 6 THEN 1 ELSE 0 END AS six_dose,
                    CASE WHEN contact_type = 'Infant' AND hbig_vacc_date IS NOT NULL THEN 1 ELSE 0 END AS recvd_hbig,
                    CASE WHEN
                        contact_type = 'Infant' AND (
                            (trisano.get_contact_hbsag_before(dce.id, NULL)).lab_test_date <=
                                dce.birth_date + INTERVAL '12 months' OR
                            (trisano.get_contact_antihb_after(dce.id, NULL)).lab_test_date <=
                                dce.birth_date + INTERVAL '12 months'
                        )
                    THEN 1 ELSE 0 END AS serotest_12m,
                    CASE WHEN
                        contact_type = 'Infant' AND (
                            (trisano.get_contact_hbsag_before(dce.id, NULL)).lab_test_date <=
                                dce.birth_date + INTERVAL '15 months' OR
                            (trisano.get_contact_antihb_after(dce.id, NULL)).lab_test_date <=
                                dce.birth_date + INTERVAL '15 months'
                        )
                    THEN 1 ELSE 0 END AS serotest_15m,
                    CASE WHEN contact_type = 'Infant' AND ((trisano.get_contact_hbsag_after(dce.id, NULL)).lab_test_date IS NOT NULL OR (trisano.get_contact_antihb_after(dce.id, NULL)).lab_test_date IS NOT NULL) THEN 1 ELSE 0 END AS total_serotest,
                    CASE WHEN contact_type = 'Infant' AND (trisano.get_contact_antihb_after(dce.id, NULL)).test_result ~ 'Positive / Reactive' THEN 1 ELSE 0 END AS positive_antihb,
                    CASE WHEN contact_type = 'Infant' AND (trisano.get_contact_hbsag_after(dce.id, NULL)).test_result ~ 'Positive / Reactive' THEN 1 ELSE 0 END AS positive_hbsag,
                    CASE
                        WHEN contact_type = 'Infant' AND
                        (
                            hepb_comvax1_date IS NOT NULL OR
                            hepb_comvax2_date IS NOT NULL OR
                            hepb_comvax3_date IS NOT NULL OR
                            hepb_comvax4_date IS NOT NULL
                        )
                        THEN 1
                        ELSE 0
                    END AS received_comvax,
                    CASE WHEN contact_type != 'Infant' THEN 1 ELSE 0 END AS total_hs,
                    CASE WHEN contact_type != 'Infant' AND disposition = 'Completed' THEN 1 ELSE 0 END AS completed_hs,
                    CASE WHEN contact_type != 'Infant' AND disposition = 'False positive mother/case' THEN 1 ELSE 0 END AS false_positive_hs,
                    CASE WHEN contact_type != 'Infant' AND disposition IN (
                        'Closed: Transferred to another state',
                        'Closed: Left state (unable to transfer)',
                        'Closed: Moved out of country'
                    ) THEN 1 ELSE 0 END AS out_of_jurisdiction_hs,
                    CASE WHEN contact_type != 'Infant' AND disposition IN ('Provider refusal', 'Mother/family refusal') THEN 1 ELSE 0 END AS refused_hs,
                    CASE WHEN contact_type != 'Infant' AND disposition = 'Unable to locate' THEN 1 ELSE 0 END AS unable_to_locate_hs,
                    CASE WHEN contact_type != 'Infant' AND disposition = 'Other' THEN 1 ELSE 0 END AS other_hs,
                    CASE WHEN contact_type != 'Infant' AND disposition IS NULL THEN 1 ELSE 0 END AS disposition_blank_hs,
                    CASE WHEN
                        contact_type != 'Infant' AND
                        (
                            (trisano.get_contact_hbsag_before(dce.id, NULL)).test_result IS NOT NULL OR
                            (trisano.get_contact_antihb_before(dce.id, NULL)).test_result IS NOT NULL
                        )
                        THEN 1 ELSE 0 END AS total_hs_tested,
                    CASE WHEN contact_type != 'Infant' AND (trisano.get_contact_hbsag_before(dce.id, NULL)).test_result ~ 'Positive / Reactive' THEN 1 ELSE 0 END AS hbsag_pos_hs,
                    CASE WHEN contact_type != 'Infant' AND (trisano.get_contact_antihb_before(dce.id, NULL)).test_result ~ 'Positive / Reactive' THEN 1 ELSE 0 END AS antihb_pos_hs,
                    CASE WHEN contact_type != 'Infant' AND treatments_agg.total_doses >= 1 THEN 1 ELSE 0 END AS dose1_hs,
                    CASE WHEN contact_type != 'Infant' AND treatments_agg.total_doses >= 2 THEN 1 ELSE 0 END AS dose2_hs,
                    CASE WHEN contact_type != 'Infant' AND treatments_agg.total_doses >= 3 THEN 1 ELSE 0 END AS dose3_hs,
                    CASE WHEN contact_type != 'Infant' AND treatments_agg.total_doses >= 4 THEN 1 ELSE 0 END AS dose4_hs,
                    CASE WHEN contact_type != 'Infant' AND treatments_agg.total_doses >= 5 THEN 1 ELSE 0 END AS dose5_hs,
                    CASE WHEN contact_type != 'Infant' AND treatments_agg.total_doses >= 6 THEN 1 ELSE 0 END AS dose6_hs,
                    CASE WHEN contact_type = 'Infant' AND disposition IN (
                        'Closed: Transferred to another state',
                        'Closed: Left state (unable to transfer)',
                        'Closed: Moved out of country'
                    ) AND (hepb_dose1_date IS NOT NULL OR hepb_comvax1_date IS NOT NULL) AND hbig_vacc_date IS NOT NULL THEN 1 ELSE 0 END AS dose1_hbig_trans,
                    CASE WHEN contact_type = 'Infant' AND disposition IN (
                        'Closed: Transferred to another state',
                        'Closed: Left state (unable to transfer)',
                        'Closed: Moved out of country'
                    ) AND hepb_dose1_date IS NULL AND hepb_comvax1_date IS NULL AND hbig_vacc_date IS NOT NULL THEN 1 ELSE 0 END AS hbig_trans,
                    CASE WHEN contact_type = 'Infant' AND disposition IN (
                        'Closed: Transferred to another state',
                        'Closed: Left state (unable to transfer)',
                        'Closed: Moved out of country'
                    ) AND (hepb_dose1_date IS NOT NULL OR hepb_comvax1_date IS NOT NULL) AND hbig_vacc_date IS NULL THEN 1 ELSE 0 END AS dose1_trans,
                    CASE WHEN contact_type = 'Infant' AND disposition IN (
                        'Closed: Transferred to another state',
                        'Closed: Left state (unable to transfer)',
                        'Closed: Moved out of country'
                    ) AND hepb_dose1_date IS NULL AND hepb_comvax1_date IS NULL AND hbig_vacc_date IS NULL THEN 1 ELSE 0 END AS neither_trans,
                    CASE WHEN contact_type = 'Infant' AND
                        disposition IN (
                            'Closed: Transferred to another state',
                            'Closed: Left state (unable to transfer)',
                            'Closed: Moved out of country'
                        ) AND
                        (hepb_dose1_date <= dce.birth_date + INTERVAL '8 months' OR hepb_comvax1_date <= dce.birth_date + INTERVAL '8 months') AND
                        (hepb_dose2_date <= dce.birth_date + INTERVAL '8 months' OR hepb_comvax2_date <= dce.birth_date + INTERVAL '8 months') AND
                        (hepb_dose3_date <= dce.birth_date + INTERVAL '8 months' OR hepb_comvax4_date <= dce.birth_date + INTERVAL '8 months') AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '8 months'
                        THEN 1 ELSE 0
                    END AS all_8m_trans,
                    CASE WHEN contact_type = 'Infant' AND
                        disposition IN (
                            'Closed: Transferred to another state',
                            'Closed: Left state (unable to transfer)',
                            'Closed: Moved out of country'
                        ) AND
                        (hepb_dose1_date <= dce.birth_date + INTERVAL '12 months' OR hepb_comvax1_date <= dce.birth_date + INTERVAL '12 months') AND
                        (hepb_dose2_date <= dce.birth_date + INTERVAL '12 months' OR hepb_comvax2_date <= dce.birth_date + INTERVAL '12 months') AND
                        (hepb_dose3_date <= dce.birth_date + INTERVAL '12 months' OR hepb_comvax4_date <= dce.birth_date + INTERVAL '12 months') AND
                        hbig_vacc_date <= dce.birth_date + INTERVAL '12 months'
                        THEN 1 ELSE 0
                    END AS all_12m_trans
                FROM
                    trisano.dw_contact_events_view dce
                    JOIN trisano.dw_morbidity_events_view dme
                        ON (dce.parent_id = dme.id)
                    LEFT JOIN (
                        SELECT
                            CASE WHEN hepb_dose1_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_dose2_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_dose3_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_dose4_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_dose5_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_dose6_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_comvax1_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_comvax2_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_comvax3_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_comvax4_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_comvax5_date IS NULL THEN 0 ELSE 1 END +
                            CASE WHEN hepb_comvax6_date IS NULL THEN 0 ELSE 1 END
                                AS total_doses,
                            *
                        FROM (
                            SELECT
                                dw_contact_events_id AS contact_event_id,
                                trisano.earliest_date(trisano.array_accum(hbig_vacc_date )) AS hbig_vacc_date,
                                trisano.earliest_date(trisano.array_accum(hepb_dose1_date)) AS hepb_dose1_date,
                                trisano.earliest_date(trisano.array_accum(hepb_dose2_date)) AS hepb_dose2_date,
                                trisano.earliest_date(trisano.array_accum(hepb_dose3_date)) AS hepb_dose3_date,
                                trisano.earliest_date(trisano.array_accum(hepb_dose4_date)) AS hepb_dose4_date,
                                trisano.earliest_date(trisano.array_accum(hepb_dose5_date)) AS hepb_dose5_date,
                                trisano.earliest_date(trisano.array_accum(hepb_dose6_date)) AS hepb_dose6_date,
                                trisano.earliest_date(trisano.array_accum(hepb_comvax1_date)) AS hepb_comvax1_date,
                                trisano.earliest_date(trisano.array_accum(hepb_comvax2_date)) AS hepb_comvax2_date,
                                trisano.earliest_date(trisano.array_accum(hepb_comvax3_date)) AS hepb_comvax3_date,
                                trisano.earliest_date(trisano.array_accum(hepb_comvax4_date)) AS hepb_comvax4_date,
                                trisano.earliest_date(trisano.array_accum(hepb_comvax5_date)) AS hepb_comvax5_date,
                                trisano.earliest_date(trisano.array_accum(hepb_comvax6_date)) AS hepb_comvax6_date
                            FROM (
                                SELECT
                                    dw_contact_events_id,
                                    CASE WHEN treatment_name = 'HBIG' THEN date_of_treatment ELSE NULL END AS hbig_vacc_date,
                                    CASE WHEN treatment_name = 'Hepatitis B Dose 1' THEN date_of_treatment ELSE NULL END AS hepb_dose1_date,
                                    CASE WHEN treatment_name = 'Hepatitis B Dose 2' THEN date_of_treatment ELSE NULL END AS hepb_dose2_date,
                                    CASE WHEN treatment_name = 'Hepatitis B Dose 3' THEN date_of_treatment ELSE NULL END AS hepb_dose3_date,
                                    CASE WHEN treatment_name = 'Hepatitis B Dose 4' THEN date_of_treatment ELSE NULL END AS hepb_dose4_date,
                                    CASE WHEN treatment_name = 'Hepatitis B Dose 5' THEN date_of_treatment ELSE NULL END AS hepb_dose5_date,
                                    CASE WHEN treatment_name = 'Hepatitis B Dose 6' THEN date_of_treatment ELSE NULL END AS hepb_dose6_date,
                                    CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 1' THEN date_of_treatment ELSE NULL END AS hepb_comvax1_date,
                                    CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 2' THEN date_of_treatment ELSE NULL END AS hepb_comvax2_date,
                                    CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 3' THEN date_of_treatment ELSE NULL END AS hepb_comvax3_date,
                                    CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 4' THEN date_of_treatment ELSE NULL END AS hepb_comvax4_date,
                                    CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 5' THEN date_of_treatment ELSE NULL END AS hepb_comvax5_date,
                                    CASE WHEN treatment_name = 'Hepatitis B - Comvax Dose 6' THEN date_of_treatment ELSE NULL END AS hepb_comvax6_date
                                FROM
                                    trisano.dw_contact_treatments_events_view dct
                            ) treatments_split
                                GROUP BY 1
                        ) treatment_1
                    ) treatments_agg
                        ON (treatments_agg.contact_event_id = dce.id)
                WHERE
                    dme.disease_name = 'Hepatitis B Pregnancy Event' AND
                    (
                        dce.birth_date IS NOT NULL OR
                        dce.contact_type != 'Infant'
                    )
;

CREATE TABLE morb_sec_juris AS
    SELECT dw_morbidity_events_id, name FROM trisano.dw_morbidity_secondary_jurisdictions_view;

CREATE TABLE juris AS
    SELECT name AS investigating_jurisdiction
    FROM
        trisano.places_view p
        JOIN trisano.places_types_view pt
            ON (pt.place_id = p.id)
        JOIN trisano.codes_view c
            ON (c.id = pt.type_id)
    WHERE c.code_description = 'Jurisdiction';

GRANT SELECT ON report1 TO trisano_ro;
GRANT SELECT ON report2 TO trisano_ro;
GRANT SELECT ON report3 TO trisano_ro;
GRANT SELECT ON report4 TO trisano_ro;
GRANT SELECT ON morb_sec_juris TO trisano_ro;
GRANT SELECT ON juris TO trisano_ro;
GRANT SELECT ON dispositions TO trisano_ro;

COMMIT;
