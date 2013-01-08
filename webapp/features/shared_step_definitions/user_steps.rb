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
Given /^I have the following email addresses:$/ do |table|
  table.raw.map(&:first).each do |email|
    User.current_user.email_addresses.create(:email_address => email)
  end
end

Given /^a user with uid "([^\"]*)"$/ do |uid|
  @user = User.find_by_uid(uid)
  unless @user
    @user = Factory.create(:user, :uid => uid, :user_name => uid)
  end
end

Given /^"([^\"]*)" is an investigator in "([^\"]*)"$/ do |uid, jurisdiction_name|
  Given %{a user with uid "#{uid}"}
  jurisdiction = Place.jurisdictions.select { |j| j.short_name == jurisdiction_name }.first
  role = Role.find_by_role_name('Investigator')
  @user.role_memberships.create(:jurisdiction_id => jurisdiction.entity_id, :role => role)
end

