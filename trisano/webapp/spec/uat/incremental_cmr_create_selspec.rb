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
describe 'User functionality for creating and saving CMRs' do
  
  #  $dont_kill_browser = true
  
  before(:all) do
    @last_name = get_unique_name(1)
    @browser.open "/trisano/cmrs"
  end
  
  it 'should save a CMR with just a last name' do
    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', @last_name)
    save_cmr(@browser).should be_true
    @browser.is_text_present(@last_name).should be_true
  end
  
  it 'should save the contact information' do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Contacts")
    @browser.click "link=Add a contact"
    sleep(1)
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'last_name')]", "Costello"
    save_cmr(@browser).should be_true
    @browser.is_text_present('Costello').should be_true
  end
  
  it 'should save the street name' do    
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Demographics")
    @browser.type('morbidity_event_active_patient__active_primary_entity__address_street_name', 'Junglewood Court')
             
    save_cmr(@browser).should be_true
  end
  
  it 'should save the phone number' do
    edit_cmr(@browser).should be_true
    @browser.click 'link=New Telephone / Email'
    @browser.select 'morbidity_event_new_telephone_attributes__entity_location_type_id', 'label=Work'
    @browser.type 'morbidity_event_new_telephone_attributes__area_code',   '801'
    @browser.type 'morbidity_event_new_telephone_attributes__phone_number', '5811234'
    save_cmr(@browser).should be_true
  end
  
  it 'should save the disease info' do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Clinical")
    @browser.select 'morbidity_event_disease_disease_id', 'label=AIDS'
    save_cmr(@browser).should be_true
  end
  
  it 'should save the lab result' do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Laboratory")
    @browser.click("link=Add a lab result")
    sleep 3
    @browser.type("//input[contains(@id, 'model_auto_completer_tf')]", 'Lab')
    @browser.type('morbidity_event_new_lab_attributes__lab_result_text', 'Positive')
    @browser.select 'morbidity_event_new_lab_attributes__specimen_source_id', 'label=Animal head'
    save_cmr(@browser).should be_true
    @browser.is_text_present('Animal head').should be_true
    @browser.is_text_present('Positive').should be_true
  end
  
  it 'should save the treatment info' do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Clinical")
    @browser.click("link=New Treatment")
    sleep 3
    @browser.select 'participations_treatment_treatment_given_yn_id', 'label=Yes'
    @browser.type('participations_treatment_treatment', 'Leaches')
    @browser.click 'treatment-save-button'
    sleep 3
    save_cmr(@browser).should be_true
  end
  
  it 'should save the reporting info' do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Reporting")
    @browser.type "//input[contains(@id, 'model_auto_completer_tf')]", 'Happy Jacks Health Store'
    save_cmr(@browser).should be_true
  end

  it 'should save administrative info' do
    edit_cmr(@browser).should be_true
    click_core_tab(@browser, "Administrative")
    @browser.type 'morbidity_event_event_name', 'Test Event'
    save_cmr(@browser).should be_true
  end
  
  it 'should still have all the data present' do
    @browser.is_text_present(@last_name).should be_true
    @browser.is_text_present('Junglewood Court').should be_true
    @browser.is_text_present('(801) 581-1234').should be_true
    
    click_core_tab(@browser, "Clinical")
    @browser.is_text_present('AIDS').should be_true
    @browser.is_text_present('Leaches').should be_true
    
    click_core_tab(@browser, "Laboratory")
    @browser.is_text_present('Animal head').should be_true
    
    click_core_tab(@browser, "Administrative")
    @browser.is_text_present('Test Event').should be_true
    
    click_core_tab(@browser, "Contacts")
    @browser.is_text_present('Costello').should be_true
  end
end
