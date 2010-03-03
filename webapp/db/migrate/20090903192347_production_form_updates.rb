# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

class ProductionFormUpdates < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == "production"
      puts "Establishing core field to code name mappings"
      [[CoreField.find_by_key("morbidity_event[address][state_id]"), CodeName.find_by_code_name("state")],
        [CoreField.find_by_key("morbidity_event[address][county_id]"), CodeName.find_by_code_name("county")],
        [CoreField.find_by_key("morbidity_event[imported_from_id]"), CodeName.find_by_code_name("imported")],
        [CoreField.find_by_key("morbidity_event[labs][lab_results][test_type]"), CodeName.find_by_code_name("lab_test_type")],
        [CoreField.find_by_key("morbidity_event[interested_party][person_entity][person][birth_gender_id]"), CodeName.find_by_code_name("gender")],
        [CoreField.find_by_key("morbidity_event[interested_party][person_entity][person][ethnicity_id]"), CodeName.find_by_code_name("ethnicity")],
        [CoreField.find_by_key("morbidity_event[interested_party][person_entity][person][primary_language_id]"), CodeName.find_by_code_name("language")],
        [CoreField.find_by_key("morbidity_event[interested_party][risk_factor][pregnant_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("morbidity_event[labs][lab_results][specimen_sent_to_state]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("morbidity_event[interested_party][risk_factor][food_handler_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("morbidity_event[interested_party][risk_factor][healthcare_worker_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("morbidity_event[interested_party][risk_factor][group_living_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("morbidity_event[disease_event][hospitalized_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("morbidity_event[disease_event][died_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("morbidity_event[interested_party][risk_factor][day_care_association_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("morbidity_event[lhd_case_status_id]"), CodeName.find_by_code_name("investigation")],
        [CoreField.find_by_key("morbidity_event[labs][lab_results][test_status]"), CodeName.find_by_code_name("test_result")],
        [CoreField.find_by_key("morbidity_event[state_case_status_id]"), CodeName.find_by_code_name("investigation")],
        [CoreField.find_by_key("morbidity_event[outbreak_associated_id]"), CodeName.find_by_code_name("yesno")],
        [CoreField.find_by_key("morbidity_event[labs][lab_results][specimen_source]"), CodeName.find_by_code_name("specimen")],
        [CoreField.find_by_key("morbidity_event[labs][lab_results][test_result]"), CodeName.find_by_code_name("test_result")],
        [CoreField.find_by_key("morbidity_event[reporter][person_entity][telephones][entity_location_type_id]"), CodeName.find_by_code_name("locationtype")]].each do |field_and_code|

        field_and_code[0].code_name_id = field_and_code[1].id
        field_and_code[0].save!
      end

      puts "Cleaning up field types"

      # Should be drop downs
      ["morbidity_event[interested_party][person_entity][person][ethnicity_id]",
        "morbidity_event[interested_party][person_entity][person][primary_language_id]",
        "morbidity_event[address][county_id]",
        "morbidity_event[address][state_id]",
        "morbidity_event[interested_party][person_entity][person][birth_gender_id]"].each do |key|

        core_field = CoreField.find_by_key(key)
        core_field.field_type = "drop_down"
        core_field.save!
      end

      # Should be single-line text
      ["morbidity_event[reporter][person_entity][person][first_name]",
        "morbidity_event[reporter][person_entity][person][last_name]"].each do |key|
        core_field = CoreField.find_by_key(key)
        core_field.field_type = "single_line_text"
        core_field.save!
      end

      # Should not be able to follow up on"
      ["morbidity_event[interested_party][person_entity][person][age_at_onset]"].each do |key|
        core_field = CoreField.find_by_key(key)
        core_field.can_follow_up = false
        core_field.save!
      end

      # Should be numeric
      ["morbidity_event[interested_party][person_entity][person][age_at_onset]",
        "morbidity_event[interested_party][person_entity][person][approximate_age_no_birthday]",
        "contact_event[interested_party][person_entity][person][age_at_onset]",
        "contact_event[interested_party][person_entity][person][approximate_age_no_birthday]"].each do |key|
        core_field = CoreField.find_by_key(key)
        core_field.field_type = "numeric"
        core_field.save!
      end

    end
  end

  def self.down
  end
end
