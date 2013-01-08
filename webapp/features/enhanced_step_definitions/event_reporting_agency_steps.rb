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

When(/^I add an existing reporting agency$/) do
  click_core_tab(@browser, "Reporting")
  @browser.type_keys("reporting_agency_search_name", @place_entity.place.name)
  @browser.click("reporting_agency_search")
  @browser.wait_for_ajax
  @browser.click "//div[@id='reporting_agency_search_results']//td[text()='#{@place_entity.place.name}']/../td/a"
  @browser.wait_for_ajax
  script = "selenium.browserbot.getCurrentWindow().$j('#reporting_agency span').text();"
  @browser.get_eval(script).should =~ /#{@place_entity.place.name}/
end

When(/^I click remove for that reporting agency$/) do
  @browser.click("//div[@id='reporting_agency']//a[text()='Remove']")
  @browser.wait_for_ajax
end

Then(/^I should not see the reporting agency$/) do
  script = "selenium.browserbot.getCurrentWindow().$j('#reporting_agency span').text();"
  @browser.get_eval(script).should_not =~ /#{@place_entity.place.name}/
end

Then(/^I should see the added reporting agency$/) do
  @browser.is_text_present(@place_entity.place.name).should be_true
  @browser.is_text_present('Public').should be_true
end

