-- Report 2
SELECT
        trisano.make_date('${START_DATE}', '1900-01-01'::DATE) AS start,
        trisano.make_date('${END_DATE}'  , '2900-01-01'::DATE) AS end,
         -- Which date do we want to use for this?
        EXTRACT(year FROM date_entered_into_system) AS year,
        SUM(prospective_infants) AS prospective_infants,
        SUM(retrospective_infants) AS retrospective_infants,
        COUNT(*) AS identified_subtotal,
        SUM(contact_infants) AS contact_infants,
        COUNT(*) AS high_risk,
        SUM(currently_active) AS currently_active
        -- From what I see of the report definition, identified_subtotal and
        -- high_risk will always be the same
    FROM
        (
            SELECT
                date_entered_into_system,
                CASE
                    WHEN pregnancy_due_date IS NOT NULL THEN 1
                    ELSE 0
                END AS prospective_infants,
                CASE
                    WHEN pregnancy_due_date IS NULL THEN 1
                    ELSE 0
                END AS retrospective_infants,
                CASE
                    WHEN EXISTS (
                        SELECT 1 FROM trisano.dw_contact_events_view c
                        WHERE dmev.id = c.id AND contact_type = 'Newborn'
                        -- This "contact_type = 'Newborn'" is probably not what we want
                    ) THEN 1
                    ELSE 0
                END AS contact_infants,
                CASE
                    WHEN 'perinatal-prevention-status-date' IS NULL THEN 1
                    -- This is also probably not what we want
                    ELSE 0
                END AS currently_active
            FROM
                trisano.dw_morbidity_events_view dmev
            WHERE
                -- This again may not be what we want
                disease_name ~ 'Hepatitis' AND
                pregnant = 'Yes' AND
                -- This definitely isn't what we want, but we don't yet have the
                -- actual delivery date field
                'actual-delivery-date' IS NOT NULL AND
               -- Which date do we use for this?
               -- Using ::TEXT to cause bad logic and prevent Pentaho errors
               date_entered_into_system BETWEEN trisano.make_date('${START_DATE}', '1900-01-01'::DATE)
 AND trisano.make_date('${END_DATE}', '2300-01-01'::DATE)
        ) foo
    GROUP BY 1, 2, 3
    ORDER BY 3 ASC
;


-- Report 3
-- Requires a subreport

-- Main query:
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
    , ', ')
FROM
    trisano.dw_morbidity_events_view dme
    LEFT JOIN trisano.dw_morbidity_telephones_view dt
        ON (dme.patient_entity_id = dt.entity_id)
WHERE
    dme.disease_name IN ('Hepatitis B, acute', 'Hepatitis B virus infection, chronic') AND
    dme.pregnant = 'Yes'
GROUP BY
    id, name, address
;

