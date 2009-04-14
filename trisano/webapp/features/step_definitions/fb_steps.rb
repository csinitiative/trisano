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

#
# Basic setup
#

Given(/^a form exists with the name (.+) \((.+)\) for a (.+) with the disease (.+)$/) do |form_name, form_short_name, event_type, disease|
  @form = create_form(event_type, form_name, form_short_name, disease)
end

#
# Basic navigation
#

When /^I navigate to the new form view$/ do
  visit new_form_path
  response.should contain("Create Form")
end

When /^I navigate to the form builder interface$/ do
  visit builder_path(@form)
  response.should contain("Form Builder")
end

#
# Form-creation helpers
#

When /^I create a new form named (.+) \((.+)\) for a (.+) with the disease (.+)$/ do |form_name, form_short_name, event_type, disease|
  @form = create_form(event_type, form_name, form_short_name, disease)
end

When /^I enter a form name of (.+)$/ do |form_name|
  fill_in "form_name", :with => form_name
end

When /^I enter a form short name of (.+)$/ do |form_short_name|
  fill_in "form_short_name", :with => form_short_name
end

When /^I select a form event type of (.+)$/ do |event_type|
  select event_type, :from => "form_event_type"
end

When /^I check the disease (.+)$/ do |disease|
  check disease
end

When /^I create the new form$/ do
  submit_form "form_submit"
end

#
# Question-creation helpers
#

When /^I enter the question text \"(.+)\"$/ do |question_text|
  fill_in "question_element_question_attributes_question_text", :with => question_text
end



Then /^I should be able to create the new form and see the form name (.+)$/ do |form_name|
  save_new_form(form_name)
end
