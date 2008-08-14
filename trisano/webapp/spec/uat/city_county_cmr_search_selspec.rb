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
  
  describe 'User functionality for searching for CMRs by city and county' do
    before(:all) do
      @browser.open "/trisano/"
      click_nav_forms(@browser)
    end
    
    it 'should find or add Chuckles in Provo, Utah county' do
      if !@browser.is_text_present('chuckles')
        click_nav_new_cmr(@browser).should be_true
        @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', 'chuckles')
        @browser.type('morbidity_event_active_patient__active_primary_entity__address_city', 'Provo')
        @browser.select('morbidity_event_active_patient__active_primary_entity__address_state_id', 'label=Utah')
        @browser.select('morbidity_event_active_patient__active_primary_entity__address_county_id', 'label=Utah')
        @browser.type('morbidity_event_active_patient__active_primary_entity__address_postal_code', '84602')
        save_cmr(@browser).should be_true
      end
    end
  
    it 'should find or add Joker in Orem, Utah county' do
      click_nav_cmrs(@browser).should be_true
      if !@browser.is_text_present('Joker')
        click_nav_new_cmr(@browser).should be_true
        @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', 'Joker')
        @browser.type('morbidity_event_active_patient__active_primary_entity__address_city', 'Orem')
        @browser.select('morbidity_event_active_patient__active_primary_entity__address_state_id', 'label=Utah')
        @browser.select('morbidity_event_active_patient__active_primary_entity__address_county_id', 'label=Utah')
        @browser.type('morbidity_event_active_patient__active_primary_entity__address_postal_code', '84606')
        save_cmr(@browser).should be_true
      end
    end
    
    it 'should find or add Papa Smurf in Provo, Utah county' do
      click_nav_cmrs(@browser).should be_true
      if !@browser.is_text_present('Smurf, Papa')
        click_nav_new_cmr(@browser).should be_true
        @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', 'Smurf')
        @browser.type('morbidity_event_active_patient__active_primary_entity__person_first_name', 'Papa')
        @browser.type('morbidity_event_active_patient__active_primary_entity__address_city', 'Provo')
        @browser.select('morbidity_event_active_patient__active_primary_entity__address_state_id', 'label=Utah')
        @browser.select('morbidity_event_active_patient__active_primary_entity__address_county_id', 'label=Utah')
        @browser.type('morbidity_event_active_patient__active_primary_entity__address_postal_code', '84602')
        save_cmr(@browser).should be_true
      end
    end
    
    it 'should find or add Gidget in Provo, Utah county' do  
      click_nav_cmrs(@browser).should be_true
      if !@browser.is_text_present('Gidget')
        click_nav_new_cmr(@browser).should be_true
        @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', 'Gidget')
        @browser.type('morbidity_event_active_patient__active_primary_entity__address_city', 'Orem')
        @browser.select('morbidity_event_active_patient__active_primary_entity__address_state_id', 'label=Utah')
        @browser.select('morbidity_event_active_patient__active_primary_entity__address_county_id', 'label=Utah')
        @browser.type('morbidity_event_active_patient__active_primary_entity__address_postal_code', '84606')
        save_cmr(@browser).should be_true
      end
    end
   
    it 'should find chuckles and Papa Smurf and not Joker or Gidget when it searches in city = Provo' do
      navigate_to_cmr_search(@browser).should be_true
      @browser.type('name=city', 'Provo')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('chuckles').should be_true
      @browser.is_text_present('Papa Smurf').should be_true
    end
   
    it 'should find Joker and Gidget and not chuckles or Papa Smurf when it searches in city = Orem' do
      pending("appears to be some dependency between tests? Passes with a clean db, but not in grid")
      navigate_to_cmr_search(@browser).should be_true
      @browser.type('name=city', 'Orem')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Joker').should be_true
      @browser.is_text_present('Gidget').should be_true
      @browser.is_text_present('chuckles').should be_false
      @browser.is_text_present('Smurf, Papa').should be_false
    end
   
    it 'should find chuckles, Joker, Gidget, and Papa Smurf when it searches in county = Utah' do
      pending("appears to be some dependency between tests? Passes with a clean db, but not in grid")
      navigate_to_cmr_search(@browser).should be_true
      @browser.type('name=city', '')
      @browser.select('county', 'label=Utah')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('chuckles').should be_true
      @browser.is_text_present('Joker').should be_true
      @browser.is_text_present('Papa Smurf').should be_true
      @browser.is_text_present('Gidget').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfette, or Papa Smurf when it searches in city = Weber' do
      navigate_to_cmr_search(@browser).should be_true
      @browser.type('name=city', 'Weber')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Your search returned no results.').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfett, or Papa Smurf when it searches in city = Brigham City' do
      navigate_to_cmr_search(@browser).should be_true
      @browser.type('name=city', 'Brigham City')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Your search returned no results.').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfett, or Papa Smurf when it searches in city = Manti' do
      navigate_to_cmr_search(@browser).should be_true
      @browser.type('name=city', 'Manti')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Your search returned no results.').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfett, or Papa Smurf when it searches in city = Delta' do
      navigate_to_cmr_search(@browser).should be_true
      @browser.type('name=city', 'Delta')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Your search returned no results.').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfett, or Papa Smurf when it searches in county = Daggett' do
      navigate_to_cmr_search(@browser).should be_true
      @browser.type('name=city', '')
      @browser.select('county', 'label=Daggett')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Your search returned no results.').should be_true
    end
    
    it 'should not find chuckles, Joker, Smurfett, or Papa Smurf when it searches in county = Garfield' do
      navigate_to_cmr_search(@browser).should be_true
      @browser.select('county', 'label=Garfield')
      @browser.click('//input[@type=\'submit\']')
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present('Your search returned no results.').should be_true
    end
end