-- Report 3, subreport
SELECT
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
        -- XXX Replace NOW() with hepb_dose1_date
        WHEN fdd_act_code = 10 THEN NOW() + (INTERVAL '30 days' * 1)
        -- XXX Replace NOW() with hepb_dose1_date
        WHEN fdd_act_code = 11 THEN NOW() + (INTERVAL '30 days' * 6)
        -- XXX Replace NOW() with hepb_dose3_date
        WHEN fdd_act_code = 12 THEN NOW() + (INTERVAL '30 days' * 1)
        WHEN fdd_act_code = 13 THEN now()::DATE
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
        dce.contact_type,
        COALESCE(dce.first_name || ' ', '') || COALESCE(dce.middle_name || ' ', '') || COALESCE(dce.last_name, '') AS name,
        dce.birth_date,
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
        -- XXX Using fake fields:
        --          'hbig_vaccination_date'
        --          'hepb_dose1_date'
        --          'hepb_dose2_date'
        --          'hepb_dose3_date'
        --          'post_immun_hbsag'
        --          'pre_immun_hbsag_date'
        --          'pre_immun_hbsag_result'
        --          'anti_hbs_date'
        --          'anti_hbs_result'
            WHEN dce.contact_type = 'Newborn' THEN
                CASE
                    WHEN 'hbig_vaccination_date' IS NULL AND 'hepb_dose1_date' IS NULL THEN
                        1 -- fdd = dob, act = 'Needs HBIG and Vaccine #1'
                    WHEN 'hbig_vaccination_date' IS NOT NULL AND 'hepb_dose1_date' IS NULL THEN
                        2 -- fdd = dob, act = 'Needs Vaccine #1'
                    WHEN 'hbig_vaccination_date' IS NULL AND 'hepb_dose1_date' IS NOT NULL THEN
                        3 -- fdd = dob, act = 'Needs HBIG'
                    WHEN 'hbig_vaccination_date' IS NOT NULL AND 'hepb_dose1_date' IS NOT NULL AND 'hepb_dose2_date' IS NULL THEN
                        4 -- fdd = dob + 1 mo., act = 'Needs Vaccine #2'
                    WHEN 'hbig_vaccination_date' IS NOT NULL AND 'hepb_dose1_date' IS NOT NULL AND 'hepb_dose2_date' IS NOT NULL AND 'hepb_dose3_date' IS NULL THEN
                        5 -- fdd = dob + 6 mo., act = 'Needs 6-month vaccine dose'
                    WHEN COALESCE(
                            (now() - dce.birth_date) BETWEEN (interval '30 days' * 9) AND (interval '30 days' * 18),
                            dce.age_in_years BETWEEN .6 AND 1.5
                        ) THEN
                        6 -- fdd = dob + 9 mo., act = 'Needs serology 3 months after 9-month dose'
                    WHEN COALESCE((now() - dce.birth_date) >= INTERVAL '365 days' * 2, dce.age_in_years >= 2) THEN
                        7 -- fdd = dob + 24 mo., act = 'Close Newborn Contact'
                    ELSE
                        -1 -- XXX What do we do here?
                END
            ELSE -- Not a newborn contact
                CASE
                    WHEN 'pre_immun_hbsag_date' IS NULL OR 'anti_hbs_date' IS NULL THEN
                        8 -- fdd = report date, act = 'Needs Pre-Immunization Serology'
                    -- XXX Replace hardcoded 'F' with pre_immun_hbsag_result and anti_hbs_result
                    WHEN 'hepb_dose1_date' IS NULL AND NOT 'F'::BOOLEAN AND NOT 'F'::BOOLEAN THEN
                        9 -- fdd = report date, act = 'Needs Vaccine #1'
                    -- XXX Replace hardcoded 'F' with pre_immun_hbsag_result and anti_hbs_result
                    WHEN 'hepb_dose1_date' IS NOT NULL AND 'hepb_dose2_date' IS NULL AND NOT 'F'::BOOLEAN AND NOT 'F'::BOOLEAN THEN
                        10 -- fdd = 'hepb_dose1_date' + 1 mo., act = 'Needs Vaccine #2'
                    -- XXX Replace hardcoded 'F' with pre_immun_hbsag_result and anti_hbs_result
                    WHEN 'hepb_dose1_date' IS NOT NULL AND 'hepb_dose2_date' IS NOT NULL AND 'hepb_dose3_date' IS NULL AND NOT 'F'::BOOLEAN AND NOT 'F'::BOOLEAN THEN
                        11 -- fdd = 'hepb_dose1_date' + 6 mo., act = 'Needs Vaccine #3'
                    -- XXX Replace hardcoded 'F' with pre_immun_hbsag_result and anti_hbs_result
                    WHEN 'hepb_dose1_date' IS NOT NULL AND 'hepb_dose2_date' IS NOT NULL AND 'hepb_dose3_date' IS NOT NULL AND NOT 'F'::BOOLEAN AND NOT 'F'::BOOLEAN THEN
                        12 -- fdd = 'hepb_dose3_date' + 1 mo., act = 'Needs Post Immunization Serology'
                    WHEN 'perinatal_prevention_status_date' IS NOT NULL THEN -- XXX This should probably be the *firt* non-newborn check
                        13 -- fdd = report date, act = 'Close Contact'
                    ELSE
                        -1 -- XXX What do we do here?
                END
        END AS fdd_act_code
    FROM
        trisano.dw_contact_events_view dce
    WHERE
        -- XXX NOT CLOSED?
        parent_id = 1 -- XXX ${outer_query_parent_id}
    ) foo
