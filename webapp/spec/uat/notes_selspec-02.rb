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

require File.dirname(__FILE__) + '/spec_helper'

 # $dont_kill_browser = true

describe 'Associating notes with an event.' do

  before(:all) do
    @note_1 = get_unique_name(5)
    @note_2 = get_unique_name(5)
    @note_3 = get_unique_name(5)
  end

  it "It should show an appropriate message for new events." do
    @browser.open "/trisano/cmrs"
    @browser.wait_for_page_to_load $load_time
    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_last_name', "Smith")
    first_reported_to_ph_date @browser, Date.today
    click_core_tab(@browser, NOTES)
    save_and_continue(@browser)

    @browser.is_element_present("id=existing-notes").should be_true
    @browser.is_text_present("Event created for jurisdiction Unassigned.").should be_true
    note_count(@browser).should == 1
  end

  it "should allow adding one clinical note" do
    enter_note(@browser, "My first clinical note.")
    save_and_continue(@browser)
    @browser.is_element_present("css=DIV#existing-notes").should be_true
    note_count(@browser).should == 2
    @browser.is_text_present("My first clinical note.").should be_true
  end

  it "should allow adding one admin note" do
    enter_note(@browser, "My first admin note.", { :is_admin => true })
    save_and_continue(@browser)
    @browser.is_element_present("css=DIV#existing-notes").should be_true
    note_count(@browser).should == 3
    @browser.is_text_present("My first admin note.").should be_true
  end

  it "should filter notes for morbidity events" do
    note_count(@browser).should eql(3)
    note_count(@browser, "Administrative").should eql(2)
    note_count(@browser, "Clinical").should eql(1)

    @browser.click("admin-notes")
    sleep(2)
    note_count(@browser).should eql(2)
    note_count(@browser, "Administrative").should eql(2)
    note_count(@browser, "Clinical").should eql(0)
    
    @browser.click("clinical-notes")
    sleep(2)
    note_count(@browser).should eql(1)
    note_count(@browser, "Administrative").should eql(0)
    note_count(@browser, "Clinical").should eql(1)
    
    @browser.click("all-notes")
    sleep(2)
    note_count(@browser).should eql(3)
    note_count(@browser, "Administrative").should eql(2)
    note_count(@browser, "Clinical").should eql(1)
  end

  it "should allow a note to be struck through" do
    @browser.click "//input[contains(@id, 'struckthrough')]"
    sleep(1)
    @browser.is_element_present("css=DIV.struck-through").should be_true
    save_and_continue(@browser)
    @browser.is_element_present("css=DIV.struck-through").should be_true
  end

  it "should work with contacts and places" do
    add_contact(@browser, { :last_name => "Jones"})
    add_place(@browser, { :name => "PS 207" })
    save_cmr(@browser)
    @browser.click "link=Edit Contact"
    @browser.wait_for_page_to_load $load_time 

    @browser.get_html_source.include?("Contact event created.").should be_true
    enter_note(@browser, "My first clinical, contact note.")
    save_and_continue(@browser)
    @browser.is_element_present("css=DIV#existing-notes").should be_true
    @browser.get_html_source.include?("My first clinical, contact note.").should be_true
    note_count(@browser).should eql(2)

    enter_note(@browser, "My first admin, contact note.", :is_admin => true)
    save_and_continue(@browser)
    @browser.is_element_present("css=DIV#existing-notes").should be_true
    @browser.get_html_source.include?("My first admin, contact note.").should be_true

    note_count(@browser).should eql(3)
    note_count(@browser, "Administrative").should eql(2)
    note_count(@browser, "Clinical").should eql(1)

    @browser.click("admin-notes")
    sleep(2)
    note_count(@browser).should eql(2)
    note_count(@browser, "Administrative").should eql(2)
    note_count(@browser, "Clinical").should eql(0)

    @browser.click("clinical-notes")
    sleep(2)
    note_count(@browser).should eql(1)
    note_count(@browser, "Administrative").should eql(0)
    note_count(@browser, "Clinical").should eql(1)

    @browser.click("all-notes")
    sleep(2)
    note_count(@browser).should eql(3)
    note_count(@browser, "Administrative").should eql(2)
    note_count(@browser, "Clinical").should eql(1)

    @browser.click("link=Smith")
    @browser.wait_for_page_to_load $load_time 
    @browser.click "link=Edit Place"
    @browser.wait_for_page_to_load $load_time

    @browser.get_html_source.include?("Place event created.").should be_true
    enter_note(@browser, "My first clinical, place note.")
    save_and_continue(@browser)
    @browser.is_element_present("css=DIV#existing-notes").should be_true
    @browser.get_html_source.include?("My first clinical, place note.").should be_true

    enter_note(@browser, "My first admin, place note.", :is_admin => true)
    save_and_continue(@browser)
    @browser.is_element_present("css=DIV#existing-notes").should be_true
    @browser.get_html_source.include?("My first admin, place note.").should be_true

    note_count(@browser).should eql(3)
    note_count(@browser, "Administrative").should eql(2)
    note_count(@browser, "Clinical").should eql(1)

    @browser.click("admin-notes")
    sleep(2)
    note_count(@browser).should eql(2)
    note_count(@browser, "Administrative").should eql(2)
    note_count(@browser, "Clinical").should eql(0)

    @browser.click("clinical-notes")
    sleep(2)
    note_count(@browser).should eql(1)
    note_count(@browser, "Administrative").should eql(0)
    note_count(@browser, "Clinical").should eql(1)

    @browser.click("all-notes")
    sleep(2)
    note_count(@browser).should eql(3)
    note_count(@browser, "Administrative").should eql(2)
    note_count(@browser, "Clinical").should eql(1)

  end
end
