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

Given /^I don\'t see any of the core follow up questions$/ do
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    raise "Should not not find #{core_field.key}" if html_source.include?("#{core_field.key} follow up?") == true
  end
end

When(/^I answer all of the core follow ups with a matching condition$/) do
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    key = railsify_core_field_key(core_field.key)

    if core_field.code_name
      # For now, all core condition follow ups are drop downs. Later, we might have to
      # look at the core field's field type to know how to tell Selenium how to fill
      # in the answer
      code = core_field.code_name.codes.empty? ? core_field.code_name.external_codes.all(:order => "code_description ASC").first : core_field.code_name.codes.all(:order => "code_description ASC").first

      @browser.select(key, code.code_description)
    else
      # Originally, all non-code core fields are text inputs. Fields are incrementally
      # getting smarter. Age fields are now type numeric. The rest of the text inputs
      # are still single_line_text
      if core_field.field_type == "single_line_text"
        @browser.type(key, "YES")
      elsif core_field.field_type == "numeric"
        @browser.type(key, "1")
      end

      puts "answering core follow up #{key} with matching condition"
      sleep 1  #to many questions answered at the same time, must wait for AJAX calls
    end
  end
end

Then /^I should see all of the core follow up questions$/ do
  @browser.wait_for_ajax
  sleep 3 # Wait a sec or three for all of the core follow ups to show up
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    html_source.include?("#{core_field.key} follow up?").should be_true, "Expected to see '#{core_field.key} follow up?'"
  end
end

When /^I answer all core follow up questions$/ do
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    answer_investigator_question(@browser, "#{core_field.key} follow up?", "#{core_field.key} answer", html_source)
    puts "answering core follow up question #{core_field.key}"
  end
end

Then /^I should see all follow up answers$/ do
  @browser.wait_for_ajax
  sleep 3 # Wait a sec or three for all of the core follow ups to show up
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    raise "Could not find #{core_field.key} answer" if html_source.include?("#{core_field.key} answer") == false
  end
end

When /^I answer all of the core follow ups with a non\-matching condition$/ do
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    key = railsify_core_field_key(core_field.key)

    if core_field.code_name

      # For now, all core condition follow ups are drop downs. Later, we might have to
      # look at the core field's field type to know how to tell Selenium how to fill
      # in the answer
      #
      # Use the last code for a non-match. First is used for the match.
      code = core_field.code_name.codes.empty? ? core_field.code_name.external_codes.all(:order => "code_description ASC").last : core_field.code_name.codes.all(:order => "code_description ASC").last

      @browser.select(key, code.code_description)
    else
      # Originally, all non-code core fields are text inputs. Fields are incrementally
      # getting smarter. Age fields are now type numeric. The rest of the text inputs
      # are still single_line_text
      if core_field.field_type == "single_line_text"
        @browser.type(key, "NO")
      elsif core_field.field_type == "numeric"
        @browser.type(key, "0")
      end

    end

    puts "answering core follow up #{key} with NON-matching condition"
    sleep 1  #to many questions answered at the same time, must wait for AJAX calls
  end
end

When /^I remove read only entities from the event$/ do
  When %{I remove the reporter from the event}
end

Then /^I should not see any of the core follow up questions$/ do
  @browser.wait_for_ajax
  sleep 3 # Wait a sec or three for all of the core follow ups to show up
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    raise "Should not find #{core_field.key}" if html_source.include?("#{core_field.key} follow up?") == true
  end
end

Then /^I should not see any follow up answers$/ do
  @browser.wait_for_ajax
  sleep 3 # Wait a sec or three for all of the core follow ups to show up
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    raise "Should not find #{core_field.key} answer" if html_source.include?("#{core_field.key} answer") == true
  end
end

Given /^that form has follow ups configured for all configured form fields$/ do
  @core_field_container = @form.core_field_elements_container

  # Create a core field config for every core field
  CoreField.all(:conditions => ['event_type = ? and fb_accessible = true and disease_specific != true', @form.event_type]).each do |core_field|
    create_core_field_config(@form, @core_field_container, core_field, :follow_up => true)
  end
end

When /^I answer all of the form field follow ups with a matching condition$/ do
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    key = core_field.key
    before_follow_up_question = key + " before?"
    before_follow_up_question_html_id = @browser.get_attribute("//label[text()='#{before_follow_up_question}']@for")
    @browser.type(before_follow_up_question_html_id, "YES")
    after_follow_up_question = key + " after?"
    after_follow_up_question_html_id = @browser.get_attribute("//label[text()='#{after_follow_up_question}']@for")
    @browser.type(after_follow_up_question_html_id, "YES")
    sleep(1) # wait for ajax
  end
end

Then /^I should see all of the form field follow up questions$/ do
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    raise "Should find #{core_field.key} before follow up" if html_source.include?("#{core_field.key} before follow up?") == false
    raise "Should find #{core_field.key} after follow up" if html_source.include?("#{core_field.key} after follow up?") == false
  end
end

When /^I answer all form field follow up questions$/ do
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    key = core_field.key
    before_follow_up_question = key + " before follow up?"
    before_follow_up_answer = key + " before follow up answer"
    before_follow_up_question_html_id = @browser.get_attribute("//label[text()='#{before_follow_up_question}']@for")
    @browser.type(before_follow_up_question_html_id, before_follow_up_answer)
    after_follow_up_question = key + " after follow up?"
    after_follow_up_answer = key + " after follow up answer"
    after_follow_up_question_html_id = @browser.get_attribute("//label[text()='#{after_follow_up_question}']@for")
    @browser.type(after_follow_up_question_html_id, after_follow_up_answer)
  end
end

Then /^I should see all form field follow up answers$/ do
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    raise "Should find #{core_field.key} before follow up answer" if html_source.include?("#{core_field.key} before follow up answer") == false
    raise "Should find #{core_field.key} after follow up answer" if html_source.include?("#{core_field.key} after follow up answer") == false
  end
end

When /^I answer all of the form field follow ups with a non\-matching condition$/ do
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    key = core_field.key
    before_follow_up_question = key + " before?"
    before_follow_up_question_html_id = @browser.get_attribute("//label[text()='#{before_follow_up_question}']@for")
    @browser.type(before_follow_up_question_html_id, "NO")
    after_follow_up_question = key + " after?"
    after_follow_up_question_html_id = @browser.get_attribute("//label[text()='#{after_follow_up_question}']@for")
    @browser.type(after_follow_up_question_html_id, "NO")
    sleep(1) # wait for ajax
  end
end

Then /^I should not see any of the form field follow up questions$/ do
  html_source = @browser.get_html_source
  @core_fields ||= CoreField.default_follow_up_core_fields_for(@form.event_type)
  @core_fields.each do |core_field|
    raise "Should not find #{core_field.key} before follow up" if html_source.include?("#{core_field.key} before follow up?") == true
    raise "Should not find #{core_field.key} after follow up" if html_source.include?("#{core_field.key} after follow up?") == true
  end
end

