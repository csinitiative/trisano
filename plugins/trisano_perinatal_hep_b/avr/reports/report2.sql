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
