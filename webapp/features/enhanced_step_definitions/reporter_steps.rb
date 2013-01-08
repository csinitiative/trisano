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
Given /^the event has a reporter$/ do
  @reporter_entity = Factory.create(:person_entity)
  @reporter = @reporter_entity.person
  @event.build_reporter(:secondary_entity => @reporter_entity)
  @event.save!
end

When /^I add an existing reporter$/ do
  click_core_tab(@browser, "Reporting")
  @browser.type('reporter_search_name', @reporter_entity.person.last_name)
  @browser.click('reporter_search')
  wait_for_element_present("//div[@id='reporter_search_results']/table")
  @browser.click "//div[@id='reporter_search_results']//a[@id='add_reporter_entity_#{@reporter_entity.id}']"
  wait_for_element_present("//div[@id='existing-reporter']")
end

Then /^I should see the reporter on the page$/ do
  script = "selenium.browserbot.getCurrentWindow().$j('#reporters').text();"
  wait_for_element_present("//div[@id='reporters']")
  @browser.get_eval(script).should =~ /#{@reporter.last_comma_first}/
end

Then /^I should not see the reporter on the page$/ do
  script = "selenium.browserbot.getCurrentWindow().$j('#reporters').text();"
  wait_for_element_present("//div[@id='reporters']")
  @browser.get_eval(script).should_not =~ /#{@reporter.last_comma_first}/
end

Then /^I should see the reporter form$/ do
  event_type = @event.class.to_s.underscore
    ["#{event_type}_reporter_attributes_person_entity_attributes_person_attributes_last_name",
     "#{event_type}_reporter_attributes_person_entity_attributes_person_attributes_first_name",
     "#{event_type}_reporter_attributes_person_entity_attributes_telephones_attributes_0_area_code",
     "#{event_type}_reporter_attributes_person_entity_attributes_telephones_attributes_0_phone_number",
     "#{event_type}_reporter_attributes_person_entity_attributes_telephones_attributes_0_extension"].each do |id|
    @browser.get_xpath_count("//div[@id='reporters']//input[@id='#{id}']").to_i.should == 1
  end
end

When /^I remove the reporter from the event$/ do
  @browser.click "//input[@id='#{@event.class.to_s.underscore}_reporter_attributes__destroy']"
  When %{I save and continue}
end
