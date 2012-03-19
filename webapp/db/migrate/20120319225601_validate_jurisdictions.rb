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
 
DROP TRIGGER IF EXISTS validate_jurisdiction ON alert_subscriptions_jurisdictions;
CREATE TRIGGER validate_jurisdiction BEFORE INSERT OR UPDATE
    ON alert_subscriptions_jurisdictions FOR EACH ROW EXECUTE PROCEDURE validate_jurisdiction();

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
