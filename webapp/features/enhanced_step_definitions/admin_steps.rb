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

When(/^I navigate to the admin dashboard page$/) do
  @browser.open "/trisano/admin"
  @browser.wait_for_page_to_load
end

When(/^I navigate to the place management tool$/) do
   navigate_to_place_admin(@browser)
end

When /^I open the place management tool$/ do
  @browser.open "/trisano/places"
end

When(/^I search for a place named (.+)/) do |name|
   @browser.type("name", name)
   @browser.click("submit_place_search")
   @browser.wait_for_page_to_load($load_time)
end

