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

# $dont_kill_browser = true

describe 'Sytem functionality for setting the record ID of a CMR' do

  it 'should create a person with all the demographics information' do
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__person_last_name', 'Christiansen')
    @browser.type('morbidity_event_active_patient__person_first_name', 'David')
    @browser.type('morbidity_event_active_patient__address_street_number', '123')
    @browser.type('morbidity_event_active_patient__address_street_name', 'My Street')
    @browser.type('morbidity_event_active_patient__address_city', 'Hometown')
    @browser.select('morbidity_event_active_patient__address_state_id', 'label=Texas')
    @browser.select('morbidity_event_active_patient__address_county_id', 'label=Out-of-state')
    @browser.type('morbidity_event_active_patient__address_postal_code', '46060')
    @browser.type('morbidity_event_active_patient__person_birth_date', '4/1/1989')
    @browser.type('morbidity_event_active_patient__person_approximate_age_no_birthday', '34')
    @browser.click('link=New Telephone / Email')
    @browser.select('morbidity_event_new_telephone_attributes__entity_location_type_id', 'label=Work')
    @browser.type('morbidity_event_new_telephone_attributes__area_code', '333')
    @browser.type('morbidity_event_new_telephone_attributes__phone_number', '5551212')
    @browser.select('morbidity_event_active_patient__person_birth_gender_id', 'label=Male')
    @browser.select('morbidity_event_active_patient__person_ethnicity_id', 'label=Not Hispanic or Latino')
    @browser.add_selection('morbidity_event_active_patient__race_ids', 'label=White')
    @browser.select('morbidity_event_active_patient__person_primary_language_id', 'label=Hmong')
    save_cmr(@browser).should be_true
        
    @browser.is_text_present('Christiansen').should be_true
    @browser.is_text_present('David').should be_true
    @browser.is_text_present('123').should be_true
    @browser.is_text_present('My Street').should be_true
    @browser.is_text_present('Hometown').should be_true
    @browser.is_text_present('Texas').should be_true
    @browser.is_text_present('46060').should be_true
    @browser.is_text_present('Out-of-state').should be_true
    @browser.is_text_present('1989-04-01').should be_true
    @browser.is_text_present('34').should be_false
    @browser.is_text_present('(333) 555-1212').should be_true
    @browser.is_text_present('Male').should be_true
    @browser.is_text_present('46060').should be_true
    @browser.is_text_present('Hmong').should be_true
    @browser.is_text_present('White').should be_true
    @browser.is_text_present('Not Hispanic or Latino').should be_true
    @browser.is_text_present('Jurisdiction of Residence').should be_true
    @browser.is_text_present('Not Applicable').should be_true
  end
  
  it 'should show a jurisdiction of residience' do
    edit_cmr(@browser)
    @browser.select('morbidity_event_active_patient__address_state_id', 'label=Utah')
    @browser.select('morbidity_event_active_patient__address_county_id', 'label=Emery')
    save_cmr(@browser).should be_true
    click_core_tab(@browser, ADMIN)
    @browser.is_text_present('Jurisdiction of Residence').should be_true
    @browser.is_text_present('Southeastern Utah District Health Department').should be_true
  end
end
