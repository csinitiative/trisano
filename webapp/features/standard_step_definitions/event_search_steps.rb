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

#
# Givens
#
Given /^another morbidity event$/ do
  @other_event = create_basic_event('morbidity', 'Patient')
end

Given /^a morbidity event with the record number (\d{15})$/ do |record_number|
  @event_to_match = create_basic_event('morbidity', 'Record Number')
  @event_to_match.record_number = record_number
  @event_to_match.save!
end

Given /^a morbidity event with a pregnant patient$/ do
  @event_to_match = create_basic_event('morbidity', 'Pregnant')
  @event_to_match.interested_party.build_risk_factor(:pregnant_id => ExternalCode.yes_id)
  @event_to_match.save!
end

Given /^a morbidity event with a state status "([^\"]*)"$/ do |status|
  @event_to_match = create_basic_event('morbidity', 'state status')
  @event_to_match.state_case_status = ExternalCode.send(status.downcase.underscore)
  @event_to_match.save!
end

Given /^a morbidity event with a LHD status "([^\"]*)"$/ do |status|
  @event_to_match = create_basic_event('morbidity', 'lhd status')
  @event_to_match.lhd_case_status = ExternalCode.send(status.downcase.underscore)
  @event_to_match.save!
end

Given /^a morbidity event that has been sent to the CDC$/ do
  @event_to_match = create_basic_event('morbidity', 'sent_to_cdc')
  @event_to_match.sent_to_cdc = true
  @event_to_match.save!
end

Given /^a morbidity event first reported on "([^\"]*)"$/ do |date|
  @event_to_match = create_basic_event('morbidity', 'first_reported')
  @event_to_match.first_reported_PH_date = Date.parse(date)
  @event_to_match.save!
end

#
# Whens
#
When /^I navigate to the event search form$/ do
  visit search_cmrs_path
  response.should contain("Event Search")
end

When /^I enter (\d{15}) into the record number search field$/ do |record_number|
  fill_in "record_number", :with => record_number
end

When /^I submit the search$/ do
  click_button 'submit_query'
end

#
# Thens
#
Then /^I should receive 1 matching record$/ do
  response.should have_xpath("//a[@id='show-cmr-link-#{@event_to_match.id}']")
end

