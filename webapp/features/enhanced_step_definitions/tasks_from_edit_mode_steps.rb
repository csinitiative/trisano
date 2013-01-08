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

When(/^I click the Add Task link$/) do
  link = "//div[@id='title_area']//a[contains(text(), 'Add Task')]"
  @browser.click(link)
  @browser.wait_for_ajax
end

When(/^I fill in the New Task form$/) do
  @browser.type("task_name", "Do this please!")
  @browser.type("task_due_date", Date.tomorrow.to_s)
end

When(/^I submit the New Task form$/) do
  @browser.click("new-task-create")
  @browser.wait_for_ajax
end

Then /^the flash should disappear$/ do
  sleep 3
  @browser.get_eval("selenium.browserbot.getCurrentWindow().$('flash-message').visible()").should == "false"
end

Then /^the task form should not be visible$/ do
  @browser.get_html_source.include?("event-task-form").should be_true
  @browser.get_html_source.include?("new-event-form").should be_false
end

Then /^I should see the task$/ do
  @browser.get_html_source.include?("Do this please!").should be_true
end

