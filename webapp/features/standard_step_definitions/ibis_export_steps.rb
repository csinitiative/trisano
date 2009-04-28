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

Given /^a morbidity event with disease "([^\"]*)" and "([^\"]*)" by the state$/ do |disease_name, status_description|
  disease = Disease.find_by_disease_name(disease_name)
  status = ExternalCode.find_by_code_name_and_code_description('case', status_description)
  @event_to_match = create_basic_event('morbidity', 'ibis_guy')
  @event_to_match.state_case_status = status
  @event_to_match.build_disease_event(:disease_id => disease.id)
  @event_to_match.save!
end

Given /^a morbidity event with disease "([^\"]*)" and "([^\"]*)" by the LHD$/ do |disease_name, status_description|
  disease = Disease.find_by_disease_name(disease_name)
  status = ExternalCode.find_by_code_name_and_code_description('case', status_description)
  @event_to_match = create_basic_event('morbidity', 'ibis_guy')
  @event_to_match.lhd_case_status = status
  @event_to_match.build_disease_event(:disease_id => disease.id)
  @event_to_match.save!
end

Given /^a morbidity event in "([^\"]*)" county, with disease "([^\"]*)" and "([^\"]*)" by the state$/ do |county_name, disease_name, status_description|
  disease = Disease.find_by_disease_name(disease_name)
  status = ExternalCode.find_by_code_name_and_code_description('case', status_description)
  county = ExternalCode.find_by_code_name_and_code_description('county', county_name)
  @event_to_match = create_basic_event('morbidity', 'ibis_guy')
  @event_to_match.state_case_status = status
  @event_to_match.build_disease_event(:disease_id => disease.id)
  @event_to_match.build_address(:county_id => county.id)
  @event_to_match.save!
end

Given /^a morbidity event already sent to ibis, with an "([^\"]*)" LHD status$/ do |status_description|
  disease = Disease.find_by_disease_name('African Tick Bite Fever')
  status = ExternalCode.find_by_code_name_and_code_description('case', status_description)
  @event_to_match = create_basic_event('morbidity', 'ibis_guy')
  @event_to_match.state_case_status = status
  @event_to_match.build_disease_event(:disease_id => disease.id)
  @event_to_match.sent_to_ibis = true
  @event_to_match.save!
end

When /^I navigate to the ibis export form$/ do
  visit ibis_events_path
  response.should contain("IBIS Export")
end

When /^I set the "([^\"]*)" to "([^\"]*)"$/ do |field, date_expression|
  date = Date.send(date_expression)
  fill_in(field, :with => date.strftime('%m/%d/%Y'))
end

Then /^it should have the code for "([^\"]*)" county$/ do |county_name|
  county = ExternalCode.find_by_code_name_and_code_description('county', county_name)
  response.should have_xpath "//county[text() = '#{@event_to_match.address.try(:county).try(:the_code)}']"
end

Then /^I should receive the morbidity event as xml$/ do
  response.should have_xpath("//recordid[text() = '#{@event_to_match.record_number}']")
end

Then /^I should receive the deleted morbidity event as xml$/ do
  response.should have_xpath "//recordid[text()='#{@event_to_match.record_number}']/../updateflag[text()='1']"
end

Then /^I should see "([^\"]*)" in the Status node$/ do |status_code|
  response.should have_xpath "//recordid[text()='#{@event_to_match.record_number}']/../status[text()='#{status_code}']"
end
