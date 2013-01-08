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

Given /^a (.+) event with with a form with repeating core fields and hospitalizations$/ do |event_type|
  And "a #{event_type} event with with a form with repeating core fields"
  And   "I navigate to the #{event_type} event edit page"
  hospital_name = PlaceEntity.by_name_and_participation_type(PlacesSearchForm.new({:place_type => "H"})).first.place.name
  add_hospital(@browser, {:name => hospital_name})
  And   "I save and exit"
end
