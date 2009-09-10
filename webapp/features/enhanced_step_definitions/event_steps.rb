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

When(/^I navigate to the new event page and start a simple event$/) do
  @browser.open "/trisano/cmrs/new"
  add_demographic_info(@browser, { :last_name => get_unique_name })
end

When(/^I navigate to the event edit page$/) do
  @browser.click "link=EVENTS"
  @browser.wait_for_page_to_load $load_time
  @browser.click "link=Edit"
  @browser.wait_for_page_to_load $load_time
end

When(/^I am on the event edit page$/) do
  @browser.open "/trisano/cmrs/#{(@event).id}/edit"
  @browser.wait_for_page_to_load
end

# Consider refactoring the name of this one -- it really isn't navigating, it's
# more like a "when I am on"
When(/^I navigate to the event show page$/) do
  @browser.open "/trisano/cmrs/#{(@event).id}"
  @browser.wait_for_page_to_load
end

When /^I am on the events index page$/ do
  @browser.open "/trisano/cmrs"
  @browser.wait_for_page_to_load
end


When(/^I am on the contact event edit page$/) do
  @browser.open "/trisano/contact_events/#{(@contact_event).id}/edit"
  @browser.wait_for_page_to_load
end

When(/^I am on the place event edit page$/) do
  @browser.open "/trisano/place_events/#{(@place_event).id}/edit"
  @browser.wait_for_page_to_load
end

When(/^I save the event$/) do
  save_cmr(@browser).should be_true

  # Try to establish a reference to the event if there isn't already one. This will enable
  # steps like 'navigate to event show page' to work
  if @event.nil?
    begin
      location = @browser.get_location
      event_id_start = location.index("cmr") + 5
      event_id_end = location.index("?")
      event_id = location[event_id_start...event_id_end]
      @event = Event.find event_id.to_i
    rescue
      # Well, we tried. We'll end up in here if we used this step on a non-morb event.
    end

  end
end

Then /^events list should show (\d+) events$/ do |expected_count|
  @browser.get_xpath_count("//div[@class='patientname']").should == expected_count
end

After('@clean_events') do
  Address.all.each(&:delete)
  Event.all.each(&:delete)
end
