# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

Given /^a queue named "([^\"]*)" in jurisdiction "([^\"]*)"$/ do |queue_name, jurisdiction_name|
  @event_queue = EventQueue.find_or_create_by_queue_name_and_jurisdiction_id queue_name, jurisdiction_id_by_name(jurisdiction_name) 
  @event_queue.should be_valid
end

Then /^I should see the assigned event$/ do
  response.should have_xpath("//a[@href = '/cmrs/#{@event.id}']")
end

Then /^I should see all available event states$/ do
  response.should have_selector("#states_selector") do |select|
    select.should have_selector("option[value='accepted_by_lhd']")
    select.should have_selector("option[value='rejected_by_lhd']")
    select.should have_selector("option[value='assigned_to_queue']")
    select.should have_selector("option[value='assigned_to_investigator']")
    select.should have_selector("option[value='under_investigation']")
    select.should have_selector("option[value='rejected_by_investigator']")
    select.should have_selector("option[value='investigation_complete']")
    select.should have_selector("option[value='approved_by_lhd']")
    select.should have_selector("option[value='reopened_by_manager']")
    select.should have_selector("option[value='reopened_by_state']")
    select.should have_selector("option[value='closed']")
    select.should have_selector("option[value='not_routed']")
  end
end

Then /^I should see a listing for (.+)$/ do |name|
  response.should have_xpath("//div[@class='patientname'][contains(text(), '#{name}')]")
end

Then /^I should not see a listing for (.+)$/ do |name|
  response.should_not have_xpath("//div[@class='patientname'][contains(text(), '#{name}')]")
end

