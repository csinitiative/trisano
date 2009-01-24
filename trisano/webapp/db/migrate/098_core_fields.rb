# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

class CoreFields < ActiveRecord::Migration

  def self.up
    transaction do
      create_table :core_fields do |t|
        t.string  :key
        t.string  :field_type
        t.string  :name
        t.boolean :can_follow_up
        t.string  :event_type
        t.string  :help_text
        
        t.timestamps
      end
    
      if RAILS_ENV == 'production'
        core_fields.each do |field|
          CoreField.create(field)
        end
      end
    end
  end

  def self.down
    drop_table :core_fields
  end

  def self.core_fields
    [ # morbidity events
      {:key => "morbidity_event[active_patient][active_primary_entity][person][last_name]", :field_type => 'single_line_text', :name => "Patient last name", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][person][first_name]", :field_type => 'single_line_text', :name => "Patient first name", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][person][middle_name]", :field_type => 'single_line_text', :name => "Patient middle name", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][address][street_number]", :field_type => 'single_line_text', :name => "Patient street number", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][address][street_name]", :field_type => 'single_line_text', :name => "Patient street name", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][address][unit_number]", :field_type => 'single_line_text', :name => "Patient unit number", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][address][city]", :field_type => 'single_line_text', :name => "Patient city", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][address][state_id]", :field_type => 'single_line_text', :name => "Patient state", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][address][county_id]", :field_type => 'single_line_text', :name => "Patient county", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][address][postal_code]", :field_type => 'single_line_text', :name => "Patient zip code", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][person][birth_date]", :field_type => 'date', :name => "Patient date of birth", :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]", :field_type => 'single_line_text', :name => "Patient age", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][person][age_at_onset]", :field_type => 'single_line_text', :name => "Age at onset", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][person][date_of_death]", :field_type => 'date', :name => "Patient date of death", :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][person][birth_gender_id]", :field_type => 'single_line_text', :name => "Patient birth gender", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][person][ethnicity_id]", :field_type => 'single_line_text', :name => "Patient ethnicity", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][active_primary_entity][person][primary_language_id]", :field_type => 'single_line_text', :name => "Patient primary language", :can_follow_up => true, :event_type => 'morbidity_event' },
      # "morbidity_event[active_patient][active_primary_entity][race_ids][]" => {:field_type => 'single_line_text', :name => "Patient race" }
      
      # Risk factors
      {:key => "morbidity_event[active_patient][participations_risk_factor][pregnant_id]", :field_type => 'drop_down', :name => "Pregnant", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][participations_risk_factor][pregnancy_due_date]", :field_type => 'date', :name => "Pregnancy due date", :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][participations_risk_factor][food_handler_id]", :field_type => 'drop_down', :name => "Food handler", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][participations_risk_factor][healthcare_worker_id]", :field_type => 'drop_down', :name => "Healthcare worker", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][participations_risk_factor][group_living_id]", :field_type => 'drop_down', :name => "Group living", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][participations_risk_factor][day_care_association_id]", :field_type => 'drop_down', :name => "Day care association", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][participations_risk_factor][occupation]", :field_type => 'single_line_text', :name => "Occupation", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][participations_risk_factor][risk_factors]", :field_type => 'single_line_text', :name => "Risk factors", :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_patient][participations_risk_factor][risk_factors_notes]", :field_type => 'multi_line_text', :name => "Risk factors notes", :can_follow_up => false, :event_type => 'morbidity_event' },

      # Event-level fields
      {:key => "morbidity_event[results_reported_to_clinician_date]", :field_type => 'single_line_text', :name => "Results reported to clinician date", :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[first_reported_PH_date]", :field_type => 'single_line_text', :name => "Date first reported to public health", :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[lhd_case_status_id]", :field_type => 'drop_down', :name => 'LHD case status', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[udoh_case_status_id]", :field_type => 'drop_down', :name => 'UDOH case status', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[outbreak_associated_id]", :field_type => 'drop_down', :name => 'Outbreak associated', :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[outbreak_name]", :field_type => 'single_line_text', :name => 'Outbreak', :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_jurisdiction][secondary_entity_id]", :field_type => 'multi_select', :name => 'Jurisdiction responsible for investigation', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[event_status]", :field_type => 'drop_down', :name => 'Event status', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[investigation_started_date]", :field_type => 'single_line_text', :name => 'Date investigation started', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[investigation_completed_LHD_date]", :field_type => 'single_line_text', :name => 'Date investigation completed', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[event_name]", :field_type => 'single_line_text', :name => 'Event name', :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[review_completed_UDOH_date]", :field_type => 'single_line_text', :name => 'Date review completed by UDOH', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[imported_from_id]", :field_type => 'drop_down', :name => 'Imported from', :can_follow_up => true, :event_type => 'morbidity_event' },
     
      # Reporting-level fields
      {:key => "morbidity_event[active_reporting_agency][active_secondary_entity][place][name]", :field_type => 'drop_down', :name => 'Reporting agency', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_reporter][active_secondary_entity][person][first_name]", :field_type => 'drop_down', :name => 'Reporter first name', :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_reporter][active_secondary_entity][person][last_name]", :field_type => 'drop_down', :name => 'Reporter last name', :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_reporter][active_secondary_entity][telephone_entities_location][entity_location_type_id]", :field_type => 'drop_down', :name => 'Reporter phone type', :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_reporter][active_secondary_entity][telephone][area_code]", :field_type => 'drop_down', :name => 'Reporter area code', :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_reporter][active_secondary_entity][telephone][phone_number]", :field_type => 'drop_down', :name => 'Reporter phone number', :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[active_reporter][active_secondary_entity][telephone][extension]", :field_type => 'drop_down', :name => 'Reporter extension', :can_follow_up => true, :event_type => 'morbidity_event' },

      # Disease-level fields
      {:key => "morbidity_event[disease][disease_id]", :field_type => 'drop_down', :name => 'Disease', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[disease][disease_onset_date]", :field_type => 'date', :name => 'Disease onset date', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[disease][date_diagnosed]", :field_type => 'date', :name => 'Disease date diagnosed', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[disease][hospitalized_id]", :field_type => 'drop_down', :name => 'Hospitalized', :can_follow_up => true, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[disease][died_id]", :field_type => 'drop_down', :name => 'Died', :can_follow_up => true, :event_type => 'morbidity_event' },
      
      # Multiples wrappers
      {:key => "morbidity_event[contacts]", :field_type => 'drop_down', :name => 'Contacts', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[places]", :field_type => 'drop_down', :name => 'Places', :can_follow_up => false, :event_type => 'morbidity_event' },
      {:key => "morbidity_event[treatments]", :field_type => 'drop_down', :name => 'Treatments', :can_follow_up => false, :event_type => 'morbidity_event' },

      # place events
      {:key => "place_event[active_place][active_primary_entity][place][name]", :field_type => 'single_line_text', :name => "Name", :can_follow_up => true, :event_type => 'place_event' },
      {:key => "place_event[active_place][active_primary_entity][place][place_type_id]", :field_type => 'drop_down', :name => "Type", :can_follow_up => false, :event_type => 'place_event' },
      {:key => "place_event[active_place][active_primary_entity][address][street_number]", :field_type => 'single_line_text', :name => "Street number", :can_follow_up => true, :event_type => 'place_event' },
      {:key => "place_event[active_place][active_primary_entity][address][street_name]", :field_type => 'single_line_text', :name => "Street name", :can_follow_up => true, :event_type => 'place_event' },
      
      {:key => "place_event[active_place][active_primary_entity][address][unit_number]", :field_type => 'single_line_text', :name => "Unit number", :can_follow_up => true, :event_type => 'place_event' },
      {:key => "place_event[active_place][active_primary_entity][address][city]", :field_type => 'single_line_text', :name => "City", :can_follow_up => true, :event_type => 'place_event' },
      {:key => "place_event[active_place][active_primary_entity][address][state_id]", :field_type => 'drop_down', :name => "State", :can_follow_up => true, :event_type => 'place_event' },
      {:key => "place_event[active_place][active_primary_entity][address][county_id]", :field_type => 'drop_down', :name => "County", :can_follow_up => true, :event_type => 'place_event' },
      {:key => "place_event[active_place][active_primary_entity][address][postal_code]", :field_type => 'single_line_text', :name => "Zip code", :can_follow_up => true, :event_type => 'place_event'},
     
      #contact events
      {:key => "contact_event[active_patient][active_primary_entity][person][last_name]", :field_type => 'single_line_text', :name => "Contact last name", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][person][first_name]", :field_type => 'single_line_text', :name => "Contact first name", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][person][middle_name]", :field_type => 'single_line_text', :name => "Contact middle name", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][address][street_number]", :field_type => 'single_line_text', :name => "Contact street number", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][address][street_name]", :field_type => 'single_line_text', :name => "Contact street name", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][address][unit_number]", :field_type => 'single_line_text', :name => "Contact unit number", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][address][city]", :field_type => 'single_line_text', :name => "Contact city", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][address][state_id]", :field_type => 'single_line_text', :name => "Contact state", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][address][county_id]", :field_type => 'single_line_text', :name => "Contact county", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][address][postal_code]", :field_type => 'single_line_text', :name => "Contact zip code", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][person][birth_date]", :field_type => 'date', :name => "Contact date of birth", :can_follow_up => false, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]", :field_type => 'single_line_text', :name => "Contact age", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][person][age_at_onset]", :field_type => 'single_line_text', :name => "Age at onset", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][person][date_of_death]", :field_type => 'date', :name => "Contact date of death", :can_follow_up => false, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][person][birth_gender_id]", :field_type => 'single_line_text', :name => "Contact birth gender", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][person][ethnicity_id]", :field_type => 'single_line_text', :name => "Contact ethnicity", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][active_primary_entity][person][primary_language_id]", :field_type => 'single_line_text', :name => "Contact primary language", :can_follow_up => true, :event_type => 'contact_event' },

      # contact_event_active_patient__person_disposition_id
      # "contact_event[active_patient][race_ids][]" => {:field_type => 'single_line_text', :name => "Patient race" }
      
      # Event-level fields
      {:key => "contact_event[imported_from_id]", :field_type => 'drop_down', :name => 'Imported from', :can_follow_up => true, :event_type => 'contact_event' },
      
      # Risk factors
      {:key => "contact_event[active_patient][participations_risk_factor][pregnant_id]", :field_type => 'drop_down', :name => "Pregnant", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][participations_risk_factor][pregnancy_due_date]", :field_type => 'date', :name => "Pregnancy due date", :can_follow_up => false, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][participations_risk_factor][food_handler_id]", :field_type => 'drop_down', :name => "Food handler", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][participations_risk_factor][healthcare_worker_id]", :field_type => 'drop_down', :name => "Healthcare worker", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][participations_risk_factor][group_living_id]", :field_type => 'drop_down', :name => "Group living", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][participations_risk_factor][day_care_association_id]", :field_type => 'drop_down', :name => "Day care association", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][participations_risk_factor][occupation]", :field_type => 'single_line_text', :name => "Occupation", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][participations_risk_factor][risk_factors]", :field_type => 'single_line_text', :name => "Risk factors", :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[active_patient][participations_risk_factor][risk_factors_notes]", :field_type => 'multi_line_text', :name => "Risk factors notes", :can_follow_up => false, :event_type => 'contact_event' },
     
      # Disease-level fields
      {:key => "contact_event[disease][disease_id]", :field_type => 'drop_down', :name => 'Disease', :can_follow_up => false, :event_type => 'contact_event' },
      {:key => "contact_event[disease][disease_onset_date]", :field_type => 'date', :name => 'Disease onset date', :can_follow_up => false, :event_type => 'contact_event' },
      {:key => "contact_event[disease][date_diagnosed]", :field_type => 'date', :name => 'Disease date diagnosed', :can_follow_up => false, :event_type => 'contact_event' },
      {:key => "contact_event[disease][hospitalized_id]", :field_type => 'drop_down', :name => 'Hospitalized', :can_follow_up => true, :event_type => 'contact_event' },
      {:key => "contact_event[disease][died_id]", :field_type => 'drop_down', :name => 'Died', :can_follow_up => true, :event_type => 'contact_event' },
      
      # Multiples wrappers
      {:key => "contact_event[treatments]", :field_type => 'drop_down', :name => 'Treatments', :can_follow_up => false, :event_type => 'contact_event' },
    ]
  end

end
