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

require 'active_support'

require File.dirname(__FILE__) + '/spec_helper'
describe 'Copying an address from the Original Patient' do
  
$dont_kill_browser = true
  
  before(:all) do
    @last_name = get_unique_name(1) + "-copy-uat"
    @first_contact = get_unique_name(1) + "-copy-uat"
    @second_contact = get_unique_name(1) + "-copy-uat"
    @browser.open "/trisano/cmrs"
    @city = 'BYOB'
  end
  
  it 'should create a new cmr with associated contacts and "save & continue".' do
    click_nav_new_cmr(@browser).should be_true

    @browser.type 'morbidity_event_active_patient__person_last_name', @last_name
    @browser.type 'morbidity_event_active_patient__address_street_name', 'Postin Place'
    @browser.type 'morbidity_event_active_patient__address_street_number', '123'
    @browser.type 'morbidity_event_active_patient__address_unit_number', '54'
    @browser.type 'morbidity_event_active_patient__address_city', @city
    @browser.select 'morbidity_event_active_patient__address_state_id', 'Utah'
    @browser.select 'morbidity_event_active_patient__address_county_id', 'Beaver'
    @browser.type 'morbidity_event_active_patient__address_postal_code', '12345'

    click_core_tab(@browser, "Contacts")
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'last_name')]", @first_contact
    @browser.click "link=Add a contact"
    sleep(1)
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'last_name')]", @second_contact

    save_and_continue(@browser).should be_true
  end

  it 'should copy over the address correctly' do
    copy_address
  end

  it 'should copy a change in address if copy is clicked again' do
    @city = get_unique_name(1) + '-copy-uat'
    @browser.click "link=" + @last_name
    @browser.wait_for_page_to_load($load_time)
    @browser.click "link=Edit"
    @browser.wait_for_page_to_load($load_time)
    @browser.type 'morbidity_event_active_patient__address_city', @city
    save_and_continue(@browser).should be_true

    click_core_tab(@browser, "Contacts")
    copy_address
  end

end

def copy_address
    @browser.click "//a[@id='edit-contact-event'][1]"
    @browser.wait_for_page_to_load($load_time)
    @browser.click "//input[@value='Copy From Original Patient']"
    sleep(3)
    save_cmr(@browser).should be_true
    @browser.is_text_present('Postin Place').should be_true
    @browser.is_text_present('123').should be_true
    @browser.is_text_present('54').should be_true
    @browser.is_text_present(@city).should be_true
    @browser.is_text_present('Utah').should be_true
    @browser.is_text_present('Beaver').should be_true
    @browser.is_text_present('12345').should be_true
end
