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

Given /^I am logged in as a super user$/ do
  log_in_as("default_user")
end

Given /^a (.+) event for last name (.+) with disease (.+) in jurisdiction (.+)$/ do |event_type, last_name, disease, jurisdiction|
  @m = create_basic_event(event_type, last_name, disease, jurisdiction)
end

Given /^a published disease form called (.+) for (.+) events with (.+)$/ do |form_name, event_type, disease|
  create_published_form(event_type, form_name, form_name, disease)
end

Given /^there is a contact named (.+)$/ do |last_name|
  @child = add_child_to_event(@m, last_name)
end

When /^I visit contacts show page$/ do
  visit contact_event_path(@child)
end  

Then /^I should see a link to promote event to a CMR$/ do
  response.should have_selector("a#event-type[href='#{event_type_contact_event_path(@m.contact_child_events.first)}']")
end

When /^I promote Jones to a morbidity event$/ do
  visit contact_event_path(@child)
  click_link "Promote to CMR"
end

Then /^I should be on the show morbidity event for Jones page$/ do
  path = cmr_path(@child)
  current_url.should =~ /#{path}/
end

Then /^the morbidity event should have disease forms for MA1 and CA1$/ do
  response.should have_selector("#investigation_form_list li", :content => "MA1")
  response.should have_selector("#investigation_form_list li", :content => "CA1")
end

Then /^the new morbidity event should show Smith as the parent$/ do
  response.should have_xpath("//div[@id='contacts_tab']//div[@id='morbidity_parent_event']//*[contains(text(), 'Smith')]")
end

Then /^the parent CMR should show the child as an elevated contact$/ do
  visit cmr_path(@m)
  response.should have_xpath("//div[@id='contacts_tab']//div[@id='morbidity_child_events']//*[contains(text(), 'Jones')]")
end
