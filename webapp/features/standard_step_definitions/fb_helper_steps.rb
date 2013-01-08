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

#
# Givens
# 

Given /^that form has core field configs configured for all core fields$/ do
  @core_field_container = @form.core_field_elements_container

  # Create a core field config for every core field
  CoreField.all(:conditions => ['event_type = ? and fb_accessible = true and disease_specific != true and repeater = false', @form.event_type]).each do |core_field|
    create_core_field_config(@form, @core_field_container, core_field)
  end
end

Given /^I already have a form with the short name "([^\"]*)"$/ do |short_name|
  @form = create_form('morbidity', 'Already created', short_name, 'African Tick Bite Fever')
  @last_used_short_name = @form.short_name
end

Given /^I already have a deactivated form with the short name "([^\"]*)"$/ do |short_name|
  @form = create_form('morbidity', 'Already created', short_name, 'African Tick Bite Fever')
  @form.publish
  @form.should_not be_nil, "Unable to successfully publish form. Check feature logs."
  @form.deactivate
  @last_used_short_name = @form.short_name
end

Given /^I already have a published form$/ do
  @form = create_form('morbidity', 'Already created', 'something_published', 'African Tick Bite Fever')
  @published_form = @form.publish
  @published_form.should_not be_nil, "Unable to successfully publish form. Check feature logs."
end

Given /^I already have a form with the name "([^\"]*)"$/ do |name|
  @form = create_form('morbidity', name, name.underscore, 'African Tick Bite Fever')
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

When /^I navigate to the form edit view$/ do
  visit edit_form_path(@form)
  response.should contain("Edit Form")
end

#
# Form-creation helpers
#

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

When /^I re\-enter the duplicate short name$/ do
  fill_in "form_short_name", :with => @last_used_short_name 
end

Then /^I should see error "(.+)"$/ do |msg|
  response.should have_xpath("//div[@id='errorExplanation']")
  response.body.should =~ /#{msg}/m
end

Then /^I should be able to fill in the short name field$/ do
  response.should have_xpath("//input[@id='form_short_name']")
end

Then /^I should not be able to fill in the short name field$/ do
  response.should_not have_xpath("//input[@id='form_short_name']")
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
