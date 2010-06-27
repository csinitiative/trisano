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

ALTER TABLE dw_morbidity_events ADD expected_delivery_facility TEXT;

UPDATE dw_morbidity_events
    SET expected_delivery_facility = edf.name
    FROM (
        SELECT par.event_id, pl.name
        FROM
            participations par
            JOIN places pl
                ON (pl.entity_id = par.secondary_entity_id)
        WHERE par.type = 'ExpectedDeliveryFacility'
    ) edf
    WHERE edf.event_id = dw_morbidity_events.id;
COMMIT;
