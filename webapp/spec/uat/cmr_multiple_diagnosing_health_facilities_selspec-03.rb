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

 # $dont_kill_browser = true

describe 'Adding multiple diagnosing health facilities to a CMR' do
  
  before(:all) do
    @facility_name_1 = get_unique_name(2) + " dhf-uat"
    @facility_name_2 = get_unique_name(2) + " dhf-uat"
  end

  it "should allow adding new health facilities to a new CMR" do
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser)
    add_demographic_info(@browser, { :last_name => "Diagnosing-HF", :first_name => "Johnny" })
    click_core_tab(@browser, "Clinical")
    @browser.type_keys "diagnostics_search", "b"
    wait_for_element_present("//div[@id='diagnostics_search_choices']/ul")
    @browser.click "//div[@id='diagnostics_search_choices']/ul/li/span[@class='place_name'][text()='Beaver Valley Hospital']"
    wait_for_element_present("//div[@id='existing_diagnostic_facilities']/div[@class='existing_diagnostic']")
    add_diagnostic_facility(@browser, { :name => @facility_name_1, :place_type => "S" }, 1)
    save_cmr(@browser).should be_true

    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present('Beaver Valley Hospital').should be_true
    @browser.is_text_present('Hospital / ICP').should be_true
    @browser.is_text_present(@facility_name_1).should be_true
    @browser.is_text_present("School").should be_true
  end

  it "should allow removing a diagnosing facility" do
    edit_cmr(@browser)
    remove_diagnostic_facility(@browser)
    save_cmr(@browser).should be_true
    @browser.is_text_present(@facility_name_1).should be_false
  end

  it "should allow adding new diagnosing facilities from edit mode" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Clinical")
    @browser.type_keys "diagnostics_search", "g"
    wait_for_element_present("//div[@id='diagnostics_search_choices']/ul")
    @browser.click "//div[@id='diagnostics_search_choices']/ul/li/span[@class='place_name'][text()='Gunnison Valley Hospital']"
    wait_for_element_present("//div[@id='existing_diagnostic_facilities']/div[@class='existing_diagnostic']")
    add_diagnostic_facility(@browser, { :name => @facility_name_2, :place_type => "S" }, 1)
    save_cmr(@browser).should be_true
    
    @browser.is_text_present('CMR was successfully updated.').should be_true
    @browser.is_text_present('Gunnison Valley Hospital').should be_true
    @browser.is_text_present(@facility_name_2).should be_true
    @browser.is_text_present("School").should be_true
  end

  it "should work for contacts" do
    edit_cmr(@browser)
    add_contact(@browser, {:last_name => "Smith", :first_name => "Will", :disposition => "Other"})
    save_cmr(@browser).should be_true
    edit_contact(@browser)
    click_core_tab(@browser, "Clinical")
    @browser.type_keys "diagnostics_search", "g"
    wait_for_element_present("//div[@id='diagnostics_search_choices']/ul")
    @browser.click "//div[@id='diagnostics_search_choices']/ul/li/span[@class='place_name'][text()='Gunnison Valley Hospital']"
    wait_for_element_present("//div[@id='existing_diagnostic_facilities']/div[@class='existing_diagnostic']")
    add_diagnostic_facility(@browser, { :name => @facility_name_2, :place_type => "S" }, 1)
    save_cmr(@browser).should be_true

    @browser.is_text_present('Gunnison Valley Hospital').should be_true
    @browser.is_text_present(@facility_name_2).should be_true
    @browser.is_text_present("School").should be_true
  end

end
