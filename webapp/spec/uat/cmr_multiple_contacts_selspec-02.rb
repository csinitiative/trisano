# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

# $dont_kill_browser = true

describe 'Adding multiple contacts to a CMR' do

  it "should allow adding new contacts to a new CMR" do
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser)
    @browser.type "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_last_name", "Headroom"
    @browser.type "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_first_name", "Max"

    click_core_tab(@browser, "Contacts")
    @browser.click "link=Add a contact"
    sleep(1)
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'last_name')]", "Costello"
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'first_name')]", "Lou"
    @browser.select "//div[@class='contact'][1]//select[contains(@id, 'disposition')]", "label=Unable to locate"
    @browser.select "//div[@class='contact'][1]//select[contains(@id, 'contact_type')]", "label=Sexual"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'last_name')]", "Abbott"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'first_name')]", "Bud"
    @browser.select "//div[@class='contact'][2]//select[contains(@id, 'entity_location_type_id')]", "label=Home"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'area_code')]", "202"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'phone_number')]", "5551212"
    @browser.type "//div[@class='contact'][2]//input[contains(@id, 'extension')]", "22"

    first_reported_to_ph_date @browser, Date.today

    save_cmr(@browser).should be_true

    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present('Costello').should be_true
    @browser.is_text_present('Lou').should be_true
    @browser.is_text_present('Unable to locate').should be_true
    @browser.is_text_present('Sexual').should be_true
    @browser.is_text_present('Abbott').should be_true
    @browser.is_text_present('Bud').should be_true
    @browser.is_text_present('(202) 555-1212 Ext. 22').should be_true
  end

  it "should allow removing a contact" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Contacts")
    @browser.check "//div[@id='contacts_tab']//input[contains(@id, '_destroy')]"
    save_cmr(@browser).should be_true
    @browser.is_element_present("css=TD.struck-through").should be_true
  end

  it "should allow editing a contact" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Contacts")
    @browser.select "//div[@class='contact'][1]//select[contains(@id, 'disposition')]", "label=Not infected"
    @browser.select "//div[@class='contact'][1]//select[contains(@id, 'contact_type')]", "label=Household"
    save_cmr(@browser).should be_true
    @browser.is_text_present('Not infected')
    @browser.is_text_present('Household')
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
    @browser.click "//tr[3]//a[contains(text(), 'Edit')]"
    @browser.wait_for_page_to_load($load_time)
    @browser.select "contact_event_participations_contact_attributes_disposition_id", "label=Infected, brought to treatment"
    @browser.select "contact_event_participations_contact_attributes_contact_type_id", "label=First Responder"
    click_core_tab(@browser, "Laboratory")
    @browser.click "link=Add a new lab"
    @browser.type "//div[@id='labs']/div[@class='lab'][1]//input[contains(@name, 'name')]", "Abbott Labs"
    @browser.select "//select[contains(@id, 'test_type')]", "label=Acid fast stain"
    @browser.select "//select[contains(@id, 'test_result')]", "label=Positive / Reactive"
    save_contact_event(@browser).should be_true
    @browser.is_text_present('Abbott Labs').should be_true
    @browser.is_text_present('Positive').should be_true
    @browser.is_text_present('Infected, brought to treatment').should be_true
    @browser.is_text_present('First Responder').should be_true
  end

end
