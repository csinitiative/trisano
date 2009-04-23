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

Given(/^I am logged in as a super user$/) do
  switch_user(@browser, 'default_user')
end

Given(/^I am logged in as a lhd manager$/) do
  switch_user(@browser, 'lhd_manager')
end

When(/^I click the "(.+)" link$/) do |link|
  @browser.click("link=#{link}")
  @browser.wait_for_page_to_load($load_time)
end

When(/^I click the "(.+)" button$/) do |button|
  @browser.click("//input[contains(@value, '#{button}')]")
end

When(/^I click and confirm the "(.+)" button$/) do |button|
  @browser.click("//input[contains(@value, '#{button}')]")
  @browser.get_confirmation()
  @browser.wait_for_page_to_load($load_time)
end

Then(/^I should be presented with the error message \"(.+)\"$/) do |message|
  @browser.is_text_present(message).should be_true
end

Then(/^I should not be presented with an error message$/) do
  @browser.is_text_present("error prohibited").should be_false
end


