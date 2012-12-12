# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

def log_in_as(user)
  visit home_path unless current_url
  begin
  select user, :from => "user_id"
  submit_form "switch_user"
  rescue Exception => e
    case e.message
    when 'Could not find field: "user_id"'
      raise "Please check your site_config.yml and make sure the test enviornment includes auth_src_env: TRISANO_UID, auth_allow_user_switch: true"
    else
      raise e.message
    end
  end
  @current_user = User.find_by_user_name(user)
end

def create_basic_event(event_type, last_name=nil, disease=nil, jurisdiction=nil)

  # notes need a user, so set to default if current user is nil
  User.current_user ||= User.find_by_uid('default')
  returning Kernel.const_get(event_type.capitalize + "Event").new do |event|

    event.first_reported_PH_date = Date.yesterday.to_s(:db) if event.respond_to?(:first_reported_PH_date)

    if event_type.to_s.downcase=="encounter" or event_type.to_s.downcase == "contact"
      event.parent_event = create_basic_event("assessment", get_random_word, disease, jurisdiction)
    end

    if event_type.to_s.downcase=="encounter" 
      event.build_participations_encounter(:user => User.current_user,
                                           :encounter_date => event.first_reported_PH_date, 
                                           :encounter_location_type => ParticipationsEncounter.valid_location_types.first)
    end

    if last_name.nil?
      event.interested_party = InterestedParty.create(:primary_entity_id => @person.id)
    else
      event.attributes = { :interested_party_attributes => { :person_entity_attributes => { :person_attributes => { :last_name => last_name } } } }
    end

    event.build_disease_event(:disease => Disease.find_or_create_by_disease_name(:active => true, :disease_name => disease)) if disease
    event.build_jurisdiction(:secondary_entity_id => Place.all_by_name_and_types(jurisdiction || "Unassigned", 'J', true).first.entity_id)
    event.add_note("Dummy Note")
    event.save!
  end
end

def unassigned_jurisdiction
  Place.all_by_name_and_types("Unassigned", 'J', true).first
end

def create_event_with_attributes(event_type, last_name, attrs, disease=nil, jurisdiction=nil)
  e = create_basic_event(event_type, last_name, disease, jurisdiction)
  e.attributes = attrs
  e.save!
  e
end

def add_encounter_to_event(event, options={})
  returning event.encounter_child_events.build do |child|
    child.attributes = { :participations_encounter_attributes => {
      :encounter_date => options[:encounter_date] || Date.today,
      :user_id => options[:user_id] || 1,
      :encounter_location_type => options[:location_id] || "clinic" }
    }
    event.save!
    child.save
  end
end

def jurisdiction_id_by_name(name)
  Place.all_by_name_and_types(name || "Unassigned", 'J', true).first.entity_id
end

# Core field keys do not have the _attributes in them that Rails throws
# in for nested forms. This method takes a core field key and converts it
# to a key that can be used to identify form elements in the browser.
def railsify_core_field_key(key)
  key.chop.gsub("]", "_attributes]") << "]"
end

# Debt: Replace these with factory-based setup
def place_child_events_attributes(values)
  { "5"=>{
      "interested_place_attributes"=>{
        "place_entity_attributes"=>{
          "place_attributes"=>{
            "name"=>"#{values[:name]}"
          }
        }
      },
      "participations_place_attributes"=>{
        "date_of_exposure"=>""
      }
    }
  }
end

def lab_attributes(values)
  { "3"=>{
      "place_entity_attributes"=>{
        "place_attributes"=>{
          "name"=>"#{values[:name] if values[:name]}"
        }
      },
      "lab_results_attributes"=>{
        "0"=>{
          "test_type_id"=>"#{values[:test_type_id] if values[:test_type_id]}", "reference_range"=>"",
          "specimen_source_id"=>"", "collection_date"=>"", "lab_test_date"=>"", "specimen_sent_to_state_id"=>""
        }
      }
    }
  }
end

def add_path_to(page_name, path_str=nil, &path_proc)
  Cucumber::Rails::World.class_eval do
    @@extension_path_names << {
      :page_name => page_name,
      :path => path_str || path_proc
    }
  end
end

def invalidate_date_diagnosed(event)
  DiseaseEvent.update_all("disease_onset_date = '#{Date.today + 1.month}', date_diagnosed = '#{Date.today}'", ['event_id = ?', event.id])
end

def invalidate_disease_onset_date(event)
  invalid_date = event.first_reported_PH_date + 1.month
  DiseaseEvent.update_all("disease_onset_date = '#{invalid_date}'", ['event_id = ?', event.id])
end

# A dirty, filthy hack because succ! seems to be broken in JRuby on 64
# bit Java
String.class_eval do
  def loinc_succ
    (self.gsub('-', '').to_i + 1).to_s.insert(-2, '-')
  end
end

