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

 # $dont_kill_browser = true

describe 'Soft deleting events' do
  
  before(:all) do
    @cmr_last_name = get_unique_name(1) + " sd-uat"
    @contact_last_name = get_unique_name(1) + " sd-uat"
    @place_name = get_unique_name(1) + " sd-uat"
  end

  after(:all) do
    @cmr_last_name = nil
    @contact_last_name = nil
    @place_name = nil
  end
  
  it "should create a CMR with a contact and a place" do
    @browser.open "/trisano/cmrs"
    click_nav_new_cmr(@browser)
    @browser.type "morbidity_event_active_patient__person_last_name", @cmr_last_name

    click_core_tab(@browser, "Contacts")
    @browser.type "//div[@class='contact'][1]//input[contains(@id, 'last_name')]", @contact_last_name
    @browser.type "morbidity_event_new_place_exposure_attributes__name", @place_name
    save_cmr(@browser).should be_true

    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present(@cmr_last_name).should be_true
    @browser.is_text_present(@contact_last_name).should be_true
    @browser.is_text_present(@place_name).should be_true
  end
  
  it "should should soft delete the morbidity event" do
    @browser.click("soft-delete")
    @browser.get_confirmation()   
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("The event was successfully marked as deleted.").should be_true
    @browser.get_eval(%Q{selenium.browserbot.getCurrentWindow().$$('div.patientname-inactive')[0].getStyle('color') == "rgb(204, 204, 204)"}).should eql("true")
  end
  
  it "should should have soft deleted the contact event" do
    @browser.click("link=Edit contact event")
    @browser.wait_for_page_to_load($load_time)
    @browser.click("link=Show")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_eval(%Q{selenium.browserbot.getCurrentWindow().$$('div.contactname-inactive')[0].getStyle('color') == "rgb(204, 204, 204)"}).should eql("true")
    @browser.is_text_present("Delete").should be_false
  end

  it "should should have soft deleted the place event" do
    @browser.click("link=#{@cmr_last_name}")
    @browser.wait_for_page_to_load($load_time)
    @browser.click("link=Edit place details")
    @browser.wait_for_page_to_load($load_time)
    @browser.click("link=Show")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_eval(%Q{selenium.browserbot.getCurrentWindow().$$('div.placename-inactive')[0].getStyle('color') == "rgb(204, 204, 204)"}).should eql("true")
    @browser.is_text_present("Delete").should be_false
  end

  it "should search for deleted events" do
    navigate_to_cmr_search(@browser)
    @browser.type("name", @cmr_last_name)
    @browser.click("//input[@type='submit']")
    @browser.wait_for_page_to_load($load_time)
  end

  it "should find at least one deleted event, which should be grey" do
    @browser.get_eval(%Q{selenium.browserbot.getCurrentWindow().$$('tr.search-inactive')[0].childNodes[1].getStyle('color') == "rgb(25, 25, 112)"}).should eql("true")
  end

  it "should search for deleted people" do
    navigate_to_people_search(@browser)
    @browser.type("name", @cmr_last_name)
    @browser.click("//input[@type='submit']")
    @browser.wait_for_page_to_load($load_time)
  end

  it "should find at least one deleted person, which should be grey" do
    @browser.get_eval(%Q{selenium.browserbot.getCurrentWindow().$$('tr.search-inactive')[0].childNodes[1].getStyle('color') == "rgb(25, 25, 112)"}).should eql("true")
  end
end
