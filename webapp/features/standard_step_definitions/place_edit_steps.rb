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

When(/^I change the place name to (.+)$/) do |new_name|
  fill_in "name", :with => new_name
end

When(/^I enter a canonical address$/) do
  # Need to XPath this up
  @street_number = "11"
  @street_name = "Happy St."
  @unit_number = "12"
  @city = "SLC"
  @state = "Utah"
  @county = "Cache"
  @zip = "97232"

  fill_in "place_entity_canonical_address_attributes_street_number", :with => @street_number
  fill_in "place_entity_canonical_address_attributes_street_name", :with => @street_name
  fill_in "place_entity_canonical_address_attributes_unit_number", :with => @unit_number
  fill_in "place_entity_canonical_address_attributes_city", :with => @city
  select @state, :from => "place_entity_canonical_address_attributes_state_id"
  select @county, :from => "place_entity_canonical_address_attributes_county_id"
  fill_in "place_entity_canonical_address_attributes_postal_code", :with => @zip
end

When(/^I submit the place update form$/) do
  click_button "Update"
end

When(/^I enter invalid place data$/) do
  fill_in "name", :with => ""
end

Then(/^the place name change to (.+) should be reflected on the show page$/) do |new_name|
  response.should contain(new_name)
  response.should contain("Place Detail")
end

Then(/^the canonical address should be displayed on the show page$/) do
  response.should contain(@street_number)
  response.should contain(@street_name)
  response.should contain(@unit_number)
  response.should contain(@city)
  response.should contain(@state)
  response.should contain(@county)
  response.should contain(@zip)

  # Also ensure that this address is indeed canonical
  @place_entity.canonical_address.should_not be_nil
  @place_entity.canonical_address.street_number.should == @street_number
  @place_entity.canonical_address.street_name.should == @street_name
  @place_entity.canonical_address.unit_number.should == @unit_number
  @place_entity.canonical_address.city.should == @city
  @place_entity.canonical_address.state.code_description.should == @state
  @place_entity.canonical_address.county.code_description.should == @county
  @place_entity.canonical_address.postal_code.should == @zip
end

Then(/^the place edit form should be redisplayed with an error message$/) do
  response.should have_xpath("//div[contains(@id, 'errorExplanation')]")
end

Then /^the phone number should be displayed on the show page$/ do
  response.should contain("111")
  response.should contain("222-3333")
  response.should contain("Ext. 4")
end

