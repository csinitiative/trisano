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

Given /^a ([^\"]*) event in jurisdiction "([^\"]*)" assigned to "([^\"]*)" queue$/ do |type, jurisdiction, queue_name|
  @event = create_basic_event(type, get_random_word, "African Tick Bite Fever", jurisdiction)
  @event.event_queue = EventQueue.find_by_queue_name(queue_name)
  # TODO: investigator and disease can be removed once webrat multi select is fixed.
  @event.investigator_id = User.current_user
  @event.save!
end

Given /^a routed (.+) event for last name (.+)$/ do |event_type, last_name|
  @event = create_basic_event(event_type, last_name, nil, 'Unassigned')
  @event.assign_to_lhd(Place.jurisdiction_by_name("Bear River Health Department"), [], "")
  @event.save!
end

Given /^the morbidity event has the following place exposures:$/ do |places|
  places.hashes.each do |place|
    hash = {
      "interested_place_attributes" => {
        "place_entity_attributes" => {
          "place_attributes" => place
        }
      },
      "jurisdiction_attributes" => { "secondary_entity_id" => Place.all_by_name_and_types("Unassigned", 'J', true).first.entity_id }
    }
    @event.place_child_events << PlaceEvent.create!(hash)
  end
  @event.save!
end

Given /^the morbidity event state case status is "([^\"]*)"$/ do |description|
  case_status = ExternalCode.case.find_by_code_description description
  @event.state_case_status = case_status
  @event.save!
end

Given /^the morbidity event was sent to the CDC$/ do
  @event.sent_to_cdc = true
  @event.save!
end

Given /^the morbidity event is deleted$/ do
  @event.soft_delete
end

When /^I visit the events index page$/ do
  visit cmrs_path({})
end

When(/^I navigate to the event edit page$/) do
  visit edit_cmr_path(@event)
end

When(/^I navigate to the event show page$/) do
  visit cmr_path(@event)
end

When(/^I navigate to the new event page$/) do
  visit new_cmr_path
end

When /^I navigate to the add attachments page$/ do
  visit new_event_attachment_path(@event)
end

When(/^I navigate to the contact event show page$/) do
  visit contact_event_path(@event)
end

Then /^the CMR should look deleted$/ do
  response.should have_xpath("//div[@class='patientname-inactive']")
end

Then /^the Contact event should look deleted$/ do
  response.should have_xpath("//div[@class='patientname-inactive']")
end

Then /^the Place event should look deleted$/ do
  response.should have_xpath("//div[@class='placename-inactive']")
end

Then /^contact "([^\"]*)" should appear deleted$/ do |contact_name|
  response.should have_xpath("//td[@class='struck-through' and text()='#{contact_name}']")
end

Then /^place exposure "([^\"]*)" should appear deleted$/ do |place_name|
  response.should have_xpath("//td[@class='struck-through' and text()='#{place_name}']")
end
