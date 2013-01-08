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

When(/^I add an existing contact$/) do
  click_core_tab(@browser, 'Contacts')
  @existing_contact_name = get_unique_name(2)
  @contact_event.interested_party.person_entity.person.last_name = @existing_contact_name
  @contact_event.interested_party.person_entity.person.save!
  @browser.type("contact_search_name", @contact_event.interested_party.person_entity.person.last_name)
  @browser.click("contact_search")

  wait_for_element_present("//div[@id='contact_search_results']/table")
  @browser.click "//div[@id='contact_search_results']//a[@id='add_contact_#{@contact_event.id}']"
  wait_for_element_present("//div[@class='contact_from_search']")
end

When(/^I click remove for that contact$/) do
  @browser.click("link=Remove")
  wait_for_element_not_present("//div[@id='contact_child_events']/div[@class='contact_from_search']")
end

Then(/^I should not see the contact$/) do
  @browser.is_element_present("//div[@id='contact_child_events']/div[@class='contact_from_search']").should be_false
end

When(/^I add a new contact$/) do
  @new_contact_name = get_unique_name(2)
  add_contact(@browser, { :last_name => @new_contact_name })
end

Then(/^I should see all added contacts$/) do
  @browser.is_text_present(@existing_contact_name).should be_true
  @browser.is_text_present(@new_contact_name).should be_true
end

When(/^I check a contact to remove$/) do
  remove_contact(@browser)
end

Then(/^the removed contact should be struckthrough$/) do
   @browser.is_element_present("//td[@class='struck-through']").should be_true
end

