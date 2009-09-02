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

#
# Log in helpers
#

Given(/^I am logged in as a super user$/) do
  log_in_as("default_user")
end

Given(/^I am logged in as a manager$/) do
  log_in_as("lhd_manager")
end

Given(/^I am logged in as an investigator$/) do
  log_in_as("investigator")
end

Given(/^I am logged in as a data entry tech/) do
  log_in_as("data_entry_tech")
end

#
# Basic moving around helpers
#

When(/^I navigate to the person management tool$/) do
  visit people_path
  response.should contain("People")
end

When(/^I click the "(.+)" link$/) do |link|
  click_link link
end

When(/^I click the "(.+)" button$/) do |button|
  click_button button
end

#
# Error message helpers
#

Then(/^I should be presented with the error message \"(.+)\"$/) do |message|
  response.should contain(message)
end

#
# HTTP helpers
#

Then /^I should get a (.+) response$/ do |code|
  response.code.should == code.to_s
end

Then /^I follow "(.*)" expecting a failure$/ do |link|
  lambda{ click_link(link) }.should raise_error(Webrat::PageLoadError)
end

#
# Verification Helpers
#

Then /^I should see a link to "([^\"]*)"$/ do |link_text|
  response.should have_xpath("//a[text()='#{link_text}']")
end

Then /^I should not see a link to "([^\"]*)"$/ do |link_text|
  response.should_not have_xpath("//a[text()='#{link_text}']")
end

# Other stuff
#

When(/^I search for the place entity "([^\"]*)"$/) do |name|
  fill_in "name", :with => name
  click_button "Search"
end

When(/^I search for the person entity "([^\"]*)"$/) do |name|
  if name.split(" ").size == 2
    fill_in "first_name", :with => name.split(" ")[0]
    fill_in "last_name", :with => name.split(" ")[1]
  else
    fill_in "last_name", :with => name
  end

  click_button "Search"
end
