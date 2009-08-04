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

When(/^I add an existing reporting agency$/) do
  click_core_tab(@browser, "Reporting")
  @browser.type_keys("reporting_agency_search", @place_entity.place.name)
  wait_for_element_present("//div[@id='reporting_agency_search_choices']/ul")
  @browser.click "//div[@id='reporting_agency_search_choices']/ul/li/div[@class='place_name'][text()='#{@place_entity.place.name}']"
  sleep 1
end

When(/^I click remove for that reporting agency$/) do
  # This may need to be more specific at some point
  @browser.click("link=Remove")
  wait_for_element_not_present("//div[@id='reporting_agency']/div")
end

Then(/^I should not see the reporting agency$/) do
  @browser.is_element_present("//div[@id='reporting_agency']/div").should be_false
end

Then(/^I should see the added reporting agency$/) do
  @browser.is_text_present(@place_entity.place.name).should be_true
  @browser.is_text_present('Public').should be_true
end

