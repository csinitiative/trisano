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

describe 'User functionality for searching for existing users' do

  before(:all) do
    @name = (get_unique_name(1))[0..18]
  end

  it 'should find or add Charles Chuckles in Provo, Utah county' do
    @browser.open "/trisano/cmrs"
    click_nav_cmrs(@browser).should be_true
    if !@browser.is_text_present('Chuckles')
      click_nav_new_cmr(@browser).should be_true
      @browser.type('morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_last_name', 'Chuckles')
      @browser.type('morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_first_name', 'Charles')
      @browser.type('morbidity_event_address_attributes_city', 'Provo')
      @browser.select('morbidity_event_address_attributes_state_id', 'label=Utah')
      @browser.select('morbidity_event_address_attributes_county_id', 'label=Utah')
      @browser.type('morbidity_event_address_attributes_postal_code', '84602')

      click_core_tab(@browser, "Contacts")
      @browser.type "//div[@class='contact'][1]//input[contains(@id, 'last_name')]", "Laurel"
      @browser.type "//div[@class='contact'][1]//input[contains(@id, 'first_name')]", "Charles"
      
      # uncomment when the reporting tab is restored.
      # click_core_tab(@browser, "Reporting")
      # @browser.type "morbidity_event_active_reporting_agency_last_name", "Hardy"
      # @browser.type "morbidity_event_active_reporting_agency_first_name", "Charles"
      save_cmr(@browser).should be_true
    end
  end

  it 'should find a person named Charles Chuckles when searching by Chuckles' do
    navigate_to_people_search(@browser).should be_true
    @browser.type('name', 'Chuckles')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time) 
    @browser.is_text_present('Charles Chuckles').should be_true
  end
  
  it 'should find three people named Charles and display the relevant event type' do
    navigate_to_people_search(@browser).should be_true
    @browser.type('name', 'Charles')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time) 
    @browser.is_text_present('Charles Chuckles (Morbidity event)').should be_true
    @browser.is_text_present('Charles Laurel (Contact event)').should be_true
    # uncomment when reporting tab is resptored
    # @browser.is_text_present('Charles Hardy (No associated event)').should be_true
  end

  it 'should find a person named Charles Chuckles when searching by Charlie Chuckles' do
    navigate_to_cmr_search(@browser).should be_true
    @browser.type('name', 'Charlie Chuckles') 
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
  end
  
  it 'should find a person named Charles Chuckles when searching by Charles' do
    @browser.type('name', 'Charles')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
  end
  
  it 'should not find anyone when searching by Charlie Chuckface' do
    @browser.type('name', 'Charlie Chuckface')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Your search returned no results.').should be_true
  end
    
  it 'should not find anyone when searching by Charlie' do
    @browser.type('name', 'Charlie')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Your search returned no results.').should be_true
  end
  
  it 'should find a person named Charles Chuckles when searching by Chuckles' do
    @browser.type('name', 'Chuckles')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
  end
  
  it 'should not find anyone when searching by first name chu' do
    @browser.type('name', '')
    @browser.type 'sw_first_name', 'chu'
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Your search returned no results.').should be_true
  end
  
  it 'should find a person named Charles Chuckles when searching by last name chu' do
    @browser.type('sw_first_name', '')
    @browser.type('sw_last_name', 'chu')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
  end
  
  it 'Charles Chuckles should be assigned to Unassigned jurisdiction' do
    @browser.type('sw_last_name', '')
    @browser.is_text_present('Unassigned').should be_true
  end

  it 'should find Charles Chuckles when searching by Unassigned jurisdiction' do
    @browser.select("//select[@name='jurisdiction_id']", 'label=Unassigned')
    @browser.click('//input[@type=\'submit\']')
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
    @browser.is_text_present('Unassigned').should be_true
  end

  it 'should find Charles and present export as csv link' do
    navigate_to_cmr_search(@browser).should be_true
    @browser.type('name', 'Charles')
    @browser.click("//input[@type='submit']")
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
    @browser.is_text_present('Export All to CSV').should be_true
  end

  it "should find charles chuckles when searching for morbidity events" do
    navigate_to_cmr_search(@browser).should be_true
    @browser.select "event_type", "label=Morbidity Event (CMR)"
    @browser.click("//input[@type='submit']")
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
  end

  it "should find charles laurel when searchin for contact events" do
    navigate_to_cmr_search(@browser).should be_true
    @browser.select "event_type", "label=Contact Event"
    @browser.click("//input[@type='submit']")
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Laurel').should be_true
  end

  it "should find charles laurel and charles chuckles when searchin not specifying an event type" do
    navigate_to_cmr_search(@browser).should be_true
    @browser.type('name', 'Charles')
    @browser.click("//input[@type='submit']")
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present('Charles Chuckles').should be_true
    @browser.is_text_present('Charles Laurel').should be_true
  end

  it "should create a cmr and route it to Davis County HD with Utah County HD as a secondary jurisdiction" do
    @browser.open "/trisano/cmrs"
    create_basic_investigatable_cmr(@browser, @name, "Pertussis", "Davis County Health Department")
    @browser.click "link=Route to Local Health Depts."
    @browser.click "Utah_County"
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Davis County").should be_true
    @browser.is_text_present("Utah County").should be_true
end

  it "should always display the primary jurisdiction in search results" do
    navigate_to_cmr_search(@browser).should be_true
    @browser.type('name', @name)
    @browser.check "Pertussis"
    @browser.click "//input[@type='submit']"
    @browser.wait_for_page_to_load "30000"
    @browser.get_text("//div[@id='main-content']/div[1]/table/tbody/tr[2]/td[8]").should == "Davis County Health Department"
  end

  it "should find the cmr searching on the primary jurisdiction" do
    @browser.select "//select[@name='jurisdiction_id']", "label=Davis County Health Department"
    @browser.click "//input[@type='submit']"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present(@name).should be_true
  end

  it "should find the cmr searching on the secondary jurisdiction" do
    @browser.select "//select[@name='jurisdiction_id']", "label=Utah County Health Department"
    @browser.click "//input[@type='submit']"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present(@name).should be_true
  end
end
