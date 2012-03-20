class CheckJurisdictionsCorrectly < ActiveRecord::Migration
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
        WHERE p.entity_id = NEW.jurisdiction_id
    ) THEN
        RAISE EXCEPTION 'Error. Place with entity id % is not a jurisdiction.', NEW.jurisdiction_id;
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$validate_jurisdiction$ LANGUAGE plpgsql;
    SQL
  end

  def self.down
  end
end
