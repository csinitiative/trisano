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

When(/^I check the add form checkbox$/) do
  check("forms_to_add_#{@published_form.id}")
end

When /^I check the add form checkbox for the form with the name "([^\"]*)"$/ do |name|
  form = Form.find_by_name(name)
  raise "Form not found by name name" if form.nil?
  check("forms_to_add_#{form.id}")
end

When /^the form has been republished$/ do
  @form.publish.should be_true
end

Then(/^I should see a checkbox to add the form$/) do
  response.should contain("Add to Event")
  response.should have_xpath("//div[@id='forms_available']//input[contains(@type, 'checkbox')]")
end

Then(/^I should see the \"Add Forms\" button$/) do
  response.should have_xpath("//div[@id='forms_available']//input[contains(@type, 'submit')]")
end

Then(/^I should not see the \"Add Forms\" button$/) do
  response.should_not have_xpath("//div[@id='forms_available']//input[contains(@type, 'submit')]")
end

Then(/^I should see the name of the added form$/) do
  response.should contain(@published_form.name)
end

Then(/^I should not see the name of the added form$/) do
  response.should_not contain(@published_form.name)
end

