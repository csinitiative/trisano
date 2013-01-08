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

When(/^I navigate to the place management tool$/) do
  visit places_path
  response.should contain("Place management")
end

Given(/^a lab named (.+) exists$/) do |place_name|

  # The lab needs to be created on an event so that it exists in the system
  # with a participation type, so it can therefore be found with a search that
  # filters on participation type.

  @event = create_basic_event("morbidity", get_random_word)
  @event.labs_attributes =  lab_attributes(
    :name => place_name,
    :test_type_id => 1
  )
  @event.save!
  @place_entity = @event.labs[0].place_entity
end

Given /^the place entity has a canonical address of:$/i do |addresses|
  address_attr = addresses.hashes.first.with_indifferent_access
  if state = address_attr.delete(:state)
    state_code = ExternalCode.find_by_the_code(state)
    address_attr[:state_id] = state_code.id
  end
  @place_entity.addresses.create(address_attr).should be_true
end

Given(/^a diagnosing facility named (.+) exists$/) do |place_name|
  @diagnosing_facility = create_place_entity!(place_name, "H")
end

When(/^I search for Manzanita$/) do
  fill_in "name", :with => "Manzanita"
  click_button "Search"
end

When(/^I search for Manzanita with a place type of Laboratory$/) do
  fill_in "name", :with => "Manzanita"
  select("Laboratory", :from => "place_type")
  click_button "Search"
end

Then( /^I should receive 2 matching records$/) do
  doc = Nokogiri::HTML::parse(response_body)
  result = doc.css("table#entity_search_results tr td").text
  result.should contain("Manzanita")
  result.should contain("Hospital / ICP")
  result.should contain("Laboratory")
end

Then( /^I should receive 1 matching record for a lab$/) do
  doc = Nokogiri::HTML::parse(response_body)
  results = doc.css("table#entity_search_results tr td").text
  results.should contain("Manzanita")
  results.should contain("Laboratory")
  results.should_not contain("Hospital / ICP")
end
