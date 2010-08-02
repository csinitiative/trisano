-- UPDATE warehouse_b.dw_contact_events set contact_type = 'Noodles' where last_name = 'Williams';
-- UPDATE warehouse_a.dw_contact_events set contact_type = 'Noodles' where last_name = 'Williams';
-- UPDATE warehouse_b.dw_contact_events set contact_type = 'Newborn' where last_name = 'Dodge';
-- UPDATE warehouse_a.dw_contact_events set contact_type = 'Newborn' where last_name = 'Dodge';

-- Report 3
-- Pregnancy Event Action report
-- No longer requires a subreport

SELECT
    name_addr.id,
    name_addr.name,
    name_addr.address,
    name_addr.phone,
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
            , ', ') AS phone
        FROM
            trisano.dw_morbidity_events_view dme
            LEFT JOIN trisano.dw_morbidity_telephones_view dt
                ON (dme.patient_entity_id = dt.entity_id)
        WHERE
            dme.disease_name IN ('Hepatitis B, acute', 'Hepatitis B virus infection, chronic') AND
            dme.pregnant = 'Yes'
        GROUP BY
            id, name, address
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
                WHEN fdd_act_code = 13 THEN hepb_dose3_date
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
                    WHEN dce.contact_type = 'Newborn' THEN
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
                                (get_contact_hbsag_after(dce.id, hepb_dose1_date)).lab_test_date IS NULL
                                    THEN 6 -- fdd = dob + 9 mo., act = 'Needs serology 3 months after 9-month dose'
                            WHEN COALESCE((now() - dce.birth_date) >= INTERVAL '365 days' * 2, dce.age_in_years >= 2) THEN
                                7 -- fdd = dob + 24 mo., act = 'Close Newborn Contact'
                            ELSE
                                -1 -- XXX What do we do here? We can hit this, for instance, if we have all our tests and aren't yet 2 yrs old.
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
                        earliest_date(trisano.array_accum(hbig_vacc_date )) AS hbig,
                        earliest_date(trisano.array_accum(hebp_dose1_date)) AS hepb_dose1_date,
                        earliest_date(trisano.array_accum(hepb_dose2_date)) AS hepb_dose2_date,
                        earliest_date(trisano.array_accum(hepb_dose3_date)) AS hepb_dose3_date,
                        earliest_date(trisano.array_accum(hepb_dose4_date)) AS hepb_dose4_date,
                        earliest_date(trisano.array_accum(hepb_dose5_date)) AS hepb_dose5_date,
                        earliest_date(trisano.array_accum(hepb_dose6_date)) AS hepb_dose6_date
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
                    GROUP BY 1
                ) treatments_agg
                    ON (treatments_agg.contact_event_id = dce.id)
        ) foo
    ) contact_stuff
        ON (name_addr.id = contact_stuff.parent_id)
;

