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

describe 'Adding multiple clinicians to a CMR' do
  
  #$dont_kill_browser = true
  
  before(:all) do
    @browser.open "/trisano/cmrs"
    @browser.wait_for_page_to_load($load_time)
    @original_last_name_1 = get_unique_name(2) + " mc"
    @original_last_name_2 = get_unique_name(2) + " mc"
    @edited_last_name = get_unique_name(2) + " mc"
    @new_last_name = get_unique_name(2) + " mc"
  end
  
  after(:all) do
    @original_last_name = nil
    @edited_last_name = nil
    @new_last_name = nil
  end
  
  it "should allow multiple clinicians to be saved with a new CMR" do
    click_nav_new_cmr(@browser).should be_true
    @browser.type "morbidity_event_active_patient__person_last_name", "multi-clinician"
    @browser.type "morbidity_event_active_patient__person_first_name", "test"

    click_core_tab(@browser, "Clinical")
    @browser.click "link=Add a clinician"
    sleep(1)

    @browser.type "//div[@class='clinician'][1]//input[contains(@id, 'last_name')]", @original_last_name_1
    @browser.type "//div[@class='clinician'][1]//input[contains(@id, 'first_name')]", "John"
    @browser.type "//div[@class='clinician'][1]//input[contains(@id, 'phone_number')]", "5551212"

    @browser.type "//div[@class='clinician'][2]//input[contains(@id, 'last_name')]", @original_last_name_2
    @browser.type "//div[@class='clinician'][2]//input[contains(@id, 'first_name')]", "Joe"
    @browser.type "//div[@class='clinician'][2]//input[contains(@id, 'phone_number')]", "5552323"

    save_cmr(@browser).should be_true

    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present(@original_last_name_1).should be_true
    @browser.is_text_present("555-1212").should be_true
    @browser.is_text_present(@original_last_name_2).should be_true
    @browser.is_text_present("555-2323").should be_true
  end

  it "should allow removing a clinician" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Clinical")
    @browser.click "remove_clinician_link"
    save_cmr(@browser).should be_true
    @browser.is_text_present(@original_last_name_1).should_not be_true
  end

  it "should allow editing a clinician" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Clinical")
    @browser.type "//div[@class='clinician'][1]//input[contains(@id, 'first_name')]", "William"
    @browser.type "//div[@class='clinician'][1]//input[contains(@id, 'area_code')]", "777"
    @browser.type "//div[@class='clinician'][1]//input[contains(@id, 'phone_number')]", "6666666"   
    save_cmr(@browser).should be_true
    @browser.is_text_present('William').should be_true
    @browser.is_text_present('(777) 666-6666').should be_true
  end

end
