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

When /^I enter a second hospitalization:$/ do |table|
  table.hashes.each do |hospital_attributes|
    add_hospital(@browser, hospital_attributes, 2)
  end
end

When /^I enter a second hospitalization with an invalid admission date and form data$/ do
  add_hospital(@browser, {:name => "Valley View Medical Center", :admission_date => 1.year.from_now.to_date.to_formatted_s}, 2)
  
  form_field_label = "morbidity_event[hospitalization_facilities][secondary_entity_id] before?"
  field_id = @browser.get_attribute "//div[@id='hospitalization_facilities']/div[@class='hospital'][2]//label[text()='#{form_field_label}']@for"
  #field_id = @browser.get_attribute "//div[@id='telephones']/div[@class='phone'][2]//label[text()='#{form_field_label}']@for"
  @hospitalization_form_data = SecureRandom.hex(16)
  @browser.type field_id, @hospitalization_form_data
end

Then /^I should see the form data entered for the second hospitalization$/ do
  Then "I should see \"#{@hospitalization_form_data}\""
end


When /^I enter the following hospitalizations:$/ do |table|
  i = 0
  table.hashes.each do |hospital_attributes|
    i += 1
    add_hospital(@browser, hospital_attributes, i)
  end
end

Then /^I should see all of the repeater core field config questions for (.+) hospitalization$/ do |expected_count|
  @core_fields ||= CoreField.all(:conditions => ["event_type = ? AND fb_accessible = ? AND disease_specific = ? AND repeater = TRUE AND key LIKE '%hospitalization_facilities%'", @form.event_type, true, false])
  @core_fields.count.should_not be_equal(0), "Didn't find any hospitalization core fields."

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

Given /^a (.+) event with with a form with repeating core fields and hospitalizations$/ do |event_type|
  And "a #{event_type} event with with a form with repeating core fields"
  And   "I navigate to the #{event_type} event edit page"
  hospital_name = PlaceEntity.by_name_and_participation_type(PlacesSearchForm.new({:place_type => "H"})).first.place.name
  add_hospital(@browser, {:name => hospital_name})
  And   "I save and exit"
end

Then /^I should see (\d+) blank hospitalization form$/ do |count|
  unsaved_hospitalizations = @browser.get_xpath_count("//div[@class='hospital']/span[@class='ajax-actions']")
  unsaved_hospitalizations.to_i.should be_equal(count.to_i)
end

When /^I click the Hospitalization Save link$/ do
  # There should only ever be one of these on the page
  @browser.click("//a[@class='save-new-hospital-participation']")
  sleep(1)
end

When /^I discard the unsaved hospitalization$/ do
  # There should only ever be one of these on the page
  @browser.click("//a[@class='discard-new-hospital-participation']")
end
