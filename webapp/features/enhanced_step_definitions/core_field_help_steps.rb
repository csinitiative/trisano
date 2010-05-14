# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

When /^I fill in enough (.+) data to enable all core fields to show up in show mode$/ do |event_type|
  event_type = event_type.gsub(" ", "_")
  
  # Street number to get the address
  @browser.type("#{event_type}[address_attributes][street_number]", "12")
  
  # Lab name and type for contact and morbidity events
  if event_type == "morbidity_event" || event_type == "contact_event"
    common_test_type = CommonTestType.first.nil? ? CommonTestType.create(:common_name => "Common Test Type") : CommonTestType.first
    add_lab_result(@browser, { :lab_name => "Labby", :lab_test_type => common_test_type.common_name })
  end
end

Then /^I should see help text for all (.+) core fields in (.+) mode$/ do |event_type, mode|
  html_source = @browser.get_html_source
  
  CoreField.find_all_by_event_type(event_type.gsub(" ", "_")).each do |core_field|
    # Ignore lab result fields in show mode
    unless (mode == "show" && core_field.key.include?("[labs]"))
      #@browser.click "//a[@id='add_reporting_agency_link']" if core_field.key == 'Reporting agency'
      help_text = "#{core_field.key} help text"
      raise "Could not find help text for #{core_field.key}" if html_source.include?(help_text) == false

      # Debt: Dig into why this isn't working. The tooltip is visible as the test runs, but the
      # test to see that the tool tip is visible doesn't find the span as it should
      # @browser.is_visible("//span[contains(@id,'core_help_text_#{core_field.id}')]").should be_false
      # @browser.mouse_over("//a[contains(@id,'core_help_text_#{core_field.id}')]")
      # @browser.mouse_move("//a[contains(@id,'core_help_text_#{core_field.id}')]")
      # sleep(2)
      # @browser.is_visible("//span[contains(@id, 'core_help_text_#{core_field.id}')]").should be_true
      # @browser.mouse_out("//a[contains(@id, 'core_help_text_#{core_field.id}')]")
      # sleep(2)
      # @browser.is_visible("//span[@id='core_help_text_#{core_field.id}']").should be_false
    end
  end
end