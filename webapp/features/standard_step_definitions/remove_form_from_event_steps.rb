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

When(/^I check the remove form checkbox$/) do
  check("forms_to_remove_#{@published_form.id}")
end

When(/^I see the form and answers on the event$/) do
  response.should contain(@form.name)
  response.should have_xpath("//div[@id='investigation_form']//input[contains(@value, '#{@answer_text}')]")
end

Then(/^I should not see a checkbox to remove the form$/) do
  response.should_not contain("Remove from event")
  response.should_not have_xpath("//div[@id='forms_in_use']//input[contains(@type, 'checkbox')]")
end

Then(/^I should not see the \"Remove Forms\" button$/) do
  response.should_not have_xpath("//div[@id='forms_in_use']//input[contains(@type, 'submit')]")
end


