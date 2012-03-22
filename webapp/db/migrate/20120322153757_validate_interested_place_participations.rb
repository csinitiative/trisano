class ValidateInterestedPlaceParticipations < ActiveRecord::Migration
  def self.up
    execute <<-SQL
CREATE OR REPLACE FUNCTION validate_participation() RETURNS TRIGGER AS $validate_participation$
DECLARE
    msg TEXT;
BEGIN
    IF NEW.type = 'Jurisdiction' OR NEW.type = 'AssociatedJurisdiction' THEN
        IF NEW.secondary_entity_id IS NULL THEN
            RETURN NULL;
        END IF;
        PERFORM 1
            FROM places
                JOIN places_types ON places_types.place_id = places.id
                JOIN codes ON places_types.type_id = codes.id AND codes.the_code = 'J'
            WHERE places.entity_id = NEW.secondary_entity_id;
        msg := 'Participation types Jurisdiction and AssociatedJurisdiction must have a jurisdiction in their secondary_entity_id';
    ELSIF NEW.type IN ('Lab', 'ActualDeliveryFacility', 'ReportingAgency', 'DiagnosticFacility', 'ExpectedDeliveryFacility', 'InterestedPlace', 'HospitalizationFacility') THEN
        IF NEW.secondary_entity_id IS NULL THEN
            RETURN NULL;
        END IF;
        PERFORM 1 FROM places WHERE places.entity_id = NEW.secondary_entity_id;
        msg := 'Participation types Lab, ActualDeliveryFacility, ReportingAgency, DiagnosticFacility, ExpectedDeliveryFacility, InterestedPlace, and HospitalizationFacility must have places in their secondary_entity_id';
    ELSIF NEW.type = 'InterestedParty' THEN
        IF NEW.primary_entity_id IS NULL THEN
            RETURN NULL;
        END IF;
        PERFORM 1 FROM people WHERE people.entity_id = NEW.primary_entity_id;
        msg := 'InterestedParty participations must have a person in their primary_entity_id';
    ELSIF NEW.type = 'Clinician' OR NEW.type = 'HealthCareProvider' OR NEW.type = 'Reporter' THEN
        IF NEW.secondary_entity_id IS NULL THEN
            RETURN NULL;
        END IF;
        PERFORM 1 FROM people WHERE people.entity_id = NEW.secondary_entity_id;
        msg := 'Participation types Clinician, HealthCareProvider, and Reporter must have people in their secondary_entity_ids';
    ELSE
        IF NEW.secondary_entity_id IS NULL THEN
            RETURN NULL;
        END IF;
        RAISE EXCEPTION 'Participation is invalid -- unknown type %', NEW.type;
    END IF;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Validation error on participation %: %', NEW.id, msg;
    END IF;
    RETURN NEW;
END;
$validate_participation$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_participations ON participations;
CREATE TRIGGER validate_participations BEFORE INSERT OR UPDATE
    ON participations FOR EACH ROW EXECUTE PROCEDURE validate_participation();
    SQL
  end

  def self.down
  end
end
