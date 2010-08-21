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

SET search_path = staging, public;

ALTER TABLE dw_morbidity_events
    ADD expected_delivery_facility TEXT, 
    ADD expected_delivery_facility_type TEXT, 
    ADD expected_delivery_facility_phone TEXT,
    ADD actual_delivery_facility TEXT,
    ADD actual_delivery_facility_type TEXT, 
    ADD actual_delivery_facility_phone TEXT,
    ADD actual_delivery_date DATE;

UPDATE dw_morbidity_events dme SET
    expected_delivery_facility = edf.name,
    expected_delivery_facility_type = edf.types,
    expected_delivery_facility_phone = det.phones
    FROM
        participations par
	INNER JOIN (
            SELECT
                places.entity_id,
                places.name,
                trisano.text_join_agg(codes.code_description, ', ') AS types
            FROM
                places
                LEFT JOIN places_types pt
                    ON (pt.place_id = places.id)
                LEFT JOIN codes
                    ON (codes.id = pt.type_id)
            GROUP BY
                places.entity_id, places.name
        ) edf
            ON (edf.entity_id = par.secondary_entity_id)
        LEFT JOIN dw_entity_telephones det
            ON (det.entity_id = par.secondary_entity_id)
    WHERE
        par.event_id = dme.id AND
        par.type = 'ExpectedDeliveryFacility' AND
        edf.entity_id = par.secondary_entity_id
;

UPDATE dw_morbidity_events dme SET
    actual_delivery_facility = adf.name,
    actual_delivery_date = adfp.actual_delivery_date,
    actual_delivery_facility_type = adf.types,
    actual_delivery_facility_phone = det.phones
    FROM
        participations par
        LEFT JOIN actual_delivery_facilities_participations adfp
            ON (adfp.participation_id = par.id)
        LEFT JOIN (
            SELECT
                places.entity_id,
                places.name,
                trisano.text_join_agg(codes.code_description, ', ') AS types
            FROM
                places
                LEFT JOIN places_types pt
                    ON (pt.place_id = places.id)
                LEFT JOIN codes
                    ON (codes.id = pt.type_id)
            GROUP BY
                places.entity_id, places.name
        ) adf
            ON (adf.entity_id = par.secondary_entity_id)
        LEFT JOIN dw_entity_telephones det
            ON (det.entity_id = par.secondary_entity_id)
    WHERE
        par.event_id = dme.id AND
        par.type = 'ActualDeliveryFacility' AND
        (
            adf.entity_id = par.secondary_entity_id OR
            adf.entity_id IS NULL
        )
;

COMMIT;
