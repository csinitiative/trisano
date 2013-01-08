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
When /^I go to edit the user$/ do
  @browser.click "link=ADMIN"
  @browser.wait_for_page_to_load
  @browser.click "link=Manage Users"
  @browser.wait_for_page_to_load
  @browser.click "link=#{@user.uid}"
  @browser.wait_for_page_to_load
  @browser.click "link=Edit"
  @browser.wait_for_page_to_load
end

When /^I remove the role$/ do
  @browser.click "link=Remove"
end

Given /^the user has the role "([^\"]*)" in the "([^\"]*)"$/ do |role, jurisdiction|
  jurisdiction_id = Place.jurisdiction_by_name(jurisdiction).id
  role_id = Role.find_by_role_name(role).id
  RoleMembership.create :user_id => @user.id, :jurisdiction_id => jurisdiction_id, :role_id => role_id
end

After('@clean_user') do
  @user.destroy if @user
end
