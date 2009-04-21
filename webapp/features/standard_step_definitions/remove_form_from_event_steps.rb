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


When(/^I see the form and answers on the event$/) do
  response.should contain(@form.name)
  response.should have_xpath("//div[@id='investigation_form']//input[contains(@value, 'disease specific answer')]")
end

When(/^I check the form for removal$/) do
  check("forms_to_remove_")
end

Then(/^I should no longer see the form on the event$/) do
  click_link "Edit"
  response.should_not contain(@form.name)
  response.should_not have_xpath("//div[@id='investigation_form']//input[contains(@value, 'disease specific answer')]")
end

Then(/^I should no longer see the answers on the event$/) do
  response.should_not contain("disease specific answer")
end














