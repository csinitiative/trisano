require "migration_helpers"
class UpdateCodesForeignKeys < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
      #addresses
      remove_foreign_key(:addresses, :county)
      add_foreign_key(:addresses, :county_id, :external_codes)
      remove_foreign_key(:addresses, :state)
      add_foreign_key(:addresses, :state_id, :external_codes)

      #clinicals
      remove_foreign_key(:clinicals, :lab_yn)
      add_foreign_key(:clinicals, :test_public_health_lab_id, :external_codes)

      #disease_events
      remove_foreign_key(:disease_events, :died)
      add_foreign_key(:disease_events, :died_id, :external_codes)
      remove_foreign_key(:disease_events, :hospitalized)
      add_foreign_key(:disease_events, :hospitalized_id, :external_codes)

      #entities_locations
      remove_foreign_key(:entities_locations, :location_type)
      add_foreign_key(:entities_locations, :entity_location_type_id, :external_codes)
      remove_foreign_key(:entities_locations, :primary_yn)
      add_foreign_key(:entities_locations, :primary_yn_id, :external_codes)

      #entity_groups
      remove_foreign_key(:entity_groups, :entitygrouptypecode)
      add_foreign_key(:entity_groups, :entity_group_type_id, :external_codes)

      #events
      remove_foreign_key(:events, :imported_from)
      add_foreign_key(:events, :imported_from_id, :external_codes)

      #lab_results
      remove_foreign_key(:lab_results, :specimensourceid)
      add_foreign_key(:lab_results, :specimen_source_id, :external_codes)
      remove_foreign_key(:lab_results, :testedatuphlynid)
      add_foreign_key(:lab_results, :tested_at_uphl_yn_id, :external_codes)

      #participations_risk_factors
      remove_foreign_key(:participations_risk_factors, :daycareassoc)
      add_foreign_key(:participations_risk_factors, :day_care_association_id, :external_codes)
      remove_foreign_key(:participations_risk_factors, :pregnant)
      add_foreign_key(:participations_risk_factors, :pregnant_id, :external_codes)
      remove_foreign_key(:participations_risk_factors, :healthcareworker)
      add_foreign_key(:participations_risk_factors, :healthcare_worker_id, :external_codes)
      remove_foreign_key(:participations_risk_factors, :groupliving)
      add_foreign_key(:participations_risk_factors, :group_living_id, :external_codes)
      remove_foreign_key(:participations_risk_factors, :foodhandler)
      add_foreign_key(:participations_risk_factors, :food_handler_id, :external_codes)

      #participation_treatments
      remove_foreign_key(:participations_treatments, :treatment_given_yn)
      add_foreign_key(:participations_treatments , :treatment_given_yn_id, :external_codes)

      #people
      remove_foreign_key(:people, :code_birthgender)
      add_foreign_key(:people, :birth_gender_id, :external_codes)
      remove_foreign_key(:people, :ethnicity)
      add_foreign_key(:people, :ethnicity_id, :external_codes)
      remove_foreign_key(:people, :primary_language)
      add_foreign_key(:people, :primary_language_id, :external_codes)
  end

  def self.down
      #addresses
      remove_foreign_key(:addresses, :county_id)
      add_foreign_key(:addresses, :county, :codes)
      remove_foreign_key(:addresses, :state_id)
      add_foreign_key(:addresses, :state, :codes)

      #clinicals
      remove_foreign_key(:clinicals, :test_public_health_lab_id)
      add_foreign_key(:clinicals, :lab_yn, :codes)

      #disease_events
      remove_foreign_key(:disease_events, :died_id)
      add_foreign_key(:disease_events, :died, :codes)
      remove_foreign_key(:disease_events, :hospitalized_id)
      add_foreign_key(:disease_events, :hospitalized_, :codes)

      #entities_locations
      remove_foreign_key(:entities_locations, :entity_location_type_id)
      add_foreign_key(:entities_locations, :location_type, :codes)
      remove_foreign_key(:entities_locations, :primary_yn_id)
      add_foreign_key(:entities_locations, :primary_yn, :codes)

      #entity_groups
      remove_foreign_key(:entity_groups, :entity_group_type_code_id)
      add_foreign_key(:entity_groups, :entitygrouptype, :codes)

      #events
      remove_foreign_key(:events, :imported_from_id)
      add_foreign_key(:events, :imported_from, :codes)

      #lab_results
      remove_foreign_key(:lab_results, :specimen_source_id)
      add_foreign_key(:lab_results, :specimensourceid, :codes)
      remove_foreign_key(:lab_results, :tested_at_uphl_yn_id)
      add_foreign_key(:lab_results, :testedatuphlynid, :codes)

      #participations_risk_factors
      remove_foreign_key(:participations_risk_factors, :day_care_association_id)
      add_foreign_key(:participations_risk_factors, :daycareassoc, :codes)
      remove_foreign_key(:participations_risk_factors, :pregnant_id)
      add_foreign_key(:participations_risk_factors, :pregnant, :codes)
      remove_foreign_key(:participations_risk_factors, :healthcare_worker_id)
      add_foreign_key(:participations_risk_factors, :healthcareworker, :codes)
      remove_foreign_key(:participations_risk_factors, :group_living_id)
      add_foreign_key(:participations_risk_factors, :groupliving, :codes)
      remove_foreign_key(:participations_risk_factors, :food_handler_id)
      add_foreign_key(:participations_risk_factors, :foodhandler, :codes)

      #participation_treatments
      remove_foreign_key(:participation_treatments, :treatment_given_yn_id)
      add_foreign_key(:participation_treatments , :treatment_given_yn, :codes)

      #people
      remove_foreign_key(:people, :birth_gender_id)
      add_foreign_key(:people, :code_birthgender, :codes)
      remove_foreign_key(:people, :ethnicity_id)
      add_foreign_key(:people, :ethnicity, :codes)
      remove_foreign_key(:people, :primary_language_id)
      add_foreign_key(:people, :primary_language, :codes)
  end
end
