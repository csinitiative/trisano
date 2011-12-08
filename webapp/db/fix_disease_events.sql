BEGIN;
DELETE FROM disease_events WHERE event_id IS NULL;
DELETE FROM disease_events USING (
    SELECT del_id FROM (
        SELECT id AS del_id, event_id, first_value(id) OVER (PARTITION BY event_id ORDER BY id) AS first
        FROM disease_events
    ) p
    WHERE del_id != first
) q
WHERE id = del_id;
ALTER TABLE disease_events ALTER event_id SET NOT NULL;
CREATE UNIQUE INDEX disease_event_id_uniq ON disease_events (event_id);
COMMIT;
