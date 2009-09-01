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
  CoreField.find_all_by_event_type("morbidity_event").each do |core_field|
    if core_field.can_follow_up
      @browser.is_text_present("#{core_field.name} follow up?").should be_false
    end
  end
end

When(/^I answer all of the core follow ups with a matching condition$/) do
  CoreField.find_all_by_event_type("morbidity_event").each do |core_field|
    if core_field.can_follow_up

      key = core_field.key.chop!.gsub("]", "_attributes]") << "]"

      if core_field.code_name
        # For now, all core condition follow ups are drop downs. Later, we might have to
        # look at the core field's field type to know how to tell Selenium how to fill
        # in the answer
        code = core_field.code_name.codes.empty? ? core_field.code_name.external_codes.first : core_field.code_name.codes.first
        
        @browser.select(key, code.code_description)
      else
        # At least for now, all non-code core fields are text inputs. This may need to get
        # smarter about the core field's field_type at some point.
        @browser.type(key, "YES")
      end

    end

    @browser.focus("morbidity_event[interested_party_attributes][person_entity_attributes][email_addresses_attributes][1][email_address]")
  end
end

Then /^I should see all of the core follow up questions$/ do
  CoreField.find_all_by_event_type("morbidity_event").each do |core_field|
    if core_field.can_follow_up
      if @browser.get_html_source.include?("#{core_field.name} follow up?") == false
        # TODO: Switch to raise once the test is fully developed
        p "Could not find #{core_field.name}"
      end
    end
  end
end

When /^I answer all core follow up questions$/ do
  CoreField.find_all_by_event_type("morbidity_event").each do |core_field|
   
    if core_field.can_follow_up
      answer_investigator_question(@browser, "#{core_field.name} follow up?", "#{core_field.name} answer")
    end
  end
end

Then /^I should see all follow up questions and their answers$/ do
  pending
end

