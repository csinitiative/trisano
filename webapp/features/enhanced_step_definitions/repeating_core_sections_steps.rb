# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

Given /^a published form with repeating core fields for a (.+) event$/ do |event_type|
  disease_name = SecureRandom.hex(16)
  @form = create_form(event_type, 'Already created', 'something_published', disease_name)
  Given "that form has core field configs configured for all repeater core fields"
  @published_form = @form.publish
  @published_form.should_not be_nil, "Unable to publish form. See feature logs."
  sleep 1
end

Given /^a basic (.+) event with the form's disease$/ do |event_type|
  @event = create_basic_event(event_type, get_unique_name(1), @form.diseases.first.disease_name.strip,  Place.unassigned_jurisdiction.short_name)
end

When /^I navigate to the new morbidity event page and start a event with the form's disease$/ do
  @browser.open "/trisano/cmrs/new"
  add_demographic_info(@browser, { :last_name => get_unique_name })
  @browser.type('morbidity_event_first_reported_PH_date', Date.today)
  @browser.select('morbidity_event_disease_event_attributes_disease_id', @form.diseases.first.disease_name)
end


Given /^a (.+) event with with a form with repeating core fields$/ do |event_type|
  Given "a published form with repeating core fields for a #{event_type} event"
  And   "a basic #{event_type} event with the form's disease"
end

When /^I change the disease to (.+) the published form$/ do |match_not_match|
  click_core_tab(@browser, "Clinical")
  if match_not_match == "match"
    disease_name = @published_form.diseases.first.disease_name
  elsif match_not_match == "not match"
    disease = Disease.find(:first, :conditions => ["disease_name != ?", @published_form.diseases.first.disease_name])
    disease_name = disease.disease_name
  else
    raise "Unexpected syntax: #{match_not_match}"
  end
  @browser.select("//select[@id='#{@event.type.underscore}_disease_event_attributes_disease_id']", disease_name)
end

When /^I print the event$/ do
  When "I click the \"Print\" link and don't wait"
  @browser.check("//input[@id='print_all']")
  When "I click the \"Print\" button"
end
