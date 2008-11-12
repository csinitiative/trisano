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

 #$dont_kill_browser = true

describe 'Tab Toggling Functionality' do

  it 'should toggle New CMR tabs properly' do  
    @browser.open '/trisano/cmrs'
    click_nav_new_cmr(@browser).should be_true
    verify_tab_behavior(@browser)
  end
  
  it 'should show CMR Core tabs properly' do
    create_basic_investigatable_cmr(@browser, 'Biel', 'AIDS', 'TriCounty Health Department').should be_true
    verify_tab_behavior(@browser)
  end
  
  it 'should show Edit Place Exposure tabs properly' do
    edit_cmr(@browser).should be_true
    sleep(3)
    click_core_tab(@browser, "Epidemiological")
    @browser.type "morbidity_event_new_place_exposure_attributes__name", 'Davis Natatorium'
    @browser.select "morbidity_event_new_place_exposure_attributes__place_type_id", "label=Pool"
    save_cmr(@browser).should be_true
    #click_core_tab(@browser, "Epidemiological")
    @browser.click "link=Edit place details"
    @browser.wait_for_page_to_load($load_time)
    verify_tab_behavior(@browser)
  end
  
  it 'should show Show Place Exposure tabs properly' do
    @browser.click "link=Show"
    @browser.wait_for_page_to_load($load_time)
    verify_tab_behavior(@browser)
  end
  
  it 'should show Edit Contact Event tabs properly' do
    click_nav_new_cmr(@browser).should be_true
    @browser.type "morbidity_event_active_patient__person_last_name", "Headroom"
    @browser.type "morbidity_event_active_patient__person_first_name", "Max"
    click_core_tab(@browser, "Contacts")
    @browser.click "link=Add a contact"
    sleep(1)
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'last_name')]", "Costello"
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'first_name')]", "Lou"
    @browser.select "//div[@class='contact'][1]//select[contains(@id, 'disposition')]", "label=Unable to locate"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'last_name')]", "Abbott"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'first_name')]", "Bud"
    @browser.select "//div[@class='contact'][2]//select[contains(@id, 'entity_location_type_id')]", "label=Home"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'area_code')]", "202"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'phone_number')]", "5551212"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'extension')]", "22"
    save_cmr(@browser).should be_true
    #click_core_tab(@browser, "Contacts")
    @browser.click "edit-contact-event"
    @browser.wait_for_page_to_load($load_time)
    verify_tab_behavior(@browser)
  end
  
  it 'should show Show Contact Event tabs properly' do
    @browser.click "link=Show"
    @browser.wait_for_page_to_load($load_time)
    verify_tab_behavior(@browser)
  end
end

def verify_tab_behavior(browser)
  browser.is_visible("//span[@id='disable_tabs']").should be_true
  browser.is_visible("//ul[@id='tabs']").should be_true
  browser.is_visible("//span[@id='enable_tabs']").should be_false
  browser.click("//span[@id='disable_tabs']")
  browser.is_visible("//span[@id='disable_tabs']").should be_false
  browser.is_visible("//ul[@id='tabs']").should be_false
  browser.is_visible("//span[@id='enable_tabs']").should be_true
  browser.click("//span[@id='enable_tabs']")
  browser.is_visible("//span[@id='disable_tabs']").should be_true
  browser.is_visible("//ul[@id='tabs']").should be_true
  browser.is_visible("//span[@id='enable_tabs']").should be_false  
end
