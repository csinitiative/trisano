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

When /^I fill in enough (.+) data to enable all core fields to show up in show mode$/ do |event_type|
  event_type = event_type.gsub(" ", "_")

  # Street number to get the address
  @browser.type("#{event_type}[address_attributes][street_number]", "12")

  # Lab name and type for contact and morbidity events
  if event_type == "morbidity_event" || event_type == "contact_event" || event_type == "assessment_event"
    common_test_type = CommonTestType.find_or_create_by_common_name("Common Test Type")
    add_lab_result(@browser, { :lab_name => "Labby", :lab_test_type => common_test_type.common_name })
    add_hospital(@browser, {:name => "Allen Memorial Hospital"}, index = 1)
  end
end

Then /^I should see help text for all (.+) core fields in (.+) mode$/ do |event_type, mode|
  html_source = @browser.get_html_source

  @core_fields ||= CoreField.all(:conditions => [<<-SQL, event_type.gsub(" ", "_"), false, %w(section tab event)])
    event_type = ? and disease_specific = ? and field_type NOT IN (?) and repeater = FALSE
  SQL
  @core_fields.each do |core_field|
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

Before('@flush_core_fields_cache') do
  require 'net/http'
  cf = CoreField.first
  http = Net::HTTP.new('localhost', '8080')
  request = Net::HTTP::Put.new("/trisano/core_fields/#{cf.id}")
  request.set_form_data({"core_field[help_text]" => cf.help_text})
  request['Accept'] = 'application/xml'
  response = http.request(request)
  unless response.code == '200'
    puts "Failed to flush core field cache. Response status #{response.code}"
  end
end
