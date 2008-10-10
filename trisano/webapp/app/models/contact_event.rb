# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

class ContactEvent < HumanEvent

  class << self
    def initialize_from_morbidity_event(morbidity_event)
      contact_events = []
      morbidity_event.contacts.select(&:new_record?).each do |contact|

        primary = Participation.new
        primary.primary_entity = contact.secondary_entity
        primary.role_id = Event.participation_code('Interested Party')
        primary.primary_entity.entity_type = "person"

        contact = Participation.new
        contact.secondary_entity = morbidity_event.active_patient.primary_entity
        contact.role_id = Event.participation_code('Contact')

        jurisdiction = Participation.new
        jurisdiction.secondary_entity = morbidity_event.active_jurisdiction.secondary_entity
        jurisdiction.role_id = Event.participation_code('Jurisdiction') 

        unless morbidity_event.disease.nil?
          disease_event = DiseaseEvent.new
          disease_event.disease = morbidity_event.disease.disease
        end

        contact_event = ContactEvent.new
        contact_event.participations << primary
        contact_event.participations << contact
        contact_event.participations << jurisdiction
        contact_event.disease_event = disease_event unless morbidity_event.disease.nil?
        contact_events << contact_event
      end
      contact_events
    end
  end
  
  # A hash that provides a basic field index for the contact event forms. It maps the form
  # attribute keys to some metadata that is used to drive core field and core follow-up
  # configurations in form builder.
  # 
  # Names do not have to match the field name on the form views. Names are used to 
  # drive the drop downs for core field and core follow up configurations. So more context
  # can be given to these names than might appear on the actual event forms, because in
  # drop down in form builder, 'Last name' isn't going to be enough information for the user.
  def self.exposed_attributes
    {
      "contact_event[active_patient][active_primary_entity][person][last_name]" => {:type => :single_line_text, :name => "Contact last name", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][person][first_name]" => {:type => :single_line_text, :name => "Contact first name", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][person][middle_name]" => {:type => :single_line_text, :name => "Contact middle name", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][address][street_number]" => {:type => :single_line_text, :name => "Contact street number", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][address][street_name]" => {:type => :single_line_text, :name => "Contact street name", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][address][unit_number]" => {:type => :single_line_text, :name => "Contact unit number", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][address][city]" => {:type => :single_line_text, :name => "Contact city", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][address][state_id]" => {:type => :single_line_text, :name => "Contact state", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][address][county_id]" => {:type => :single_line_text, :name => "Contact county", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][address][postal_code]" => {:type => :single_line_text, :name => "Contact zip code", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][person][birth_date]" => {:type => :date, :name => "Contact date of birth", :can_follow_up => false },
      "contact_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => {:type => :single_line_text, :name => "Contact age", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][person][date_of_death]" => {:type => :date, :name => "Contact date of death", :can_follow_up => false },
      "contact_event[active_patient][active_primary_entity][person][birth_gender_id]" => {:type => :single_line_text, :name => "Contact birth gender", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][person][ethnicity_id]" => {:type => :single_line_text, :name => "Contact ethnicity", :can_follow_up => true },
      "contact_event[active_patient][active_primary_entity][person][primary_language_id]" => {:type => :single_line_text, :name => "Contact primary language", :can_follow_up => true },

      # contact_event_active_patient__person_disposition_id
      # "contact_event[active_patient][race_ids][]" => {:type => :single_line_text, :name => "Patient race" }
      
      # Event-level fields
      "contact_event[imported_from_id]" => {:type => :drop_down, :name => 'Imported from', :can_follow_up => true },
      
      # Risk factors
      "contact_event[active_patient][participations_risk_factor][pregnant_id]" => {:type => :drop_down, :name => "Pregnant", :can_follow_up => true },
      "contact_event[active_patient][participations_risk_factor][pregnancy_due_date]" => {:type => :date, :name => "Pregnancy due date", :can_follow_up => false },
      "contact_event[active_patient][participations_risk_factor][food_handler_id]" => {:type => :drop_down, :name => "Food handler", :can_follow_up => true },
      "contact_event[active_patient][participations_risk_factor][healthcare_worker_id]" => {:type => :drop_down, :name => "Healthcare worker", :can_follow_up => true },
      "contact_event[active_patient][participations_risk_factor][group_living_id]" => {:type => :drop_down, :name => "Group living", :can_follow_up => true },
      "contact_event[active_patient][participations_risk_factor][day_care_association_id]" => {:type => :drop_down, :name => "Day care association", :can_follow_up => true },
      "contact_event[active_patient][participations_risk_factor][occupation]" => {:type => :single_line_text, :name => "Occupation", :can_follow_up => true },
      "contact_event[active_patient][participations_risk_factor][risk_factors]" => {:type => :single_line_text, :name => "Risk factors", :can_follow_up => true },
      "contact_event[active_patient][participations_risk_factor][risk_factors_notes]" => {:type => :multi_line_text, :name => "Risk factors notes", :can_follow_up => false },
     
      # Disease-level fields
      "contact_event[disease][disease_id]" => {:type => :drop_down, :name => 'Disease', :can_follow_up => false },
      "contact_event[disease][disease_onset_date]" => {:type => :date, :name => 'Disease onset date', :can_follow_up => false },
      "contact_event[disease][date_diagnosed]" => {:type => :date, :name => 'Disease date diagnosed', :can_follow_up => false },
      "contact_event[disease][hospitalized_id]" => {:type => :drop_down, :name => 'Hospitalized', :can_follow_up => true },
      "contact_event[disease][died_id]" => {:type => :drop_down, :name => 'Died', :can_follow_up => true },
      
      # Multiples wrappers
      "contact_event[treatments]" => {:type => :drop_down, :name => 'Treatments', :can_follow_up => false }
      
    }
  end
  
  def self.core_views
    [
      ["Demographics", "Demographics"], 
      ["Clinical", "Clinical"], 
      ["Laboratory", "Laboratory"], 
      ["Epidemiological", "Epidemiological"]
    ]
  end

  def save_associations
    super
  end

end