;



-- second version:
-- Report 3
-- Does not require a subreport

SELECT
    name_addr.id,
    name_addr.name,
    name_addr.address,
    name_addr.phone,
    contact_stuff.contact_type,
    contact_stuff.name AS contact_name,
    contact_stuff.birth_date AS contact_birth_date,
    contact_stuff.age AS contact_age,
    contact_stuff.first_due_date,
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
                -- XXX Replace NOW() with hepb_dose1_date
                WHEN fdd_act_code = 10 THEN NOW() + (INTERVAL '30 days' * 1)
                -- XXX Replace NOW() with hepb_dose1_date
                WHEN fdd_act_code = 11 THEN NOW() + (INTERVAL '30 days' * 6)
                -- XXX Replace NOW() with hepb_dose3_date
                WHEN fdd_act_code = 12 THEN NOW() + (INTERVAL '30 days' * 1)
                WHEN fdd_act_code = 13 THEN now()::DATE
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
                COALESCE(dce.first_name || ' ', '') || COALESCE(dce.middle_name || ' ', '') || COALESCE(dce.last_name, '') AS name,
                dce.birth_date,
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
                -- XXX Using fake fields:
                --          'hbig_vaccination_date'
                --          'hepb_dose1_date'
                --          'hepb_dose2_date'
                --          'hepb_dose3_date'
                --          'post_immun_hbsag'
                --          'pre_immun_hbsag_date'
                --          'pre_immun_hbsag_result'
                --          'anti_hbs_date'
                --          'anti_hbs_result'
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
                            WHEN COALESCE(
                                    (now() - dce.birth_date) BETWEEN (interval '30 days' * 9) AND (interval '30 days' * 18),
                                    dce.age_in_years BETWEEN .6 AND 1.5
                                ) THEN
                                6 -- fdd = dob + 9 mo., act = 'Needs serology 3 months after 9-month dose'
                            WHEN COALESCE((now() - dce.birth_date) >= INTERVAL '365 days' * 2, dce.age_in_years >= 2) THEN
                                7 -- fdd = dob + 24 mo., act = 'Close Newborn Contact'
                            ELSE
                                -1 -- XXX What do we do here?
                        END
                    ELSE -- Not a newborn contact
                        CASE
                            WHEN 'pre_immun_hbsag_date' IS NULL OR 'anti_hbs_date' IS NULL THEN
                                8 -- fdd = report date, act = 'Needs Pre-Immunization Serology'
                                -- XXX Check out logic here
                            WHEN hepb_dose1_date IS NULL AND 'pre_immun_hbsag_result' != 'Positive' AND 'anti_hbs_result' != 'Positive' THEN
                                9 -- fdd = report date, act = 'Needs Vaccine #1'
                            WHEN hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NULL AND 'pre_immun_hbsag_result' != 'Positive' AND 'anti_hbs_result' != 'Positive' THEN
                                10 -- fdd = 'hepb_dose1_date' + 1 mo., act = 'Needs Vaccine #2'
                            WHEN hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NULL AND 'pre_immun_hbsag_result' != 'Positive' AND 'anti_hbs_result' != 'Positive' THEN
                                11 -- fdd = 'hepb_dose1_date' + 6 mo., act = 'Needs Vaccine #3'
                            -- XXX Replace hardcoded 'F' with pre_immun_hbsag_result and anti_hbs_result
                            WHEN hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NOT NULL AND 'pre_immun_hbsag_result' != 'Positive' AND 'anti_hbs_result' != 'Positive' THEN
                                12 -- fdd = 'hepb_dose3_date' + 1 mo., act = 'Needs Post Immunization Serology'
                            WHEN 'perinatal_prevention_status_date' IS NOT NULL THEN -- XXX This should probably be the *firt* non-newborn check
                                13 -- fdd = report date, act = 'Close Contact'
                            ELSE
                                -1 -- XXX What do we do here?
                        END
                END AS fdd_act_code
            FROM
                trisano.dw_contact_events_view dce
                LEFT JOIN (
                    SELECT
                        dw_contact_events_id AS contact_event_id,
                        trisano.text_join_agg(COALESCE(hbig_vacc_date, ''), '') AS hbig,
                        trisano.text_join_agg(COALESCE(hebp_dose1_date, ''), '') AS hepb_dose1_date,
                        trisano.text_join_agg(COALESCE(hepb_dose2_date, ''), '') AS hepb_dose2_date,
                        trisano.text_join_agg(COALESCE(hepb_dose3_date, ''), '') AS hepb_dose3_date,
                        trisano.text_join_agg(COALESCE(hepb_dose4_date, ''), '') AS hepb_dose4_date,
                        trisano.text_join_agg(COALESCE(hepb_dose5_date, ''), '') AS hepb_dose5_date,
                        trisano.text_join_agg(COALESCE(hepb_dose6_date, ''), '') AS hepb_dose6_date
                    FROM (
                        SELECT
                            dw_contact_events_id,
                            CASE WHEN treatment_name = 'HBIG' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hbig_vacc_date,
                            CASE WHEN treatment_name = 'Hep B Dose 1 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hebp_dose1_date,
                            CASE WHEN treatment_name = 'Hep B Dose 2 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hepb_dose2_date,
                            -- The ~ is intentional
                            CASE WHEN treatment_name ~ 'Hep B Dose 3 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hepb_dose3_date,
                            CASE WHEN treatment_name = 'Hep B Dose 4 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hepb_dose4_date,
                            CASE WHEN treatment_name = 'Hep B Dose 5 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hepb_dose5_date,
                            CASE WHEN treatment_name = 'Hep B Dose 6 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hepb_dose6_date
                        FROM
                            trisano.dw_contact_treatments_events_view dct
                            JOIN trisano.treatments_view tv
                                ON (tv.id = dct.treatment_id)
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

-- Report 4
-- Query 1
SELECT
    COUNT(*) AS total,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition IS NULL THEN 1 ELSE NULL END) AS active,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'completed' THEN 1 ELSE NULL END) AS completed,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'provider refusal' THEN 1 ELSE NULL END) AS provider_refusal,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Mother/family refusal' THEN 1 ELSE NULL END) AS f5,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Moved' THEN 1 ELSE NULL END) AS f6,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Unable to locate' THEN 1 ELSE NULL END) AS f7,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Died' THEN 1 ELSE NULL END) AS f8,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Adopted' THEN 1 ELSE NULL END) AS f9,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'False positive mother/case' THEN 1 ELSE NULL END) AS f10,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Miscarriage or termination' THEN 1 ELSE NULL END) AS f11,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Other' THEN 1 ELSE NULL END) AS f12,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '1 day' AND hbig_vacc_date <= birth_date + INTERVAL '1 day' THEN 1 ELSE NULL END) AS f13,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '1 day' THEN 1 ELSE NULL END) AS f14,
    COUNT(CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= birth_date + INTERVAL '1 day' THEN 1 ELSE NULL END) AS f15,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > birth_date + INTERVAL '1 day' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END) AS f16,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '2 days' AND hbig_vacc_date <= birth_date + INTERVAL '2 days' THEN 1 ELSE NULL END) AS f17,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '2 days' THEN 1 ELSE NULL END) AS f18,
    COUNT(CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= birth_date + interval '2 days' THEN 1 ELSE NULL END) AS f19,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > birth_date + INTERVAL '2 days' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END) AS f20,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '7 days' AND hbig_vacc_date <= birth_date + INTERVAL '7 days' THEN 1 ELSE NULL END) AS f21,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '7 days' THEN 1 ELSE NULL END) AS f22,
    COUNT(CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= birth_date + interval '7 days' THEN 1 ELSE NULL END) AS f23,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > birth_date + INTERVAL '7 days' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END) AS f24,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '2 months' AND hbig_vacc_date <= birth_date + INTERVAL '7 days' THEN 1 ELSE NULL END) AS f25,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '2 months' THEN 1 ELSE NULL END) AS f26,
    COUNT(CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= birth_date + interval '2 months' THEN 1 ELSE NULL END) AS f27,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > birth_date + INTERVAL '2 months' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END) AS f28,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '8 months' AND hbig_vacc_date <= birth_date + INTERVAL '7 days' THEN 1 ELSE NULL END) AS f29,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '8 months' THEN 1 ELSE NULL END) AS f30,
    COUNT(CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= birth_date + interval '8 months' THEN 1 ELSE NULL END) AS f31,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > birth_date + INTERVAL '8 months' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END) AS f32,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '12 months' AND hbig_vacc_date <= birth_date + INTERVAL '7 days' THEN 1 ELSE NULL END) AS f33,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date <= birth_date + interval '12 months' THEN 1 ELSE NULL END) AS f34,
    COUNT(CASE WHEN contact_type = 'infant' AND hbig_vacc_date <= birth_date + interval '12 months' THEN 1 ELSE NULL END) AS f35,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NULL AND (hbig_vacc_date > birth_date + INTERVAL '12 months' OR hbig_vacc_date IS NULL) THEN 1 ELSE NULL END) AS f36,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NOT NULL AND hepb_dose4_date IS NOT NULL THEN 1 ELSE NULL END) AS f37,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NOT NULL AND hepb_dose4_date IS NOT NULL AND hepb_dose5_date IS NOT NULL THEN 1 ELSE NULL END) AS f38,
    COUNT(CASE WHEN contact_type = 'infant' AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NOT NULL AND hepb_dose4_date IS NOT NULL AND hepb_dose5_date IS NOT NULL AND hepb_dose6_date IS NOT NULL THEN 1 ELSE NULL END) AS f39,
    COUNT(CASE WHEN contact_type = 'infant' AND 'post_immun_hbsag_date' <= birth_date + INTERVAL '12 months' AND 'post_immun_antihb_date' <= birth_date + INTERVAL '12 months' THEN 1 ELSE NULL END) AS f40,
    COUNT(CASE WHEN contact_type = 'infant' AND 'post_immun_hbsag_date' <= birth_date + INTERVAL '15 months' AND 'post_immun_antihb_date' <= birth_date + INTERVAL '15 months' THEN 1 ELSE NULL END) AS f41,
    COUNT(CASE WHEN contact_type = 'infant' AND ('post_immun_hbsag_date' IS NULL OR 'post_immun_antihb_date' IS NULL) THEN 1 ELSE NULL END) AS f42,
    COUNT(CASE WHEN contact_type = 'infant' AND 'post_immun_hbsag_result' = 'positive' THEN 1 ELSE NULL END) AS f43,
    COUNT(CASE WHEN contact_type = 'infant' AND 'post_immun_antihb_result' = 'positive' THEN 1 ELSE NULL END) AS f44,
    COUNT(CASE WHEN contact_type = 'infant' AND 'com_vax_vacc_date' IS NOT NULL THEN 1 ELSE NULL END) AS f45,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') THEN 1 ELSE NULL END) AS f46,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition IS NULL THEN 1 ELSE NULL END) AS f47,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Completed' THEN 1 ELSE NULL END) AS f48,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Provider refusal' THEN 1 ELSE NULL END) AS f49,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Refused preventative treatment' THEN 1 ELSE NULL END) AS f50,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Moved' THEN 1 ELSE NULL END) AS f51,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Unable to locate' THEN 1 ELSE NULL END) AS f52,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Died' THEN 1 ELSE NULL END) AS f53,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'False positive mother/case' THEN 1 ELSE NULL END) AS f54,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND disposition = 'Other' THEN 1 ELSE NULL END) AS f55,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND ('pre_immun_hbsag_result' IS NOT NULL OR 'pre_immun_antihb_result' IS NOT NULL) THEN 1 ELSE NULL END) AS f56,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND 'post_immun_hbsag_result' = 'Positive' THEN 1 ELSE NULL END) AS f57,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND 'post_immun_antihb_result' = 'Positive' THEN 1 ELSE NULL END) AS f58,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND hepb_dose1_date IS NOT NULL THEN 1 ELSE NULL END) AS f59,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL THEN 1 ELSE NULL END) AS f60,
    COUNT(CASE WHEN contact_type IN ('Sexual', 'Household') AND hepb_dose1_date IS NOT NULL AND hepb_dose2_date IS NOT NULL AND hepb_dose3_date IS NOT NULL THEN 1 ELSE NULL END) AS f61,
    -- This labels field 62 as '<6>', suggesting it's a copy of field 6.
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date IS NULL AND hbig_vacc_date IS NOT NULL THEN 1 ELSE NULL END) AS f64,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date IS NOT NULL AND hbig_vacc_date IS NULL THEN 1 ELSE NULL END) AS f65,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date IS NULL AND hbig_vacc_date IS NULL THEN 1 ELSE NULL END) AS f66,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date < birth_date + INTERVAL '8 months' AND hepb_dose2_date < birth_date + INTERVAL '8 months' AND hepb_dose3_date < birth_date + INTERVAL '8 months' AND hbig_vacc_date < birth_date + INTERVAL '8 months' THEN 1 ELSE NULL END) AS f67,
    COUNT(CASE WHEN contact_type = 'infant' AND disposition = 'Moved' AND hepb_dose1_date < birth_date + INTERVAL '8 months' AND hepb_dose2_date < birth_date + INTERVAL '12 months' AND hepb_dose3_date < birth_date + INTERVAL '12 months' AND hbig_vacc_date < birth_date + INTERVAL '12 months' THEN 1 ELSE NULL END) AS f68
