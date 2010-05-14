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

Given(/^a basic morbidity event exists$/) do
  @event = create_basic_event("morbidity", get_unique_name(1), get_random_disease, get_random_jurisdiction_by_short_name)
end

Given(/^a morbidity event exists with the disease (.+)$/) do |disease|
  @event = create_basic_event("morbidity", get_unique_name(1), disease, get_random_jurisdiction_by_short_name)
  @event.disease_event.disease_onset_date = Date.today
  @event.build_address(:county => ExternalCode.counties.first)
  @event.save!
end

Given /^morbidity events with the following diseases:$/ do |table|
  table.rows.each do |disease|
    create_basic_event("morbidity", get_unique_name(1), disease.first, get_random_jurisdiction_by_short_name)
  end
end


Given(/^a (.+) event exists with a lab result having test type '(.+)'$/) do |event_type, test_type|
  test_type_id = CommonTestType.find_by_common_name(test_type).id
  attrs = { "labs_attributes" =>
      [ { "place_entity_attributes" => { "place_attributes" => { "name" => "Quest" } },
        "lab_results_attributes"  => [ { "test_type_id" => test_type_id } ]
      } ]
  }
  @event = create_event_with_attributes(event_type, get_unique_name(1), attrs, nil, get_random_jurisdiction_by_short_name)
end

Given(/^a (.+) event exists in (.+) with the disease (.+)$/) do |event_type, jurisdiction, disease|
  @event = create_basic_event(event_type, get_unique_name(1), disease, jurisdiction)
end

Given(/^a (.+) event exists with a disease that matches the form$/) do |event_type|
  @event = create_basic_event(event_type, get_unique_name(1), @form.diseases.first.disease_name, get_random_jurisdiction_by_short_name)
end

Given /^a simple (.+) event in jurisdiction (.+) for last name (.+)$/ do |event_type, jurisdiction, last_name|
  @event = create_basic_event(event_type, last_name, nil, jurisdiction)
end

Given /^a simple (.+) event in jurisdiction (.+) for the full name of (.+)$/ do |event_type, jurisdiction, name|
  # Currently assumes a first, middle and last name is supplied
  name_array = name.split
  first_name = name_array[0]
  middle_name = name_array[1]
  last_name = name_array[2]
  
  attrs = {
    "interested_party_attributes"=>
      { "person_entity_attributes"=>
        { "person_attributes"=>
          { "first_name" => "#{first_name}", "middle_name" => "#{middle_name}", "last_name" => "#{last_name}"}
        }
      }
  }
  @event = create_event_with_attributes(event_type, last_name, attrs, nil, jurisdiction)
end

Given(/^there is a contact event$/) do
  @contact_event = Factory.build(:contact_event)
  @contact_event.build_jurisdiction(:secondary_entity_id => Place.all_by_name_and_types("Unassigned", 'J', true).first.entity_id)
  @contact_event.save!
end

Given /^there is a contact on the event named (.+)$/ do |last_name|
  @contact_event = add_contact_to_event(@event, last_name)
end

Given /^the contact event is deleted$/i do
  @contact_event.update_attributes!(:deleted_at => Time.now)
end

Given(/^the disease-specific questions for the event have been answered$/) do
  @answer_text = "#{get_unique_name(2)} answer"
  question_elements = FormElement.find_all_by_form_id_and_type(@published_form.id, "QuestionElement", :include => [:question])
  question_elements.each do |element|
    Answer.create({ :event_id => @event.id, :question_id => element.question.id, :text_answer => @answer_text })
  end
end

Given /^there is a place on the event named (.+)$/ do |name|
  @place_event = add_place_to_event(@event, name)
end


Given /^all core field configs for a (.+) have help text$/ do |event_type|
  CoreField.find_all_by_event_type(event_type.gsub(" ", "_")).each do |core_field|
    core_field.help_text = core_field.key << " help text"
    core_field.save!
  end
end

Given /^the event has a lab$/i do
  lab = Factory.build(:lab)
  @event.labs << lab
  @event.save!
end
