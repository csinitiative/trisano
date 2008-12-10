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
    @browser.type('morbidity_event_active_patient__person_last_name', "Smith")

    click_core_tab(@browser, NOTES)
    @browser.is_text_present("New record: No existing notes.").should be_true
  end

  it "should show an appropriate message for existing events with no notes." do
    save_and_continue(@browser)

    @browser.is_element_present("id=existing-notes").should be_true
    pending 'Curently there is no indication that no prior notes exist' do
      @browser.is_text_present("New record: No existing notes.").should be_true
    end
  end

  it "should allow adding one note" do
    @browser.type "morbidity_event_new_note_attributes_note", "My first note."
    save_and_continue(@browser)

    @browser.is_element_present("css=DIV#existing-notes").should be_true
    @browser.is_text_present("My first note.").should be_true
  end

  it "should allow adding one note" do
    @browser.type "morbidity_event_new_note_attributes_note", "My second note."
    save_and_continue(@browser)

    @browser.is_element_present("css=DIV#existing-notes").should be_true
    @browser.is_text_present("My first note.").should be_true
    @browser.is_text_present("My second note.").should be_true
  end

  it "should allow a note to be struck through" do
    @browser.click "//input[contains(@id, 'struckthrough')]"
    sleep(1)
    @browser.is_element_present("css=DIV.struck-through").should be_true
    save_and_continue(@browser)
    @browser.is_element_present("css=DIV.struck-through").should be_true
  end

  it "should work with contacts and places" do
    @browser.type "morbidity_event_new_contact_attributes__last_name", "Jones" 
    @browser.type "morbidity_event_new_place_exposure_attributes__name", "PS 207"
    save_cmr(@browser)
    @browser.click "edit-contact-event"
    @browser.wait_for_page_to_load $load_time 
    @browser.is_element_present("id=existing-notes").should be_true

    pending 'Curently there is no indication that no prior notes exist' do
      @browser.is_text_present("No notes have been recorded for this event").should be_true
    end
    @browser.type "contact_event_new_note_attributes_note", "My first contact note."
    save_and_continue(@browser)
    @browser.is_element_present("css=DIV#existing-notes").should be_true
    @browser.is_text_present("My first contact note.").should be_true

    @browser.click("link=Smith")
    @browser.wait_for_page_to_load $load_time 
    @browser.click "edit-place-event"
    @browser.wait_for_page_to_load $load_time 
    @browser.is_element_present("id=existing-notes").should be_true
    pending 'Curently there is no indication that no prior notes exist' do
      @browser.is_text_present("No notes have been recorded for this event").should be_true
    end
    @browser.type "place_event_new_note_attributes_note", "My first place note."
    save_and_continue(@browser)
    @browser.is_element_present("css=DIV#existing-notes").should be_true
    @browser.is_text_present("My first place note.").should be_true
  end
end
