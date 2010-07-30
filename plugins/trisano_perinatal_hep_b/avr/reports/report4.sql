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
