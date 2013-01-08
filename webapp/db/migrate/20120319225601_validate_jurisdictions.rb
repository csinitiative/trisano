# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
class ValidateJurisdictions < ActiveRecord::Migration
  def self.up
    execute <<-SQL
CREATE OR REPLACE FUNCTION validate_jurisdiction() RETURNS TRIGGER AS $validate_jurisdiction$
DECLARE
    msg TEXT;
    i INTEGER;
BEGIN
    IF NEW.jurisdiction_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM places p
            JOIN places_types pt ON (pt.place_id = p.id)
            JOIN codes c ON (c.the_code = 'J' AND c.id = pt.type_id)
        WHERE p.id = NEW.jurisdiction_id
    ) THEN
        RAISE EXCEPTION 'Error. Place with id % is not a jurisdiction.', NEW.jurisdiction_id;
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$validate_jurisdiction$ LANGUAGE plpgsql;
 
DROP TRIGGER IF EXISTS validate_jurisdiction ON event_queues;
CREATE TRIGGER validate_jurisdiction BEFORE INSERT OR UPDATE
    ON event_queues FOR EACH ROW EXECUTE PROCEDURE validate_jurisdiction();

DROP TRIGGER IF EXISTS validate_jurisdiction ON external_codes;
CREATE TRIGGER validate_jurisdiction BEFORE INSERT OR UPDATE
    ON external_codes FOR EACH ROW EXECUTE PROCEDURE validate_jurisdiction();

DROP TRIGGER IF EXISTS validate_jurisdiction ON forms;
CREATE TRIGGER validate_jurisdiction BEFORE INSERT OR UPDATE
    ON forms FOR EACH ROW EXECUTE PROCEDURE validate_jurisdiction();

DROP TRIGGER IF EXISTS validate_jurisdiction ON privileges_roles;
CREATE TRIGGER validate_jurisdiction BEFORE INSERT OR UPDATE
    ON privileges_roles FOR EACH ROW EXECUTE PROCEDURE validate_jurisdiction();

DROP TRIGGER IF EXISTS validate_jurisdiction ON role_memberships;
CREATE TRIGGER validate_jurisdiction BEFORE INSERT OR UPDATE
    ON role_memberships FOR EACH ROW EXECUTE PROCEDURE validate_jurisdiction();

    SQL
  end

  def self.down
    execute <<-SQL
      DROP FUNCTION IF EXISTS validate_jurisdiction() CASCADE;
    SQL
  end
end
