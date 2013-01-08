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
Given /^the default system users$/ do
  # this is here as a place holder, and because I wanted to be
  # explicit in my scenarios describing users.
end

Then /^uid "([^\"]*)" should appear before uid "([^\"]*)"$/ do |first, second|
  response.should have_xpath("//a[text() = '#{first}']/following::a[text() = '#{second}']")
end

Then /^user status "([^\"]*)" should not appear after user status "([^\"]*)"$/ do |first, second|
  response.should_not have_xpath("//span[@id='user-status' and text()='#{second}']/following::span[@id='user-status' and text()='#{first}']")
end

Then /^user name "([^\"]*)" should not appear after user name "([^\"]*)"$/ do |first, second|
  response.should_not have_xpath("//a[text()='#{second}']/following::a[text()='#{first}']")
end

Then /^"([^\"]*)" should be selected from "([^\"]*)"$/ do |value, field|
  response.should have_xpath("//select[@id='#{field}']//option[text()='#{value}' and @selected='selected']")
end

Given /^user "([^\"]*)" is disabled$/ do |uid|
  @user = User.find_by_uid uid
  @user.disable
end



