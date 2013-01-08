# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

Given /^a ([^\"]*) event exists in jurisdiction "([^\"]*)"$/ do |type, jurisdiction|
  @event = create_basic_event(type, get_random_word, "African Tick Bite Fever", jurisdiction)
end

Given /^a ([^\"]*) event with record number "([^\"]*)"$/ do |type, record_number|
  @event = create_basic_event(type, get_random_word, "African Tick Bite Fever", "Unassigned")
  @event.save!
  @event.record_number = record_number
  @event.save!
end

Given /^a routed (.+) event for last name (.+)$/ do |event_type, last_name|
  @event = create_basic_event(event_type, last_name, nil, 'Unassigned')
  @event.assign_to_lhd(Place.jurisdiction_by_name("Bear River Health Department"), [], "")
  @event.save!
end

Given /^the event has the following place exposures:$/ do |places|
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

Given /^the event is assigned to user "([^\"]*)"$/ do |user_id|
  @event.workflow_state = 'under_investigation'
  @event.investigator = User.find_by_uid user_id
  @event.save!
end

Given /^the patient is named "([^\"]*)"$/i do |last_name|
  @patient = @event.interested_party.person_entity.person
  @patient.last_name = last_name
  @patient.save!
end

Given /^the patient was born on "([^\"]*)"$/i do |date|
  birth_date = Date.parse(date)
  @patient = @event.interested_party.person_entity.person
  @patient.birth_date = birth_date
  @patient.save!
end

Given /^the event is in "([^\"])*" county$/i do |county|
  county = ExternalCode.counties.find(:first, :conditions => {:code_description => county})
  if @event.address
    @event.address.county = county
  else
    @event.build_address(:county => county)
  end
  @event.save!
end

Given /^the event is in the city of "([^\"]*)"$/ do |city|
  if @event.address
    @event.address.city = city
  else
    @event.build_address(:city => city)
  end
  @event.save!
end

Given /^the disease is "([^\"]*)"$/i do |disease_name|
  disease = Disease.find_or_create_by_disease_name(disease_name)
  disease.update_attributes! :active => true
  @event.build_disease_event(:disease => disease)
  @event.save!
end

Given /^the disease onset date is "([^\"]*)"/i do |date|
  @onset_date = Date.parse(date)
  @event.disease_event.disease_onset_date = @onset_date
  @event.save!
end

Given /^the contact disease diagnosed date is invalid$/ do
  invalidate_date_diagnosed(@contact_event)
end

Given /^the event disease diagnosed date is invalid$/ do
  invalidate_date_diagnosed(@event)
end

Given /^the contact disease onset date is invalid$/ do
  invalidate_disease_onset_date(@contact_event)
end

Given /^the event disease onset date is invalid$/ do
  invalidate_disease_onset_date(@event)
end

Given /^I am not able to update events$/ do
  User.current_user.roles.each do |role|
    role.privileges.each do |priv|
      if priv.priv_name == 'update_event'
        priv.privileges_roles.each { |pr| pr.delete }
        priv.delete
      end
    end
  end
end

Given /^the event is routed to "([^\"]*)"$/ do |short_name|
  jurisdiction_id = Place.find_by_short_name(short_name).entity_id
  @event.assign_to_lhd(jurisdiction_id, [])
  @event.save!
end

Given /^the contact is routed to "([^\"]*)"$/ do |short_name|
  jurisdiction_id = Place.find_by_short_name(short_name).entity_id
  @contact_event.assign_to_lhd(jurisdiction_id, [])
  @contact_event.save!
end

When /^I visit the events index page$/ do
  visit events_path
end

When(/^I navigate to the morbidity event edit page$/) do
  visit edit_cmr_path(@event)
end

When(/^I navigate to the morbidity event show page$/) do
  visit cmr_path(@event)
end

When(/^I navigate to the new morbidity event page$/) do
  visit new_cmr_path
end

When /^I navigate to the add attachments page$/ do
  visit new_event_attachment_path(@event)
end

When(/^I navigate to the contact event show page$/) do
  visit contact_event_path(@event)
end

When(/^I navigate to the place event edit page$/) do
  visit edit_place_event_path(@place_event)
end

When(/^I navigate to the contact event edit page$/) do
  visit edit_contact_event_path(@contact_event)
end

When /^I "([^\"]*)" the routed event$/ do |action|
  set_hidden_field "morbidity_event[workflow_action]", :to => action.downcase
  submit_form "state_change"
end

Then(/^I should see event forms popup$/) do
  response.should have_xpath("//div[@id='form-references-dialog']")
end

Then(/^I should not see event forms popup$/) do
  response.should_not have_xpath("//div[@id='form-references-dialog']")
end

Then /^the AE should look deleted$/ do
  response.should have_xpath("//div[@class='patientname-inactive']")
end

Then /^the CMR should look deleted$/ do
  response.should have_xpath("//div[@class='patientname-inactive']")
end

Then /^the Contact event should look deleted$/ do
  response.should have_xpath("//div[@class='patientname-inactive']")
end

Then /^the Contact event should not look deleted$/ do
  response.should_not have_xpath("//div[@class='patientname-inactive']")
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

Then /^I should have a note that says "([^\"]*)"$/ do |text|
  response.should have_xpath("//div[@id='note-list']//p[contains(text(), '#{text}')]")
end

Then /^I should have a (.*) error message box$/i do |div_class|
  div_class = div_class.strip.gsub(' ', '_')
  response.should have_xpath("//div[@class='#{div_class}']/div[@id='errorExplanation'][1]")

  # Make sure there is only one error explanation box
  response.should_not have_xpath("//div[@class='#{div_class}']/div[@id='errorExplanation'][2]")
end

Then /^I should not have a (.*) error message box$/i do |div_class|
  div_class = div_class.strip.gsub(' ', '_')
  response.should_not have_xpath("//div[@class='#{div_class}']/div[@id='errorExplanation']")
end

Then /^I should have a (.*) error message containing "([^\"]*)"$/i do |div_class, message_part|
  div_class = div_class.strip.gsub(' ', '_')
  response.should have_xpath("//div[@class='#{div_class}']/div[@id='errorExplanation']/ul/li[contains(text(),\"#{message_part}\")]")
  response.should_not have_xpath("//div[@class='#{div_class}']/div[@id='errorExplanation']/ul/li[contains(text(),\"#{message_part}\")][2]")
end

Then /^jurisdiction "([^\"]*)" should be selected$/ do |jurisdiction|
  response.should have_xpath("//select[contains(@id, 'jurisdiction_attributes')]/option[text()='#{jurisdiction}' and @selected='selected']")
end

Given /^max_search_results \+ 1 basic (.*) events/i do |event_type|
  count = config_option(:max_search_results).to_i
  count.to_i.times do |i|
    create_basic_event(event_type, get_random_word, "African Tick Bite Fever", "Unassigned")
  end
end

Given /^the event has a (.+) note authored by "([^\"]*)"$/ do |note_type, author_uid|
  author = User.find_by_user_name(author_uid)
  @event.add_note("My God, it's full of stars", note_type, :user => author)
end

Then /^I should see the pregnancy fields in the right place$/ do
  response.should have_tag('#disease_info_form .form') do
    with_tag('legend', 'Pregnancy Status') do
      with_tag('~ .horiz label', 'Pregnant')
      with_tag('~ .horiz label', 'Expected delivery date')
    end
  end
end

Then /^I should see the mortality fields in the right place$/ do
  response.should have_tag('#disease_info_form .form') do
    with_tag('legend', 'Mortality Status') do
      with_tag('~ .horiz label', 'Died')
      with_tag('~ .horiz label', 'Date of death')
      without_tag('~ .horiz label', 'Pregnant')
    end
  end
end

Then /^I should see the pregnancy data in the right place$/ do
  response.should have_tag('#clinical_tab .form') do
    with_tag('legend', 'Pregnancy Status') do
      with_tag('~ .horiz label', 'Pregnant')
      with_tag('~ .horiz label', 'Expected delivery date')
    end
  end
end

Then /^I should see the mortality data in the right place$/ do
  response.should have_tag('#clinical_tab .form') do
    with_tag('legend', 'Mortality Status') do
      with_tag('~ .horiz label', 'Died')
      with_tag('~ .horiz label', 'Date of death')
      without_tag('~ .horiz label', 'Pregnant')
    end
  end
end

When /^I enter a diagnostic facility name and type$/ do
  When %{I fill in "Name" with "Zed's Lab" within ".new_diagnostic_facility"}
  When %{I check "Laboratory" within ".new_diagnostic_facility"}
end

When /^I enter a place exposure's name and type$/ do
  When %{I fill in "Name" with "Olive Guardian" within "#new_place_exposure"}
  When %{I check "Correctional Facility" within "#new_place_exposure"}
end

When /^I enter a diagnostic facility address$/ do
  When %{I fill in "Street number" with "1" within ".new_diagnostic_facility"}
  When %{I fill in "Street name" with "Happy" within ".new_diagnostic_facility"}
  When %{I select "Utah" from "State" within ".new_diagnostic_facility"}
  When %{I fill in "Zip code" with "55555" within ".new_diagnostic_facility"}
end

When /^I enter the place exposure's address$/ do
  When %{I fill in "Street number" with "1" within "#new_place_exposure"}
  When %{I fill in "Street name" with "Happy" within "#new_place_exposure"}
  When %{I select "Utah" from "State" within "#new_place_exposure"}
  When %{I fill in "Zip code" with "55555" within "#new_place_exposure"}
end

# Local Variables:
# mode: ruby
# tab-width: 2
# ruby-indent-level: 2
# indent-tabs-mode: nil
# End:
