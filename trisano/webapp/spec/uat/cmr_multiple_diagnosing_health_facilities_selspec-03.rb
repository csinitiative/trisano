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
    @browser.type "morbidity_event_active_patient__person_last_name", "Diagnosing-HF"
    @browser.type "morbidity_event_active_patient__person_first_name", "Johnny"

    click_core_tab(@browser, "Clinical")
    @browser.type_keys "diagnostic_search", "b"
    wait_for_element_present("//div[@id='diagnostic_search_choices']/ul")
    @browser.click "//div[@id='diagnostic_search_choices']/ul/li/span[@class='place_name'][text()='Beaver Valley Hospital']"
    wait_for_element_present("//div[@id='existing_diagnostic_facilities']/div[@class='existing_diagnostic']")
    @browser.type "morbidity_event_new_diagnostic_attributes__name", @facility_name_1
    @browser.select "morbidity_event_new_diagnostic_attributes__place_type_id", "label=School"

    save_cmr(@browser).should be_true

    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present('Beaver Valley Hospital').should be_true
    @browser.is_text_present('Hospital / ICP').should be_true
    @browser.is_text_present(@facility_name_1).should be_true
    @browser.is_text_present("School").should be_true
  end

  it "should allow removing a diagnosing facility" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Clinical")
    value = "//div[@id='existing_diagnostic_facilities']/div[1]/span[contains(@id, 'diagnosing_facility')]/text()[2]"
    @browser.click "//div[@id='existing_diagnostic_facilities']//a"
    save_cmr(@browser).should be_true
    @browser.is_text_present(value).should_not be_true
  end

  it "should allow adding new diagnosing facilities from edit mode" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Clinical")
    @browser.type_keys "diagnostic_search", "g"
    wait_for_element_present("//div[@id='diagnostic_search_choices']/ul")
    @browser.click "//div[@id='diagnostic_search_choices']/ul/li/span[@class='place_name'][text()='Gunnison Valley Hospital']"
    wait_for_element_present("//div[@id='existing_diagnostic_facilities']/div[@class='existing_diagnostic']")
    @browser.click "link=Add a diagnosing facility"
    @browser.type "morbidity_event_new_diagnostic_attributes__name", @facility_name_2
    @browser.select "morbidity_event_new_diagnostic_attributes__place_type_id", "label=Pool"

    save_cmr(@browser).should be_true
    @browser.is_text_present('CMR was successfully updated.').should be_true
    @browser.is_text_present('Gunnison Valley Hospital').should be_true
    @browser.is_text_present(@facility_name_2).should be_true
    @browser.is_text_present("Pool").should be_true
  end

  it "should work for contacts" do
    edit_cmr(@browser)
    add_contact(@browser, {:last_name => "Smith", :first_name => "Will", :disposition => "Other"})
    save_cmr(@browser).should be_true
    @browser.click "edit-contact-event"
    @browser.wait_for_page_to_load($load_time)
    click_core_tab(@browser, "Clinical")
    @browser.type_keys "diagnostic_search", "g"
    wait_for_element_present("//div[@id='diagnostic_search_choices']/ul")
    @browser.click "//div[@id='diagnostic_search_choices']/ul/li/span[@class='place_name'][text()='Gunnison Valley Hospital']"
    wait_for_element_present("//div[@id='existing_diagnostic_facilities']/div[@class='existing_diagnostic']")
    @browser.click "link=Add a diagnosing facility"
    @browser.type "contact_event_new_diagnostic_attributes__name", @facility_name_2
    @browser.select "contact_event_new_diagnostic_attributes__place_type_id", "label=Pool"

    save_cmr(@browser).should be_true
    @browser.is_text_present('Gunnison Valley Hospital').should be_true
    @browser.is_text_present(@facility_name_2).should be_true
    @browser.is_text_present("Pool").should be_true
  end

end
