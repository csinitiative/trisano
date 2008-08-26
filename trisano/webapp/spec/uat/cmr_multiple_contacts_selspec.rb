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

describe 'Adding multiple contacts to a CMR' do
  
  it "should allow adding new contacts to a new CMR" do
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser)
    @browser.type "morbidity_event_active_patient__active_primary_entity__person_last_name", "Headroom"
    @browser.type "morbidity_event_active_patient__active_primary_entity__person_first_name", "Max"

    click_core_tab(@browser, "Contacts")
    @browser.click "link=Add a contact"
    sleep(1)
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'last_name')]", "Costello"
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'first_name')]", "Lou"
    @browser.select "//div[@class='contact'][1]//select[contains(@id, 'disposition')]", "label=Unable to Locate"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'last_name')]", "Abbott"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'first_name')]", "Bud"

    save_cmr(@browser).should be_true

    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present('Costello').should be_true
    @browser.is_text_present('Lou').should be_true
    @browser.is_text_present('Unable to Locate').should be_true
    @browser.is_text_present('Abbott').should be_true
    @browser.is_text_present('Bud').should be_true
  end

  it "should allow removing a contact" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Contacts")
    @browser.click "remove_contact_link"
    save_cmr(@browser).should be_true
    @browser.is_text_present('Costello').should_not be_true
  end

  it "should allow editing a contact" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Contacts")
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'first_name')]", "William"
    @browser.select "//div[@class='contact'][1]//select[contains(@id, 'disposition')]", "label=Not Infected"   
    save_cmr(@browser).should be_true
    @browser.is_text_present('William').should be_true
    @browser.is_text_present('Not Infected')
  end

  it "should allow for editing a contact event" do
    # Kill three birds by editing the second contact created during an edit of the morbidity event.
    edit_cmr(@browser)
    click_core_tab(@browser, "Contacts")
    @browser.click "link=Add a contact"
    sleep(1)
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'last_name')]", "Laurel"
    save_cmr(@browser).should be_true
    click_core_tab(@browser, "Contacts")
    @browser.is_text_present('Laurel').should be_true
    @browser.click "//div[@id='contacts_tab']//table/tbody/tr[3]//a"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "contact_event_active_patient__active_primary_entity__person_first_name", "Oliver"
    @browser.type "contact_event_active_patient__active_primary_entity__address_street_number", "333"
    @browser.type "contact_event_active_patient__active_primary_entity__address_street_name", "33rd Street"
    click_core_tab(@browser, "Laboratory")
    @browser.click "link=Add a lab result"
    @browser.type "name=contact_event[new_lab_attributes][][name]", "Abbott Labs"
    @browser.type "name=contact_event[new_lab_attributes][][lab_result_text]", "Positive"
    save_contact_event(@browser).should be_true
    @browser.is_text_present('Oliver').should be_true
    @browser.is_text_present('333').should be_true
    @browser.is_text_present('33rd Street').should be_true
    @browser.is_text_present('Abbott Labs').should be_true
    @browser.is_text_present('Positive').should be_true
  end

end
