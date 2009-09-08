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

Given /^I don't see any of the core follow up questions$/ do
  CoreField.find_all_by_event_type_and_can_follow_up(@form.event_type, true).each do |core_field|
    raise "Should not not find #{core_field.name}" if @browser.get_html_source.include?("#{core_field.name} follow up?") == true
  end
end

When(/^I answer all of the core follow ups with a matching condition$/) do
  CoreField.find_all_by_event_type_and_can_follow_up(@form.event_type, true).each do |core_field|
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
      
    end
  end
end

Then /^I should see all of the core follow up questions$/ do
  CoreField.find_all_by_event_type_and_can_follow_up(@form.event_type, true).each do |core_field|
    raise "Could not find #{core_field.name}" if @browser.get_html_source.include?("#{core_field.name} follow up?") == false
  end
end

When /^I answer all core follow up questions$/ do
  CoreField.find_all_by_event_type_and_can_follow_up(@form.event_type, true).each do |core_field|
    answer_investigator_question(@browser, "#{core_field.name} follow up?", "#{core_field.name} answer")
  end
end

Then /^I should see all follow up answers$/ do
  CoreField.find_all_by_event_type_and_can_follow_up(@form.event_type, true).each do |core_field|
    raise "Could not find #{core_field.name} answer" if @browser.get_html_source.include?("#{core_field.name} answer") == false
  end
end

When /^I answer all of the core follow ups with a non\-matching condition$/ do
  CoreField.find_all_by_event_type_and_can_follow_up(@form.event_type, true).each do |core_field|
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

  end
end

Then /^I should not see any of the core follow up questions$/ do
  CoreField.find_all_by_event_type_and_can_follow_up(@form.event_type, true).each do |core_field|
    raise "Should not find #{core_field.name}" if @browser.get_html_source.include?("#{core_field.name} follow up?") == true
  end
end

Then /^I should not see any follow up answers$/ do
  CoreField.find_all_by_event_type_and_can_follow_up(@form.event_type, true).each do |core_field|
    raise "Should not find #{core_field.name} answer" if @browser.get_html_source.include?("#{core_field.name} answer") == true
  end
end
