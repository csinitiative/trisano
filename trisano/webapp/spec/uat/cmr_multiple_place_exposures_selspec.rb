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
require 'active_support'

# $dont_kill_browser = true

describe 'Adding multiple place exposures to a CMR' do

  before(:all) do
    @browser.open "/trisano/cmrs"
    @browser.wait_for_page_to_load($load_time)
    @orginal_place_name = "Davis Nat"
    @new_place_name = "Davis Natatorium"
    @date_of_exposure = 10.days.ago.strftime('%B %d, %Y')
    @new_date_of_exposure = 7.days.ago.strftime('%B %d, %Y')
  end

  after(:all) do
    @orginal_last_name = nil
    @new_place_name = nil
    @date_of_exposure = nil
    @new_date_of_exposure = nil
  end

  it "should allow a single place exposure to be saved w/ a new CMR" do
    click_nav_new_cmr(@browser).should be_true
    @browser.type "morbidity_event_active_patient__active_primary_entity__person_last_name", "multi_place_exposure"
    @browser.type "morbidity_event_new_place_exposure_attributes__name", @orginal_place_name
    @browser.type "morbidity_event_new_place_exposure_attributes__date_of_exposure", @date_of_exposure
    @browser.select "morbidity_event_new_place_exposure_attributes__place_type_id", "label=Pool"
    save_cmr(@browser).should be_true
    @browser.is_text_present(@orginal_place_name).should be_true
    @browser.is_text_present('Pool').should be_true
    @browser.is_text_present(@date_of_exposure).should be_true
  end

  it "should allow editing a place exposure from the CMR's edit mode" do
    edit_cmr(@browser).should be_true
    sleep(3)
    click_core_tab(@browser, "Epidemiological")
    @browser.type "//div[@class='place_exposure'][1]//input[contains(@id, '_name')]", @new_place_name
    @browser.type "//div[@class='place_exposure'][1]//input[contains(@id, '_date_of_exposure')]", @new_date_of_exposure
    save_cmr(@browser).should be_true
    click_core_tab(@browser, "Epidemiological")
    @browser.is_text_present(@new_place_name).should be_true
    @browser.is_text_present('Pool').should be_true
    @browser.is_text_present(@new_date_of_exposure).should be_true
    @browser.is_text_present(@date_of_exposure).should_not be_true
  end

  it "should adding a new place exposure from the CMR's edit mode" do
    edit_cmr(@browser).should be_true
    sleep(3)
    click_core_tab(@browser, "Epidemiological")
    @browser.click 'link=New Place Exposure'
    @browser.type "morbidity_event_new_place_exposure_attributes__name", 'The Stuffed Mushroom'
    @browser.select "morbidity_event_new_place_exposure_attributes__place_type_id", "label=Food Establishment"
    save_cmr(@browser).should be_true
    @browser.is_text_present(@new_place_name).should be_true
    @browser.is_text_present('Food Establishment').should be_true
    @browser.is_text_present('The Stuffed Mushroom').should be_true
  end

  it "should delete a place exposure from the CMR's edit mode" do
    edit_cmr(@browser).should be_true
    sleep(3)
    click_core_tab(@browser, "Epidemiological")
    @browser.click "//div[@class='place_exposure'][2]//a"
    save_cmr(@browser).should be_true
    @browser.is_text_present(@new_place_name).should be_true
    @browser.is_text_present('Pool').should be_true
    @browser.is_text_present('The Stuffed Mushroom').should_not be_true  
  end

  it "should allow editing a place exposure as a place event" do
    click_core_tab(@browser, "Epidemiological")
    @browser.click "link=Edit place details"
    sleep(3)
    # Address
    @browser.select "place_event_active_place__active_primary_entity__place_place_type_id", "label=Other"
    @browser.type "place_event_active_place__active_primary_entity__address_street_number", "555"
    @browser.type "place_event_active_place__active_primary_entity__address_street_name", "Main St."
    @browser.type "place_event_active_place__active_primary_entity__address_unit_number", "D"
    @browser.type "place_event_active_place__active_primary_entity__address_city", "Springfield"
    @browser.select "place_event_active_place__active_primary_entity__address_state_id", "label=Utah"
    @browser.select "place_event_active_place__active_primary_entity__address_county_id", "label=Summit"
    @browser.type "place_event_active_place__active_primary_entity__address_postal_code", "11111"
    # Phone
    @browser.select "place_event_new_telephone_attributes__entity_location_type_id", "label=Work"
    @browser.type "place_event_new_telephone_attributes__area_code", "330"
    @browser.type "place_event_new_telephone_attributes__phone_number", "5555555"
    @browser.type "place_event_new_telephone_attributes__extension", "231"
    @browser.type "place_event_new_telephone_attributes__email_address", "test@home.com"
    save_place_event(@browser).should be_true
    
    @browser.is_text_present("555").should be_true
    @browser.is_text_present("Main St.").should be_true
    @browser.is_text_present("D").should be_true
    @browser.is_text_present("Springfield").should be_true
    @browser.is_text_present("Utah").should be_true
    @browser.is_text_present("Summit").should be_true
    @browser.is_text_present("11111").should be_true
    @browser.is_text_present("Work").should be_true
    @browser.is_text_present("(330) 555-5555 Ext. 231").should be_true
    @browser.is_text_present("test@home.com").should be_true
  end
end
