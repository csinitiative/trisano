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


When(/^I add an existing place exposure$/) do
  click_core_tab(@browser, EPI)
  @browser.type('place_search_name', @place_entity.place.name)
  @browser.click('place_search')
  wait_for_element_present("//div[@id='place_search_results']/table")
  @browser.click "//div[@id='place_search_results']//a[@id='add_place_entity_#{@place_entity.id}']"
  wait_for_element_present("//div[@id='place_child_events']")
end

When(/^I click remove for the unsaved place exposure$/) do
  @browser.click("//div[@id='place_child_events']//li[@class='existing_place']//a[text()='Remove']")
end

Then(/^I should not see the place exposure$/) do
  @browser.is_element_present("//div[@id='place_child_events']//li[@class='existing_place']").should be_false
end

When(/^I add a new place exposure$/) do
  @new_place_name = get_unique_name(2)
  add_place(@browser, { :name => @new_place_name, :place_type => "S" })
end

Then(/^I should see all added place exposures$/) do
  @browser.is_text_present(@place_entity.place.name).should be_true
  @browser.is_text_present('Food Establishment').should be_true
  @browser.is_text_present(@new_place_name).should be_true
  @browser.is_text_present("School").should be_true
end

When(/^I check a place exposure to remove$/) do
  remove_place_exposure(@browser)
end

Then(/^I should see the removed place exposure as deleted$/) do
  #  script = <<-SCRIPT
  #  selenium.browserbot.getCurrentWindow().$("//td[contains(text(), '#{@place_entity.place.name}')]")[0].hasClassName('struck-through')
  #SCRIPT
  #  @browser.get_eval(script)

  # Could not get the above to work. This more generic test will do for now.
  @browser.is_element_present("//td[@class='struck-through']").should be_true
end

When(/^I add two new place exposures$/) do
  @first_new_place_name = get_unique_name(2)
  add_place(@browser, { :name => @first_new_place_name, :place_type => "S" })

  @second_new_place_name = get_unique_name(2)
  add_place(@browser, { :name => @second_new_place_name, :place_type => "S" })
end

Then(/^I should see both new place exposures$/) do
  @browser.is_text_present(@first_new_place_name).should be_true
  @browser.is_text_present(@second_new_place_name).should be_true
end

When(/^I navigate to the place event$/) do
  @browser.click "link=Edit Place"
  @browser.wait_for_page_to_load
end

When(/^I edit the place event$/) do
  @browser.type "//input[contains(@id, '_street_number')]", "555"
  @browser.type "//input[contains(@id, '_street_name')]", "Main St."
  @browser.type "//input[contains(@id, '_unit_number')]", "D"
  @browser.type "//input[contains(@id, '_city')]", "Springfield"
  @browser.select "//select[contains(@id, '_state_id')]", "label=Utah"
  @browser.select "//select[contains(@id, '_county_id')]", "label=Summit"
  @browser.type "//input[contains(@id, '_postal_code')]", "11111"
end

When(/^I save the place event$/) do
  save_place_event(@browser).should be_true
end

Then(/^I should see the edited place event$/) do
  @browser.is_text_present("555").should be_true
  @browser.is_text_present("Main St.").should be_true
  @browser.is_text_present("D").should be_true
  @browser.is_text_present("Springfield").should be_true
  @browser.is_text_present("Utah").should be_true
  @browser.is_text_present("Summit").should be_true
  @browser.is_text_present("11111").should be_true
end

