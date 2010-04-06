# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class Tgrii < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    ActiveRecord::Base.transaction do

      # IMPORTANT NOTE: In almost all cases we want to use straight SQL as opposed to active record, because by
      # the time this code is run the model code is way out of sync with the way the database looks, and many
      # active record associations and events will not work.

      ##############################################################################################################################################
      #                                                 Handle unused participation types: contacts and place
      #
      add_column :events, :participations_contact_id, :integer
      add_column :events, :participations_place_id, :integer

      if RAILS_ENV == 'production'

        say "Adjusting contact events"

        # Note, there are two different kinds of participations that are contact related: the interested party of a contact event and the
        # contact of a morbidity event.  We only want the former.
        contact_parts = execute("
          SELECT p.event_id, p.participations_contact_id 
          FROM participations p, codes c
          WHERE p.participations_contact_id IS NOT NULL
            AND p.role_id = c.id
            AND c.code_name = 'participant'
            AND c.the_code = 'I'
          ")

        # Copy the event specific data (disposition etc.) to the main event
        contact_parts.each do |part|
          execute("UPDATE events SET participations_contact_id = #{part['participations_contact_id']} WHERE id = #{part['event_id']}")
        end

        say "Adjusting place events"

        # Note, there are two different kinds of participations that are place related: the interested place of a place event and the
        # place of exposure of a morbidity event.  We only want the former.
        place_parts = execute("
          SELECT p.event_id, p.participations_place_id 
          FROM participations p, codes c
          WHERE p.participations_place_id IS NOT NULL
            AND p.role_id = c.id
            AND c.code_name = 'participant'
            AND c.the_code = 'PoI'
          ")

        # Copy the event specific data (date of exposure) to the main event
        place_parts.each do |part|
          execute("UPDATE events SET participations_place_id = #{part['participations_place_id']} WHERE id = #{part['event_id']}")
        end

        # Delete the participations we no longer use.
        execute("
          DELETE FROM participations 
          WHERE role_id IN (
            SELECT id 
            FROM codes 
            WHERE code_name = 'participant' 
              AND (the_code = 'CO' OR the_code = 'PE')
          )
          ")

      end

      remove_column :participations, :participations_contact_id
      remove_column :participations, :participations_place_id
      remove_column :participations, :participating_event_id

      ##############################################################################################################################################
      #                                                 Make participations an STI-enabled table.
      #
      add_column :participations, :type, :string
      
      if RAILS_ENV == 'production'

        say "Updating participation types"

        type_map = {
          "Interested Party" =>  "InterestedParty",
          "Place of Interest" => "InterestedPlace",
          "Hospitalized At" => "HospitalizationFacility",
          "Reported By" => "Reporter",
          "Reporting Agency" => "ReportingAgency",
          "Jurisdiction" => "Jurisdiction",
          "Treated By" => "Clinician",
          "Tested By" => "Lab",
          "Diagnosed At" => "DiagnosticFacility",
          "Secondary Jurisdiction" => "AssociatedJurisdiction"
        }

        type_map.each do | key, value |
          execute("
            UPDATE participations 
            SET type = '#{value}' 
            WHERE role_id = 
              (SELECT id 
               FROM codes 
               WHERE code_name = 'participant' 
                 AND code_description = '#{key}')
            ")
        end
      end

      remove_column :participations, :role_id

      ##############################################################################################################################################
      #                                                 Make entities an STI-enabled table.
      #


      if RAILS_ENV == 'production'

        say "Updating entity types"

        type_map = { "person" =>  "PersonEntity", "place" => "PlaceEntity" }

        # Entities already has a type column, just gotta change the value
        type_map.each do | key, value |
          execute("
            UPDATE entities
            SET entity_type = '#{value}'
            WHERE entity_type = '#{key}'
            ")
        end

      end

      ##############################################################################################################################################
      #                                               Move telephones and emails around 
      #

      say "Updating telephones and email addresses"

      create_table :email_addresses do |t|
        t.string  :email_address
        t.integer :entity_id
        t.timestamps
      end

      add_column :telephones, :entity_id, :integer
      add_column :telephones, :entity_location_type_id, :integer

      if RAILS_ENV == 'production'
        telephones = Entity.find_by_sql("
          SELECT e.id as entity_id, el.entity_location_type_id as type_id, t.email_address as email, t.id as tel_id
          FROM entities e, entities_locations el, locations l, telephones t
          WHERE
            e.id = el.entity_id
          AND
            el.location_id = l.id
          AND
            l.id = t.location_id
          ")

        telephones.each do |phone|
          execute("
            UPDATE telephones
            SET entity_id = #{phone.entity_id}, entity_location_type_id = #{phone.type_id || "NULL"}
            WHERE id = #{phone.tel_id}
            ")

          unless phone.email.blank?
            execute("
              INSERT INTO email_addresses (entity_id, email_address)
              VALUES (#{phone.entity_id}, '#{phone.email.gsub(/\\|'/) { |c| "\\#{c}" }}')
              ")
          end
        end
      end

      ##############################################################################################################################################
      #                                                        Move addresses around 
      #

      say "Updating physical addresses"

      add_column :addresses, :entity_id, :integer
      add_column :addresses, :entity_location_type_id, :integer
      
      if RAILS_ENV == 'production'

        addresses = Entity.find_by_sql("
          SELECT e.id as entity_id, el.entity_location_type_id as type_id, a.id as address_id
          FROM entities e, entities_locations el, locations l, addresses a
          WHERE
            e.id = el.entity_id
          AND
            el.location_id = l.id
          AND
            l.id = a.location_id
          ")

        addresses.each do |address|
          execute("
            UPDATE addresses
            SET entity_id = #{address.entity_id}, entity_location_type_id = #{address.type_id || "NULL"}
            WHERE id = #{address.address_id}
            ")
        end
      end

      ##############################################################################################################################################
      #                                                              Cleaning up
      #

      say "Cleaning up tables and indexes"

      # Remove tables we no longer need
      execute("DROP TABLE entities_locations CASCADE")
      execute("DROP TABLE locations CASCADE")

      # Get rid of codes we don't need anymore
      execute("DELETE FROM codes WHERE code_name = 'participant'")
      execute("DELETE FROM codes WHERE code_name = 'locationtype'")

      # Add an index to all the 'type' fields used for STI
      add_index :events, :type
      add_index :participations, :type
      add_index :entities, :entity_type

      # Create foreign keys to link telephones and addresses to entities
      add_foreign_key :telephones, :entity_id, :entities
      add_foreign_key :addresses, :entity_id, :entities

      # Add indexes for our foreign keys
      add_index :telephones, :entity_id
      add_index :addresses, :entity_id

      # While we're at it let's get rid of all still-unused tables
      execute("DROP TABLE animals CASCADE")
      execute("DROP TABLE clinicals CASCADE")
      execute("DROP TABLE clusters CASCADE")
      execute("DROP TABLE entity_groups CASCADE")
      execute("DROP TABLE export_predicates CASCADE")
      execute("DROP TABLE materials CASCADE")
      execute("DROP TABLE observations CASCADE")
      execute("DROP TABLE referrals CASCADE")

      ##############################################################################################################################################
      #                                                              Update core fields
      #

      if RAILS_ENV == 'production'
        say "Updating core field references"

        core_field_map = {
          "contact_event[active_patient][active_primary_entity][address][city]" => "contact_event[interested_party][person_entity][person][address][city]",
          "contact_event[active_patient][active_primary_entity][address][county_id]" => "contact_event[interested_party][person_entity][person][address][county_id]",
          "contact_event[active_patient][active_primary_entity][address][postal_code]" => "contact_event[interested_party][person_entity][person][address]{postal_code]",
          "contact_event[active_patient][active_primary_entity][address][state_id]" => "contact_event[interested_party][person_entity][person][address][state_id]",
          "contact_event[active_patient][active_primary_entity][address][street_name]" => "contact_event[interested_party][person_entity][person][address][street_name]",
          "contact_event[active_patient][active_primary_entity][address][street_number]" => "contact_event[interested_party][person_entity][person][address]{street_number]",
          "contact_event[active_patient][active_primary_entity][address][unit_number]" => "contact_event[interested_party][person_entity][person][address][unit_number]",

          "contact_event[active_patient][active_primary_entity][person][age_at_onset]" => "contact_event[interested_party][person_entity][person][age_at_onset]",
          "contact_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => "contact_event[interested_party][person_entity][person][approximate_age_no_birthday]",
          "contact_event[active_patient][active_primary_entity][person][birth_date]" => "contact_event[interested_party][person_entity][person][birth_date]",
          "contact_event[active_patient][active_primary_entity][person][birth_gender_id]" => "contact_event[interested_party][person_entity][person][birth_gender_id]",
          "contact_event[active_patient][active_primary_entity][person][date_of_death]" => "contact_event[interested_party][person_entity][person][date_of_death]",
          "contact_event[active_patient][active_primary_entity][person][ethnicity_id]" => "contact_event[interested_party][person_entity][person][ethnicity_id]",
          "contact_event[active_patient][active_primary_entity][person][first_name]" => "contact_event[interested_party][person_entity][person][first_name]",
          "contact_event[active_patient][active_primary_entity][person][last_name]" => "contact_event[interested_party][person_entity][person][last_name]",
          "contact_event[active_patient][active_primary_entity][person][middle_name]" => "contact_event[interested_party][person_entity][person][middle_name]",
          "contact_event[active_patient][active_primary_entity][person][primary_language_id]" => "contact_event[interested_party][person_entity][person][primary_language_id]",

          "contact_event[active_patient][participations_risk_factor][day_care_association_id]" => "contact_event[interested_party][risk_factor][day_care_association_id]",
          "contact_event[active_patient][participations_risk_factor][food_handler_id]" => "contact_event[interested_party][risk_factor][food_handler_id]",
          "contact_event[active_patient][participations_risk_factor][group_living_id]" => "contact_event[interested_party][risk_factor][group_living_id]",
          "contact_event[active_patient][participations_risk_factor][healthcare_worker_id]" => "contact_event[interested_party][risk_factor][healthcare_worker_id]",
          "contact_event[active_patient][participations_risk_factor][occupation]" => "contact_event[interested_party][risk_factor][occupation]",
          "contact_event[active_patient][participations_risk_factor][pregnancy_due_date]" => "contact_event[interested_party][risk_factor][pregnancy_due_date]",
          "contact_event[active_patient][participations_risk_factor][pregnant_id]" => "contact_event[interested_party][risk_factor][pregnant_id]",
          "contact_event[active_patient][participations_risk_factor][risk_factors]" => "contact_event[interested_party][risk_factor][risk_factors]",
          "contact_event[active_patient][participations_risk_factor][risk_factors_notes]" => "contact_event[interested_party][risk_factor][risk_factors_notes]",

          "contact_event[disease][date_diagnosed]" => "contact_event[disease_event][date_diagnosed]",
          "contact_event[disease][died_id]" => "contact_event[disease_event][died_id]",
          "contact_event[disease][disease_id]" => "contact_event[disease_event][disease_id]",
          "contact_event[disease][disease_onset_date]" => "contact_event[disease_event][disease_onset_date]",
          "contact_event[disease][hospitalized_id]" => "contact_event[disease_event][hospitalized_id]",

          "contact_event[imported_from_id]" => "contact_event[imported_from_id]",

          "contact_event[lab_result][collection_date]" => "contact_event[labs][lab_results][collection_date] ",
          "contact_event[lab_result][interpretation]" => "contact_event[labs][lab_results][interpretation]",
          "contact_event[lab_result][lab_name]" => "contact_event[labs][place_entity][place][name]",
          "contact_event[lab_result][lab_result_text]" => "contact_event[labs][lab_results][lab_result_text]",
          "contact_event[lab_result][lab_test_date]" => "contact_event[labs][lab_results][lab_test_date]",
          "contact_event[lab_result][reference_range]" => "contact_event[labs][lab_results][reference_range]",
          "contact_event[lab_result][specimen_sent_to_uphl]" => "contact_event[labs][lab_results][specimen_sent_to_uphl]",
          "contact_event[lab_result][specimen_source]" => "contact_event[labs][lab_results][specimen_source]",
          "contact_event[lab_result][test_detail]" => "contact_event[labs][lab_results][test_detail]",
          "contact_event[lab_result][test_type]" => "contact_event[labs][lab_results][test_type]",

          "contact_event[treatments]" => "contact_event[treatments]",

          "morbidity_event[active_jurisdiction][secondary_entity_id]" => "morbidity_event[jurisdiction][secondary_entity_id]",
          "morbidity_event[active_patient][active_primary_entity][address][city]" => "morbidity_event[interested_party][person_entity][address][city]",
          "morbidity_event[active_patient][active_primary_entity][address][county_id]" => "morbidity_event[interested_party][person_entity][address][county_id]",
          "morbidity_event[active_patient][active_primary_entity][address][postal_code]" => "morbidity_event[interested_party][person_entity][address][postal_code]",
          "morbidity_event[active_patient][active_primary_entity][address][state_id]" => "morbidity_event[interested_party][person_entity][address][state_id]",
          "morbidity_event[active_patient][active_primary_entity][address][street_name]" => "morbidity_event[interested_party][person_entity][address][street_name]",
          "morbidity_event[active_patient][active_primary_entity][address][street_number]" => "morbidity_event[interested_party][person_entity][address][street_number]",
          "morbidity_event[active_patient][active_primary_entity][address][unit_number]" => "morbidity_event[interested_party][person_entity][address][unit_number]",

          "morbidity_event[active_patient][active_primary_entity][person][age_at_onset]" => "morbidity_event[interested_party][person_entity][person][age_at_onset]",
          "morbidity_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => "morbidity_event[interested_party][person_entity][person][approximate_age_no_birthday]",
          "morbidity_event[active_patient][active_primary_entity][person][birth_date]" => "morbidity_event[interested_party][person_entity][person][birth_date]",
          "morbidity_event[active_patient][active_primary_entity][person][birth_gender_id]" => "morbidity_event[interested_party][person_entity][person][birth_gender_id]",
          "morbidity_event[active_patient][active_primary_entity][person][date_of_death]" => "morbidity_event[interested_party][person_entity][person][date_of_death]",
          "morbidity_event[active_patient][active_primary_entity][person][ethnicity_id]" => "morbidity_event[interested_party][person_entity][person][ethnicity_id]",
          "morbidity_event[active_patient][active_primary_entity][person][first_name]" => "morbidity_event[interested_party][person_entity][person][first_name]",
          "morbidity_event[active_patient][active_primary_entity][person][last_name]" => "morbidity_event[interested_party][person_entity][person][last_name]",
          "morbidity_event[active_patient][active_primary_entity][person][middle_name]" => "morbidity_event[interested_party][person_entity][person][middle_name]",
          "morbidity_event[active_patient][active_primary_entity][person][primary_language_id]" => "morbidity_event[interested_party][person_entity][person][primary_language_id]",

          "morbidity_event[active_patient][participations_risk_factor][day_care_association_id]" => "morbidity_event[interested_party][risk_factor][day_care_association_id]",
          "morbidity_event[active_patient][participations_risk_factor][food_handler_id]" => "morbidity_event[interested_party][risk_factor][food_handler_id]",
          "morbidity_event[active_patient][participations_risk_factor][group_living_id]" => "morbidity_event[interested_party][risk_factor][group_living_id]",
          "morbidity_event[active_patient][participations_risk_factor][healthcare_worker_id]" => "morbidity_event[interested_party][risk_factor][healthcare_worker_id]",
          "morbidity_event[active_patient][participations_risk_factor][occupation]" => "morbidity_event[interested_party][risk_factor][occupation]",
          "morbidity_event[active_patient][participations_risk_factor][pregnancy_due_date]" => "morbidity_event[interested_party][risk_factor][pregnancy_due_date]",
          "morbidity_event[active_patient][participations_risk_factor][pregnant_id]" => "morbidity_event[interested_party][risk_factor][pregnant_id]",
          "morbidity_event[active_patient][participations_risk_factor][risk_factors]" => "morbidity_event[interested_party][risk_factor][risk_factors]",
          "morbidity_event[active_patient][participations_risk_factor][risk_factors_notes]" => "morbidity_event[interested_party][risk_factor][risk_factors_notes]",

          "morbidity_event[active_reporter][active_secondary_entity][person][first_name]" => "morbidity_event[reporter][person_entity][person][first_name]",
          "morbidity_event[active_reporter][active_secondary_entity][person][last_name]" => "morbidity_event[reporter][person_entity][person][last_name]",
          "morbidity_event[active_reporter][active_secondary_entity][telephone][area_code]" => "morbidity_event[reporter][person_entity][telephones][area_code]",
          "morbidity_event[active_reporter][active_secondary_entity][telephone_entities_location][entity_location_type_id]" => "morbidity_event[reporter][person_entity][telephones][entity_location_type_id]",
          "morbidity_event[active_reporter][active_secondary_entity][telephone][extension]" => "morbidity_event[reporter][person_entity][telephones][extension]",
          "morbidity_event[active_reporter][active_secondary_entity][telephone][phone_number]" => "morbidity_event[reporter][person_entity][telephones][phone_number]",

          "morbidity_event[active_reporting_agency][active_secondary_entity][place][name]" => "morbidity_event[reporting_agency][place_entity][place][name]",

          "morbidity_event[disease][date_diagnosed]" => "morbidity_event[disease_event][date_diagnosed]",
          "morbidity_event[disease][died_id]" => "morbidity_event[disease_event][died_id]",
          "morbidity_event[disease][disease_id]" => "morbidity_event[disease_event][disease_id]",
          "morbidity_event[disease][disease_onset_date]" => "morbidity_event[disease_event][disease_onset_date]",
          "morbidity_event[disease][hospitalized_id]" => "morbidity_event[disease_event][hospitalized_id]",

          "morbidity_event[lab_result][collection_date]" => "morbidity_event[labs][lab_results][collection_date]",
          "morbidity_event[lab_result][interpretation]" => "morbidity_event[labs][lab_results][interpretation]",
          "morbidity_event[lab_result][lab_name]" => "morbidity_event[labs][place_entity][place][name]",
          "morbidity_event[lab_result][lab_result_text]" => "morbidity_event[labs][lab_results][lab_result_text]",
          "morbidity_event[lab_result][lab_test_date]" => "morbidity_event[labs][lab_results][lab_test_date]",
          "morbidity_event[lab_result][reference_range]" => "morbidity_event[labs][lab_results][reference_range]",
          "morbidity_event[lab_result][specimen_sent_to_uphl]" => "morbidity_event[labs][lab_results][specimen_sent_to_uphl]",
          "morbidity_event[lab_result][specimen_source]" => "morbidity_event[labs][lab_results][specimen_source]",
          "morbidity_event[lab_result][test_detail]" => "morbidity_event[labs][lab_results][test_detail]",
          "morbidity_event[lab_result][test_type]" => "morbidity_event[labs][lab_results][test_type]",

          "morbidity_event[acuity]" => "morbidity_event[acuity]",
          "morbidity_event[event_name]" => "morbidity_event[event_name]",
          "morbidity_event[event_status]" => "morbidity_event[event_status]",
          "morbidity_event[first_reported_PH_date]" => "morbidity_event[first_reported_PH_date]",
          "morbidity_event[imported_from_id]" => "morbidity_event[imported_from_id]",
          "morbidity_event[investigation_completed_LHD_date]" => "morbidity_event[investigation_completed_LHD_date]",
          "morbidity_event[investigation_started_date]" => "morbidity_event[investigation_started_date]",
          "morbidity_event[lhd_case_status_id]" => "morbidity_event[lhd_case_status_id]",
          "morbidity_event[other_data_1]" => "morbidity_event[other_data_1]",
          "morbidity_event[other_data_2]" => "morbidity_event[other_data_2]",
          "morbidity_event[outbreak_associated_id]" => "morbidity_event[outbreak_associated_id]",
          "morbidity_event[outbreak_name]" => "morbidity_event[outbreak_name]",
          "morbidity_event[results_reported_to_clinician_date]" => "morbidity_event[results_reported_to_clinician_date]",
          "morbidity_event[review_completed_by_state_date]" => "morbidity_event[review_completed_by_state_date]",
          "morbidity_event[state_case_status_id]" => "morbidity_event[state_case_status_id]",

          "morbidity_event[treatments]" => "morbidity_event[treatments]",
          "morbidity_event[contacts]" => "morbidity_event[contacts]",
          "morbidity_event[places]" => "morbidity_event[places]",

          "place_event[active_place][active_primary_entity][address][city]" => "place_event[interested_place][place_entity][address][city]",
          "place_event[active_place][active_primary_entity][address][county_id]" => "place_event[interested_place][place_entity][address][county_id]",
          "place_event[active_place][active_primary_entity][address][postal_code]" => "place_event[interested_place][place_entity][address][postal_code]",
          "place_event[active_place][active_primary_entity][address][state_id]" => "place_event[interested_place][place_entity][address][state_id]",
          "place_event[active_place][active_primary_entity][address][street_name]" => "place_event[interested_place][place_entity][address][street_name]",
          "place_event[active_place][active_primary_entity][address][street_number]" => "place_event[interested_place][place_entity][address][street_number]",
          "place_event[active_place][active_primary_entity][address][unit_number]" => "place_event[interested_place][place_entity][address][unit_number]",
          "place_event[active_place][active_primary_entity][place][name]" => "place_event[interested_place][place_entity][place][name]",
          "place_event[active_place][active_primary_entity][place][place_type_id]" => "place_event[interested_place][place_entity][place][place_type_id]",
        }

        core_field_map.each do |key, value|
          execute("
            UPDATE core_fields
            SET key = '#{value}'
            WHERE key = '#{key}'
            ")

          execute("
            UPDATE form_elements
            SET core_path = '#{value}'
            WHERE core_path = '#{key}'
            ")
        end

        say "Turning off form builder support for reporting phone fields"
        
        ["morbidity_event[reporter][person_entity][telephones][area_code]",
          "morbidity_event[reporter][person_entity][telephones][entity_location_type_id]",
          "morbidity_event[reporter][person_entity][telephones][extension]",
          "morbidity_event[reporter][person_entity][telephones][phone_number]"].each do |key|
          core_field = CoreField.find_by_key(key)
          unless core_field.nil?
            say "Updating #{key}"
            core_field.fb_accessible = false
            core_field.can_follow_up = false
            core_field.save!
          else
            say "Did not find a core field for #{key}"
          end
        end
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      # Fill this in
    end
  end
end
