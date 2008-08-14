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

# TODO: The specs in this test case are dependent on each other. If
# they are run in a different order they fail. This happens when run
# from rake, rahter then the command line spec.
describe 'Adding multiple clinicians to a CMR' do
  
  #$dont_kill_browser = true
  
  before(:all) do
    @browser.open "/trisano/cmrs"
    @browser.wait_for_page_to_load($load_time)
    @original_last_name = get_unique_name(2) + " mc"
    @edited_last_name = get_unique_name(2) + " mc"
    @new_last_name = get_unique_name(2) + " mc"
  end
  
  after(:all) do
    @original_last_name = nil
    @edited_last_name = nil
    @new_last_name = nil
  end
  
  it "should allow a single clinician to be saved with a new CMR" do
    click_nav_new_cmr(@browser).should be_true
    @browser.type "morbidity_event_active_patient__active_primary_entity__person_last_name", "multi-clinician"
    @browser.type "morbidity_event_active_patient__active_primary_entity__person_first_name", "test"
    @browser.type "morbidity_event_clinician__active_secondary_entity__person_last_name", @original_last_name
    @browser.type "morbidity_event_clinician__active_secondary_entity__person_first_name", "multi-clinician"
    save_cmr(@browser).should be_true
    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present(@original_last_name).should be_true
  end

  it "should allow editing a clinician from the CMR's show mode" do
    @browser.click "link=Edit clinician"
    sleep(3)
    # @browser.wait_for_element_present("person_form")
    @browser.type "entity_person_last_name", @edited_last_name
    @browser.click "person-save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("person_form")
    @browser.is_text_present(@edited_last_name).should be_true
    @browser.is_text_present(@original_last_name).should be_false
  end
  
  it "should allow editing a clinician from the CMR's edit mode, changing last name back to the original version" do
    edit_cmr(@browser).should be_true
    @browser.click "link=Edit clinician"
    sleep(3)
    # @browser.wait_for_element_present("person_form")
    @browser.type "entity_person_last_name", @original_last_name
    @browser.click "person-save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("person_form")
    @browser.is_text_present(@edited_last_name).should be_false
    @browser.is_text_present(@original_last_name).should be_true
  end

  it "should allow adding a clinician from the CMR's edit mode" do
    @browser.click "link=Clinical"
    @browser.click "link=New Clinician"
    sleep(3)
    # @browser.wait_for_element_present("person_form")
    @browser.type "entity_person_last_name", @new_last_name
    @browser.click "person-save-button"
    sleep(3)
    # @browser.wait_for_element_not_present("person_form")
    @browser.is_text_present(@new_last_name).should be_true
    @browser.is_text_present(@original_last_name).should be_true
  end

end
