# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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
require 'yaml'

describe "help text for place core fields" do
  # $dont_kill_browser = true
  
  core_fields = YAML::load_file(File.join(File.dirname(__FILE__), '..', '..', 'db', 'defaults', 'core_fields.yml'))

  before :all do
    @browser.open '/trisano/core_fields'
  end

  core_fields.collect{ |k,v| v }.select{|f| f['event_type'] == 'place_event'}.each do |core_field|
    it "should edit #{core_field['event_type']} core field help text for #{core_field['name']}" do
      @browser.click("link=#{core_field['name']}")
      @browser.wait_for_page_to_load
      @browser.click("link=Edit")
      @browser.wait_for_page_to_load
      @browser.type "core_field_help_text", "#{core_field['name']} help"
      @browser.click '//input[@value="Update"]'
      @browser.wait_for_page_to_load
      @browser.is_text_present('Core field was successfully updated').should be_true
      @browser.click "link=< Back to Core Fields"
      @browser.wait_for_page_to_load
    end 

    it "should navigate to a place event edit view" do
      create_basic_investigatable_cmr(@browser, 'Biel', 'Lead poisoning', 'Bear River Health Department')
      edit_cmr(@browser).should be_true
      add_place(@browser, {:name => 'Davis Autoparts'})
      save_cmr(@browser).should be_true
      click_link_by_order(@browser, "edit-place-event", 1)
      @browser.wait_for_page_to_load($load_time)
    end
            
    it "should have #{core_field['event_type']} help bubble after #{core_field['name']}" do
      assert_tooltip_exists(@browser, "#{core_field['name']} help").should be_true
      @browser.click("link=ADMIN")
      @browser.wait_for_page_to_load
      @browser.click("link=Core Fields")
      @browser.wait_for_page_to_load
    end
      
  end
end
