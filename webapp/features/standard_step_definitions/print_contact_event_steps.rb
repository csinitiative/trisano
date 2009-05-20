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
require 'factory_girl'

Given /^an existing contact event$/ do
  @event = Factory.create(:contact_event)
  @event.labs.first.save!
  @event.labs.reload
  p @event.labs
end

When /^I print the contact event$/ do
  visit contact_event_path(@event, :format => :print)
end

Then /^I should see the demographics data$/ do
  response.should be_success
  response.should contain(@event.interested_party.person_entity.person.last_name)
  response.should contain(@event.address.street_name)
  response.should contain(@event.interested_party.person_entity.email_addresses.first.email_address)
end

Then /^I should see clinical data$/ do
  response.should be_success
  response.should contain(@event.disease_event.disease.disease_name)
end

Then /^I should see lab data$/ do
  response.should be_success
  @event.labs.first.should_not be_a_new_record
  response.should contain(@event.labs.first.lab_results.first.test_type)
  response.should contain(@event.labs.first.lab_results.first.lab_result_text)
end

Then /^I should see epi data$/ do
  pending
end

Then /^I should see admin data$/ do
  pending
end

Then /^I should see answer data$/ do
  pending
end
