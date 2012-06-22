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

Given(/^a basic morbidity event exists$/) do
  @event = create_basic_event("morbidity", get_unique_name(1), get_random_disease, get_random_jurisdiction_by_short_name)
end

Given(/^a basic assessment event exists$/) do
  @event = create_basic_event("assessment", get_unique_name(1), get_random_disease, get_random_jurisdiction_by_short_name)
end

Given /^a cmr exists$/ do
  @event = create_basic_event("morbidity", get_unique_name(1), get_random_disease, get_random_jurisdiction_by_short_name)
end

Given(/^an assessment event exists with the disease (.+)$/) do |disease|
  @event = create_basic_event("assessment", get_unique_name(1), disease.strip, get_random_jurisdiction_by_short_name)
  @event.disease_event.disease_onset_date = Date.yesterday
  @event.build_address(:county => ExternalCode.counties.first)
  @event.save!
end

Given(/^a morbidity event exists with the disease (.+)$/) do |disease|
  @event = create_basic_event("morbidity", get_unique_name(1), disease.strip, get_random_jurisdiction_by_short_name)
  @event.disease_event.disease_onset_date = Date.yesterday
  @event.build_address(:county => ExternalCode.counties.first)
  @event.save!
end

Given /^morbidity events with the following diseases:$/ do |table|
  table.rows.each do |disease|
    create_basic_event("morbidity", get_unique_name(1), disease.first, get_random_jurisdiction_by_short_name)
  end
end

Given /^there is a (.+) event with a task$/ do |event_type|
  @event = create_basic_event(event_type, get_unique_name(1), get_random_disease, get_random_jurisdiction_by_short_name)
  @event.tasks.create :name => 'follow up', :due_date => Date.tomorrow, :user => User.current_user
end

Given /^a simple (.+) event for last name (.+)$/ do |event_type, last_name|
  @event = create_basic_event(event_type, last_name)
end

Given /^a simple (.+) event, last name (.+), and disease (.+)$/ do |event_type, last_name, disease|
  @event = create_basic_event(event_type, last_name, disease)
end

Given /^a simple (.+) event for full name (.+)$/ do |event_type, name|
  first_name, last_name = name.split(" ")
  attrs = { :interested_party_attributes => { :person_entity_attributes => { :person_attributes => { :first_name => first_name, :last_name => last_name }}}}
  @event = create_event_with_attributes(event_type, last_name, attrs)
end

Given /^the person has a simple (.+) event$/ do |event_type|
  @event = create_basic_event(event_type)
end

Given /^the person has a simple (.+) event with the disease (.+)$/ do |event_type, disease|
  @event = create_basic_event(event_type, nil, disease)
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

Given /^a simple (.+) event in jurisdiction (.+), last name (.+), and disease (.+)$/ do |event_type, jurisdiction, last_name, disease|
  @event = create_basic_event(event_type, last_name, disease, jurisdiction)
end

Given /^the (.+) event was created (.+)$/ do |event_type, date|
  case event_type
  when "contact"
    event = @contact_event
  when "place"
    event = @place_event
  else
    event = @event
  end

  new_date = eval(date.split(" ").join(".")).to_date
  event.first_reported_PH_date = new_date - 1.day
  event.created_at = new_date
  event.save!
end

Given /^the morbidity event state workflow state is "([^\"]*)"$/ do |workflow_state|
  @event.workflow_state = workflow_state
  @event.save!
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

Given /^(.+) simple (.+) events for last name (.+)$/ do |count, event_type, last_name|
  count.to_i.times do |count|
    attrs = { :interested_party_attributes => { :person_entity_attributes => { :person_attributes => { :first_name => count, :last_name => last_name }}}}
    @event = create_event_with_attributes(event_type, last_name, attrs)
  end
end

Given /^the morbidity event has the following contacts:$/ do |contacts|
  @contact_events = []
  contacts.hashes.each do |contact|
    hash = {
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => contact
        }
      },
      "jurisdiction_attributes" => { "secondary_entity_id" => Place.all_by_name_and_types("Unassigned", 'J', true).first.entity_id }
    }

    if disease_id = @event.try(:disease_event).try(:disease).try(:id)
      hash.merge!({ "disease_event_attributes"=> { "disease_id"=> disease_id }})
    end
    @contact_events << ContactEvent.create!(hash)
    @event.contact_child_events << @contact_events.last
  end
end

Given /^the assessment event has the following contacts:$/ do |contacts|
  @contact_events = []
  contacts.hashes.each do |contact|
    hash = {
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => contact
        }
      },
      "jurisdiction_attributes" => { "secondary_entity_id" => Place.all_by_name_and_types("Unassigned", 'J', true).first.entity_id }
    }

    if disease_id = @event.try(:disease_event).try(:disease).try(:id)
      hash.merge!({ "disease_event_attributes"=> { "disease_id"=> disease_id }})
    end
    @contact_events << ContactEvent.create!(hash)
    @event.contact_child_events << @contact_events.last
  end
end

Given /^the assessment event has the following deleted contacts:$/ do |contacts|
  contacts.hashes.each do |contact|
    hash = {
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => contact
        }
      },
      "jurisdiction_attributes" => { "secondary_entity_id" => Place.all_by_name_and_types("Unassigned", 'J', true).first.entity_id }
    }
    @event.contact_child_events << ContactEvent.create(hash)
    @event.contact_child_events.last.transactional_soft_delete
  end
  @event.save!
end

Given /^the morbidity event has the following deleted contacts:$/ do |contacts|
  contacts.hashes.each do |contact|
    hash = {
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => contact
        }
      },
      "jurisdiction_attributes" => { "secondary_entity_id" => Place.all_by_name_and_types("Unassigned", 'J', true).first.entity_id }
    }
    @event.contact_child_events << ContactEvent.create(hash)
    @event.contact_child_events.last.transactional_soft_delete
  end
  @event.save!
end

Given(/^there is a contact event$/) do
  @contact_event = Factory.build(:contact_event)
  @contact_event.build_jurisdiction(:secondary_entity_id => Place.all_by_name_and_types("Unassigned", 'J', true).first.entity_id)
  @contact_event.save!
end

Given /^there is a contact on the event named (.+)$/ do |last_name|
  @contact_event = add_contact_to_event(@event, last_name)
end

Given /^the contact has the disease (.+)$/ do |disease|
  @contact_event.disease_event.destroy if @contact_event.disease_event.present?
  Factory(:disease_event, :disease => Disease.find_or_create_by_disease_name(:active => true, :disease_name => disease), :event_id => @contact_event.id)
  @contact_event.reload
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

Given /^all core fields have help text$/ do
  ActiveRecord::Base.connection.execute(<<-SQL)
    UPDATE core_field_translations a
    SET help_text = (
      SELECT key || ' help text' FROM core_fields b
       WHERE a.core_field_id = b.id)
    WHERE locale = '#{I18n.locale}'
  SQL
end

Given /^all core field configs for a (.+) have help text$/ do |event_type|
  CoreField.find_all_by_event_type(event_type.gsub(" ", "_")).each do |core_field|
    core_field.help_text = core_field.key << " help text"
    core_field.save!
  end
end

Given /^the event has a lab$/i do
  add_lab_to_event(@event, "ARUP")
end
