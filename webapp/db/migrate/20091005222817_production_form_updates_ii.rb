# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

class ProductionFormUpdatesIi < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == "production"

      puts "Establishing core field to code name mappings"
      [[CoreField.find_by_key("contact_event[address][state_id]"), CodeName.find_by_code_name("state")],
        [CoreField.find_by_key("contact_event[address][county_id]"), CodeName.find_by_code_name("county")],
        [CoreField.find_by_key("contact_event[imported_from_id]"), CodeName.find_by_code_name("imported")],
        [CoreField.find_by_key("contact_event[labs][lab_results][test_type]"), CodeName.find_by_code_name("lab_test_type")],
        [CoreField.find_by_key("contact_event[interested_party][person_entity][person][birth_gender_id]"), CodeName.find_by_code_name("gender")],
        [CoreField.find_by_key("contact_event[interested_party][person_entity][person][ethnicity_id]"), CodeName.find_by_code_name("ethnicity")],
        [CoreField.find_by_key("contact_event[interested_party][person_entity][person][primary_language_id]"), CodeName.find_by_code_name("language")],
        [CoreField.find_by_key("contact_event[interested_party][risk_factor][pregnant_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("contact_event[labs][lab_results][specimen_sent_to_state]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("contact_event[interested_party][risk_factor][food_handler_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("contact_event[interested_party][risk_factor][healthcare_worker_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("contact_event[interested_party][risk_factor][group_living_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("contact_event[disease_event][hospitalized_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("contact_event[disease_event][died_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("contact_event[interested_party][risk_factor][day_care_association_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("contact_event[labs][lab_results][test_status]"), CodeName.find_by_code_name("test_status")],
        [CoreField.find_by_key("contact_event[labs][lab_results][specimen_source]"), CodeName.find_by_code_name("specimen")],
        [CoreField.find_by_key("contact_event[labs][lab_results][test_result]"), CodeName.find_by_code_name("test_result")]].each do |field_and_code|

        field_and_code[0].code_name_id = field_and_code[1].id
        field_and_code[0].save!
      end

      # Should be numeric
      ["morbidity_event[acuity]"].each do |key|
        core_field = CoreField.find_by_key(key)
        core_field.field_type = "numeric"
        core_field.save!
      end

      # Remove reporter phone type
      reporter_phone_type_field = CoreField.find_by_key("morbidity_event[reporter][person_entity][telephones][entity_location_type_id]")
      unless reporter_phone_type_field.nil?
        reporter_phone_type_field.destroy
      end

    end
  end

  def self.down
  end
end
