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

Then /^I should see a link to promote event to a AE$/ do
  response.should have_selector("a#event-type[href='#{event_type_contact_event_path(@event.contact_child_events.first)}?type=assessment_event']")
end

When /^I promote Jones to a assessment event$/ do
  visit contact_event_path(@contact_event)
  click_link "Promote to AE"
  
  # we want to make available the promoted event at a later time
  # but only if the promotion was successful
  if current_url == ae_url(@contact_event)
    #Then reload the event to make it available for other steps
    @promoted_event = AssessmentEvent.find(@contact_event.id)
  end
end

Then /^I should be viewing the show assessment event for Jones page$/ do
  path = ae_path(@contact_event)
  current_url.should =~ /#{path}/
end

Then /^the assessment event should have disease forms for MA1 and CA1$/ do
  response.should have_selector("#investigation_form_list li", :content => "MA1")
  response.should have_selector("#investigation_form_list li", :content => "CA1")
end

Then /^the new assessment event should show Smith as the parent$/ do
  response.should have_xpath("//div[@id='contacts_tab']//div[@id='morbidity_parent_event']//*[contains(text(), 'Smith')]")
end

Then /^the parent CMR should show the child as an elevated assessment$/ do
  visit cmr_path(@event)
  response.should have_xpath("//div[@id='contacts_tab']//div[@id='assessment_child_events']//*[contains(text(), 'Jones')]")
end
