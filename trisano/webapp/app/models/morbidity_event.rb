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

class MorbidityEvent < Event
  
  # A hash that provides a basic field index for the event forms. It maps the event form
  # attribute keys to some metadata that is used to drive core field and core follow-up
  # configurations in form builder.
  # 
  # Names do not have to match the field name on the form views. Names are used to 
  # drive the drop downs for core field and core follow up configurations. So more context
  # can be given to these names than might appear on the actual event forms, because in
  # drop down in form builder, 'Last name' isn't going to be enough information for the user.
  def self.exposed_attributes
    {
      "morbidity_event[active_patient][active_primary_entity][person][last_name]" => {:type => :single_line_text, :name => "Patient last name" },
      "morbidity_event[active_patient][active_primary_entity][person][first_name]" => {:type => :single_line_text, :name => "Patient first name" },
      "morbidity_event[active_patient][active_primary_entity][person][middle_name]" => {:type => :single_line_text, :name => "Patient middle name" },
      "morbidity_event[active_patient][active_primary_entity][address][street_number]" => {:type => :single_line_text, :name => "Patient street number" },
      "morbidity_event[active_patient][active_primary_entity][address][street_name]" => {:type => :single_line_text, :name => "Patient street name" },
      "morbidity_event[active_patient][active_primary_entity][address][unit_number]" => {:type => :single_line_text, :name => "Patient unit number" },
      "morbidity_event[active_patient][active_primary_entity][address][city]" => {:type => :single_line_text, :name => "Patient city" },
      "morbidity_event[active_patient][active_primary_entity][address][state_id]" => {:type => :single_line_text, :name => "Patient state" },
      "morbidity_event[active_patient][active_primary_entity][address][county_id]" => {:type => :single_line_text, :name => "Patient county" },
      "morbidity_event[active_patient][active_primary_entity][address][postal_code]" => {:type => :single_line_text, :name => "Patient zip code" },
      "morbidity_event[active_patient][active_primary_entity][person][birth_date]" => {:type => :date, :name => "Patient date of birth" },
      "morbidity_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => {:type => :single_line_text, :name => "Patient age" },
      "morbidity_event[active_patient][active_primary_entity][person][date_of_death]" => {:type => :date, :name => "Patient date of death" },
      "morbidity_event[active_patient][active_primary_entity][person][birth_gender_id]" => {:type => :single_line_text, :name => "Patient birth gender" },
      "morbidity_event[active_patient][active_primary_entity][person][ethnicity_id]" => {:type => :single_line_text, :name => "Patient ethnicity" },
      "morbidity_event[active_patient][active_primary_entity][person][primary_language_id]" => {:type => :single_line_text, :name => "Patient primary language" },
      # "morbidity_event[active_patient][active_primary_entity][race_ids][]" => {:type => :single_line_text, :name => "Patient race" }
      
      # Risk factors
      "morbidity_event[active_patient][participations_risk_factor][pregnant_id]" => {:type => :drop_down, :name => "Pregnant" },
      "morbidity_event[active_patient][participations_risk_factor][pregnancy_due_date]" => {:type => :date, :name => "Pregnancy due date" },
      "morbidity_event[active_patient][participations_risk_factor][food_handler_id]" => {:type => :drop_down, :name => "Food handler" },
      "morbidity_event[active_patient][participations_risk_factor][healthcare_worker_id]" => {:type => :drop_down, :name => "Healthcare worker" },
      "morbidity_event[active_patient][participations_risk_factor][group_living_id]" => {:type => :drop_down, :name => "Group living" },
      "morbidity_event[active_patient][participations_risk_factor][day_care_association_id]" => {:type => :drop_down, :name => "Day care association" },
      "morbidity_event[active_patient][participations_risk_factor][occupation]" => {:type => :single_line_text, :name => "Occupation" },
      "morbidity_event[active_patient][participations_risk_factor][risk_factors]" => {:type => :single_line_text, :name => "Risk factors" },
      "morbidity_event[active_patient][participations_risk_factor][risk_factors_notes]" => {:type => :multi_line_text, :name => "Risk factors notes" },

      # Event-level fields
      "morbidity_event[results_reported_to_clinician_date]" => {:type => :single_line_text, :name => "Results reported to clinician date"},
      "morbidity_event[first_reported_PH_date]" => {:type => :single_line_text, :name => "Date first reported to public health"},
      "morbidity_event[lhd_case_status_id]" => {:type => :drop_down, :name => 'LHD case status'},
      "morbidity_event[udoh_case_status_id]" => {:type => :drop_down, :name => 'UDOH case status'},
      "morbidity_event[outbreak_associated_id]" => {:type => :drop_down, :name => 'Outbreak associated'},
      "morbidity_event[outbreak_name]" => {:type => :single_line_text, :name => 'Outbreak'},
      "morbidity_event[active_jurisdiction][secondary_entity_id]" => {:type => :multi_select, :name => 'Jurisdiction responsible for investigation'},
      "morbidity_event[event_status]" => {:type => :drop_down, :name => 'Event status'},
      "morbidity_event[investigation_started_date]" => {:type => :single_line_text, :name => 'Date investigation started'},
      "morbidity_event[investigation_completed_LHD_date]" => {:type => :single_line_text, :name => 'Date investigation completed'},
      "morbidity_event[event_name]" => {:type => :single_line_text, :name => 'Event name'},
      "morbidity_event[review_completed_UDOH_date]" => {:type => :single_line_text, :name => 'Date review completed by UDOH'},
      "morbidity_event[imported_from_id]" => {:type => :drop_down, :name => 'Imported from'},
     
      # Reporting-level fields
      "morbidity_event[active_reporting_agency][active_secondary_entity][place][name]" => {:type => :drop_down, :name => 'Reporting agency'},
      "morbidity_event[active_reporter][active_secondary_entity][person][first_name]" => {:type => :drop_down, :name => 'Reporter first name'},
      "morbidity_event[active_reporter][active_secondary_entity][person][last_name]" => {:type => :drop_down, :name => 'Reporter last name'},
      "morbidity_event[active_reporter][active_secondary_entity][telephone_entities_location][entity_location_type_id]" => {:type => :drop_down, :name => 'Reporter phone type'},
      "morbidity_event[active_reporter][active_secondary_entity][telephone][area_code]" => {:type => :drop_down, :name => 'Reporter area code'},
      "morbidity_event[active_reporter][active_secondary_entity][telephone][phone_number]" => {:type => :drop_down, :name => 'Reporter phone number'},
      "morbidity_event[active_reporter][active_secondary_entity][telephone][extension]" => {:type => :drop_down, :name => 'Reporter extension'},
      
      # Disease-level fields
      "morbidity_event[disease][disease_id]" => {:type => :drop_down, :name => 'Disease'},
      "morbidity_event[disease][disease_onset_date]" => {:type => :date, :name => 'Disease onset date'},
      "morbidity_event[disease][date_diagnosed]" => {:type => :date, :name => 'Disease date diagnosed'},
      "morbidity_event[disease][hospitalized_id]" => {:type => :drop_down, :name => 'Hospitalized'},
      "morbidity_event[disease][died_id]" => {:type => :drop_down, :name => 'Died'}
        
    }
  end
  
  def self.core_views
    [
      ["Demographics", "Demographics"], 
      ["Clinical", "Clinical"], 
      ["Laboratory", "Laboratory"], 
      ["Contacts", "Contacts"],
      ["Epidemiological", "Epidemiological"], 
      ["Reporting", "Reporting"], 
      ["Administrative", "Administrative"]
    ]
  end
  
end
