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

Given /^I am logged in as a "([^\"]*)" in "([^\"]*)"$/ do |role_name, jurisdiction_name|
  name = get_unique_name(2)
  jurisdiction = Place.jurisdiction_by_name(jurisdiction_name)
  role = Role.find_by_role_name(role_name)
  @user = User.create(:uid => name, :user_name => name)
  @user.update_attributes({:role_membership_attributes => [{
                              :jurisdiction_id => jurisdiction.entity.id,
                              :role_id => role.id }] })
  @browser.refresh
  @browser.wait_for_page_to_load($load_time)
  switch_user(@browser, @user.best_name)
end

Given /^that event has been sent to the state$/ do
  @event.workflow_state = 'approved_by_lhd'
  @event.save!
end

When /^I click the "Reopen" radio$/ do
  @browser.click("//input[@id='reopen_reopen']")
end

When /^the event status is "([^\"]*)"$/ do |state_description|
  @browser.get_html_source.should =~ /#{state_description}/
end

Then /^the event state is "([^\"]*)"$/ do |state_description|
  @browser.get_html_source.should =~ /#{state_description}/
end

