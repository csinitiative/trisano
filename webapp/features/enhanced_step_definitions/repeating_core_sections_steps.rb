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

When /^I enter the following hospitalizations:$/ do |table|
  i = 0
  table.hashes.each do |hospital_attributes|
    i += 1
    add_hospital(@browser, hospital_attributes, i)
  end
end

Given /^a published form with repeating core fields for a (.+) event$/ do |event_type|
  disease_name = SecureRandom.hex(16)
  @form = create_form(event_type, 'Already created', 'something_published', disease_name)
  Given "that form has core field configs configured for all repeater core fields"
  @published_form = @form.publish
  sleep 1
end

Given /^a basic (.+) event with the form's disease$/ do |event_type|
  @event = create_basic_event(event_type, get_unique_name(1), @form.diseases.first.disease_name.strip,  Place.unassigned_jurisdiction.short_name)
end

When /^I navigate to the new morbidity event page and start a event with the form's disease$/ do
  @browser.open "/trisano/cmrs/new"
  add_demographic_info(@browser, { :last_name => get_unique_name })
  @browser.type('morbidity_event_first_reported_PH_date', Date.today)
  @browser.select('morbidity_event_disease_event_attributes_disease_id', @form.diseases.first.disease_name)
end

Then /^I should see all of the repeater core field config questions for each hospitalization$/ do
  @core_fields ||= CoreField.all(:conditions => ["event_type = ? AND fb_accessible = ? AND disease_specific = ? AND repeater = TRUE AND key LIKE '%hospitalization_facilities%'", @form.event_type, true, false])
  expected_count = @event.hospitalization_facilities.count.to_s
  @core_fields.each do |core_field|
    before_config_count = @browser.get_xpath_count("//label[contains(text(), '#{core_field.key} before?')]")
    (before_config_count==expected_count).should(be_true, "Expected '#{core_field.key} before?' label to appear #{expected_count} times. Got #{before_config_count}.")
    after_config_count = @browser.get_xpath_count("//label[contains(text(), '#{core_field.key} after?')]")
    (after_config_count==expected_count).should(be_true, "Expected '#{core_field.key} after?' label to appear #{expected_count} times. Got #{after_config_count}.")
  end
end

Then /^I should (.+) hospitalization save and discard buttons$/ do |see_not_see|
  if see_not_see == "see"
    expected_count = 1
  elsif see_not_see == "not see"
    expected_count = 0
  else
    raise "Unexpected statement."
  end

  save_button_count = @browser.get_xpath_count("//a[@class='save-new-hospital-participation']").to_i
  save_button_count.should be_equal(expected_count), "Expected to see #{expected_count} save buttons, got #{save_button_count}."

  discard_button_count = @browser.get_xpath_count("//a[@class='discard-new-hospital-participation']").to_i
  discard_button_count.should be_equal(expected_count), "Expected to see #{expected_count} discard buttons, got #{discard_button_count}." 
end

Given /^a (.+) event with with a form with repeating core fields$/ do |event_type|
  Given "a published form with repeating core fields for a #{event_type} event"
  And   "a basic #{event_type} event with the form's disease"
end

Given /^a (.+) event with with a form with repeating core fields and hospitalizations$/ do |event_type|
  And "a #{event_type} event with with a form with repeating core fields"
  And   "I navigate to the #{event_type} event edit page"
  hospital_name = PlaceEntity.by_name_and_participation_type(PlacesSearchForm.new({:place_type => "H"})).first.place.name
  add_hospital(@browser, {:name => hospital_name})
  And   "I save the event"
end

Then /^I should see (\d+) blank hospitalization form$/ do |count|
  unsaved_hospitalizations = @browser.get_xpath_count("//div[@class='hospital']/span[@class='ajax-actions']")
  unsaved_hospitalizations.to_i.should be_equal(count.to_i)
end

When /^I click the Hospitalization Save link$/ do
  @browser.click("//div[@class='hospital']//a[@class='save-new-hospital-participation']")
  sleep(1)
end

When /^I change the disease to (.+) the published form$/ do |match_not_match|
  click_core_tab(@browser, "Clinical")
  if match_not_match == "match"
    disease_name = @published_form.diseases.first.disease_name
  elsif match_not_match == "not match"
    disease = Disease.find(:first, :conditions => ["disease_name != ?", @published_form.diseases.first.disease_name])
    disease_name = disease.disease_name
  else
    raise "Unexpected syntax: #{match_not_match}"
  end
  @browser.select("//select[@id='#{@event.type.underscore}_disease_event_attributes_disease_id']", disease_name)
end
