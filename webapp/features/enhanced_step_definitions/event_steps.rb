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
Given /^a simple (.+) event in jurisdiction (.+) for last name (.+)$/ do |event_type, jurisdiction, last_name|
  @m = create_basic_event(event_type, last_name, nil, jurisdiction)
end

When(/^I navigate to the event edit page$/) do
  @browser.click "link=EVENTS"
  @browser.wait_for_page_to_load $load_time
  @browser.click "link=Edit"
  @browser.wait_for_page_to_load $load_time
end

When(/^I navigate to the event show page$/) do
  @browser.open "/trisano/cmrs/#{(@m || @event).id}"
  @browser.wait_for_page_to_load
end

