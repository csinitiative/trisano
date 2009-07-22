# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

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
  @diagnosing_facility = create_place(place_name, "H")
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
