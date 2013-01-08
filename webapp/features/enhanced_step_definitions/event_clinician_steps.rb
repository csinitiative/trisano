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

Given(/^there is a clinician$/) do
  @clinician = Factory.create(:person_entity, :person => Factory.create(:clinician))
end

Given(/^a deleted clinician exists with a name similar to another clinician$/) do
  @common_name = get_unique_name(1)
  @clinician = Factory.create(:person_entity, :person => Factory.create(:clinician, :last_name => @common_name))
  @deleted_clinician = Factory.create(:person_entity, :person => Factory.create(:clinician, :last_name => "#{@common_name}-Deleted"), :deleted_at => Time.now)
end

When(/^I add an existing clinician$/) do
  click_core_tab(@browser, "Clinical")
  @browser.type('clinician_search_name', @clinician.person.last_name)
  @browser.click('clinician_search')
  wait_for_element_present("//div[@id='clinician_search_results']/table")
  @browser.click "//div[@id='clinician_search_results']//a[@id='add_clinician_entity_#{@clinician.id}']"
  wait_for_element_present("//div[@class='existing_clinician']")
end

When(/^I add a new clinician$/) do
  @new_clinician_name = get_unique_name(2)
  add_clinician(@browser, { :last_name => @new_clinician_name })
end

When(/^I click remove for that clinician$/) do
  @browser.click("link=Remove")
  wait_for_element_not_present("//div[@id='live_search_clinicians']/div[@class='existing_clinician']")
end

When(/^I search for the deleted clinician$/) do
  click_core_tab(@browser, "Clinical")
  @browser.type_keys("clinicians_search", @common_name)
  wait_for_element_present("//div[@id='clinicians_search_choices']/ul")
end

When(/^I check a clinician to remove$/) do
  remove_clinician(@browser)
end

Then(/^I should not see the clinician$/) do
  @browser.is_element_present("//div[@id='live_search_clinicians']/div[@class='existing_clinician']").should be_false
end

Then(/^I should not see the removed clinician$/) do
  @browser.is_text_present(@new_clinician_name).should be_false
end

Then(/^I should see all added clinicians$/) do
  @browser.is_text_present(@clinician.person.last_name).should be_true
  @browser.is_text_present(@new_clinician_name).should be_true
end

Then(/^I should not see the deleted clinician$/) do
  @browser.is_element_present("//select[@id='_clinician_id']/option[text()='#{@deleted_clinician.person.last_comma_first_middle}']").should be_false
end




