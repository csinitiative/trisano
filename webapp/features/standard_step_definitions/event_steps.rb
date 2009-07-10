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

Given /^a ([^\"]*) event in jurisdiction "([^\"]*)" assigned to "([^\"]*)" queue$/ do |type, jurisdiction, queue_name|
  @event = create_basic_event(type, get_random_word, "African Tick Bite Fever", jurisdiction)
  @event.event_queue = EventQueue.find_by_queue_name(queue_name)
  # TODO: investigator and disease can be removed once webrat multi select is fixed.
  @event.investigator_id = User.current_user
  @event.save!
end

Given /^a simple (.+) event in jurisdiction (.+) for last name (.+)$/ do |event_type, jurisdiction, last_name|
  @m = create_basic_event(event_type, last_name, nil, jurisdiction)
end

Given /^a routed (.+) event for last name (.+)$/ do |event_type, last_name|
  @m = create_basic_event(event_type, last_name, nil, 'Unassigned')
  @m.assign_to_lhd(Place.jurisdiction_by_name("Bear River Health Department"), [], "")
  @m.save!
end

When /^I visit the events index page$/ do
  visit cmrs_path({})
end

When(/^I navigate to the event edit page$/) do
  visit edit_cmr_path(@event)
end

When(/^I navigate to the event show page$/) do
  visit cmr_path(@event)
end

When(/^I navigate to the new event page$/) do
  visit new_cmr_path
end
