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

When(/^I navigate to the place management tool$/) do
  visit places_path
  response.should contain("Place Management")
end

When(/^I navigate to place edit$/) do
  visit edit_place_path @place_entity
  response.should contain("Edit Place")
end

Given(/^a lab named (.+) exists$/) do |place_name|

  # The lab needs to be created on an event so that it exists in the system
  # with a participation type, so it can therefore be found with a search that
  # filters on participation type.

  @event = create_basic_event("morbidity", get_random_word)
  @event.labs_attributes =  lab_attributes(
    :name => place_name,
    :test_type=> "Culture",
    :test_detail => "Did it",
    :lab_result_text => "Done"
  )
  @event.save!
  @place_entity = @event.labs[0].place_entity
end

Given(/^a diagnosing facility named (.+) exists$/) do |place_name|
  @diagnosing_facility = create_place_entity(place_name, "Hospital / ICP")
end

When(/^I search for Manzanita$/) do
  fill_in "name", :with => "Manzanita"
  click_button "Search"
end

When(/^I search for Manzanita with a participation type of Lab$/) do
  fill_in "name", :with => "Manzanita"
  select("Lab", :from => "participation_type")
  click_button "Search"
end

When(/^I search for the entity "([^\"]*)"$/) do |name|
  fill_in "name", :with => name
  click_button "Search"
end

Then( /^I should receive 2 matching records$/) do
  response.should contain("Manzanita")
  response.should contain("Hospital / ICP")
  response.should contain("Laboratory")
end

Then( /^I should receive 1 matching record for a lab$/) do
  response.should contain("Manzanita")
  response.should contain("Laboratory")
  response.should_not contain("Hospital / ICP")
end
