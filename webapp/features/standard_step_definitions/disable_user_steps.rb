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


Given(/^I am logged in as a disabled user$/) do
  log_in_as("investigator")
  User.current_user.disable
  User.current_user.save
end

When /^I see that the user is not yet disabled$/ do
  response.should have_xpath("//select[@id='user_status']//option[@value='active' and @selected='selected']")
end

Then /^I am presented with a page saying that the account is not available$/ do
  visit home_path
  response.should contain("account is not currently available")
end