FROM
    trisano.dw_contact_events_view dce
    LEFT JOIN (
        SELECT
            dw_contact_events_id AS contact_event_id,
            trisano.text_join_agg(COALESCE(hbig_vacc_date, ''), '') AS hbig_vacc_date,
            trisano.text_join_agg(COALESCE(hebp_dose1_date, ''), '') AS hepb_dose1_date,
            trisano.text_join_agg(COALESCE(hepb_dose2_date, ''), '') AS hepb_dose2_date,
            trisano.text_join_agg(COALESCE(hepb_dose3_date, ''), '') AS hepb_dose3_date,
            trisano.text_join_agg(COALESCE(hepb_dose4_date, ''), '') AS hepb_dose4_date,
            trisano.text_join_agg(COALESCE(hepb_dose5_date, ''), '') AS hepb_dose5_date,
            trisano.text_join_agg(COALESCE(hepb_dose6_date, ''), '') AS hepb_dose6_date
        FROM (
            SELECT
                dw_contact_events_id,
                CASE WHEN treatment_name = 'HBIG' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hbig_vacc_date,
                CASE WHEN treatment_name = 'Hep B Dose 1 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hebp_dose1_date,
                CASE WHEN treatment_name = 'Hep B Dose 2 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hepb_dose2_date,
                -- The ~ is intentional
                CASE WHEN treatment_name ~ 'Hep B Dose 3 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hepb_dose3_date,
                CASE WHEN treatment_name = 'Hep B Dose 4 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hepb_dose4_date,
                CASE WHEN treatment_name = 'Hep B Dose 5 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hepb_dose5_date,
                CASE WHEN treatment_name = 'Hep B Dose 6 Vaccination' THEN TO_CHAR(date_of_treatment, 'YYYY-MM-DD') ELSE NULL END AS hepb_dose6_date
            FROM
                trisano.dw_contact_treatments_events_view dct
                JOIN trisano.treatments_view tv
                    ON (tv.id = dct.treatment_id)
            WHERE
                treatment_given = 'Yes'
        ) treatments_split
        GROUP BY 1
    ) treatments_agg
        ON (treatments_agg.contact_event_id = dce.id)
WHERE disease_name = 'Hepatitis B Pregnancy Event'
;
