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

require File.dirname(__FILE__) + '/spec_helper'
describe "help text for morbidity core fields", :shared => true do
  #   $dont_kill_browser = true

  before :all do
    #    @browser.open '/trisano/core_fields'
  end

  $test_core_fields.each do |core_field|

    # Special exception for reporting agency, as a link needs to be clicked to bring this field into view.
    next if core_field['name'].downcase.include?("reporting agency")

    it "should edit #{core_field['event_type']} core field help text for #{core_field['name']}" do
      @browser.open("/trisano/core_fields")
      @browser.wait_for_page_to_load
      @browser.click("//div[@id='rot'][1]//a[text()='#{core_field['name']}']")
      @browser.wait_for_page_to_load
      @browser.click("link=Edit")
      @browser.wait_for_page_to_load
      @browser.type "core_field_help_text", "#{core_field['name']} help"
      @browser.click '//input[@value="Update"]'
      @browser.wait_for_page_to_load
      @browser.is_text_present('Core field was successfully updated').should be_true
      @browser.is_text_present("#{core_field['name']} help").should be_true
    end

    it "should navigate to a morbidity event edit view" do
      @browser.open "/trisano/cmrs/new"
      @browser.wait_for_page_to_load
    end

    it "should have #{core_field['event_type']} help bubble after #{core_field['name']}" do
      @browser.click "//a[@id='add_reporting_agency_link']" if core_field['name'] == 'Reporting agency'
      assert_tooltip_exists(@browser, "#{core_field['name']} help").should be_true
    end

  end
end
