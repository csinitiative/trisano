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

Given /^I have an existing contact event$/ do
  @event = Factory.create(:contact_event)

  # we build (rather then create) some form bits because they have special save mechanisms.
  @form =  Factory.build(:form)
  @form.save_and_initialize_form_elements
  @form.investigator_view_elements_container.add_child Factory.create(:view_element, :tree_id => @form.form_base_element.tree_id)
  @form.save!
  @published_form = @form.publish

  @event.add_forms(@published_form.id)
  @event.labs << Factory.create(:lab)
  @event.save!
end

When /^I print the contact event$/ do
  visit contact_event_path(@event, :format => :print, :print_options => ['All'])
end

When /^I visit the cmrs index page$/ do
  visit cmrs_path
end

When /^I visit the contacts show page$/ do
  visit contact_event_path(@event)
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
  response.should contain(@event.labs.first.lab_results.first.test_type.common_name)
  response.should contain(@event.labs.first.lab_results.first.lab_result_text)
end

Then /^I should see epi data$/ do
  response.should be_success
  response.should contain(@event.interested_party.risk_factor.occupation)
end

Then /^I should see admin data$/ do
  response.should be_success
  @event.record_number.should_not be_nil
  response.should contain(@event.record_number)
end

Then /^I should see answer data$/ do
  response.should be_success
  response.should contain(@event.investigation_form_references.first.form.name)
end
