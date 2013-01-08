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

When(/^I add an existing diagnosing facility$/) do
  click_core_tab(@browser, "Clinical")
  @browser.type("diagnostic_facility_search_name", "b")
  @browser.click "diagnostic_facility_search"
  @browser.wait_for_ajax
  @browser.click "//div[@id='diagnostic_facility_search_results']//td[text()='Beaver Valley Hospital']/../td/a"
  @browser.wait_for_ajax
end

When(/^I click remove for that diagnosing facility$/) do
  # This may need to be more specific at some point
  @browser.click("link=Remove")
  wait_for_element_not_present("//div[@id='live_search_diagnostics']/div[@class='existing_diagnostic']")
end

Then(/^I should not see the diagnosing facility$/) do
  script = "selenium.browserbot.getCurrentWindow().$j('#diagnostic_facilities span').text();"
  text = @browser.get_eval(script)
  text.should =~ /Beaver Valley Hospital/m
end

When(/^I add a new diagnosing facility$/) do
  @facility_name_1 = get_unique_name(2)
  add_diagnostic_facility(@browser, { :name => @facility_name_1, :place_type => "S" })
end

Then(/^I should see all added diagnosing facilities$/) do
  @browser.is_text_present('Beaver Valley Hospital').should be_true
  @browser.is_text_present('Hospital / ICP').should be_true
  @browser.is_text_present(@facility_name_1).should be_true
  @browser.is_text_present("School").should be_true
end

When /^I remove all of the diagnostic facilities$/ do
  script = %{selenium.browserbot.getCurrentWindow().$j('#diagnostic_facilities input[type="checkbox"]').click()}
  @browser.get_eval(script)
  When "I save and exit"
end

Then(/^I should not see the removed diagnostic facility$/) do
  @browser.is_text_present(@facility_name_1).should be_false
end
