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

When(/^I see the form and answers on the event$/) do
  @browser.is_text_present(@short_name).should be_true
  @browser.is_element_present("//div[@id='investigation_form']//input[contains(@value, '#{@answer_text}')]").should be_true
end

When(/^I check the form for removal$/) do
  @browser.check("//div[@id='forms_in_use']//input[@value='#{@published_form.id}']")
end

When(/^I check the form for addition$/) do
  @browser.check("//div[@id='forms_available']//input[@value='#{@published_form.id}']")
end

Then(/^I should no longer see the form on the event$/) do
  @browser.click "link=Edit CMR"
  @browser.wait_for_page_to_load
  @browser.is_text_present("Person Information").should be_true
  @browser.is_text_present(@short_name).should be_true
end

Then(/^I should no longer see the answers on the event$/) do
  @browser.is_element_present("//div[@id='investigation_form']//input[contains(@value, '#{@answer_text}')]").should be_false
end
