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

Then /^the encounter should be struck\-through$/ do
  @browser.is_element_present("//table[@id='encounters']//td[@class='struck-through'][text()='#{@encounter.participations_encounter.user.uid}']").should be_true
end

When /^I click the encounter parent link$/ do
  parent_event_name = @encounter.parent_event.party.full_name
  @browser.click("link=#{parent_event_name}")
  @browser.wait_for_page_to_load($load_time)
end

When /^I click the "([^\"]*)" link and accept the confirmation$/ do |link|
  @browser.click("link=#{link}")
  @browser.get_confirmation
  @browser.wait_for_page_to_load($load_time)
end
