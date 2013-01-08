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

describe 'Encounter event notes' do

  # $dont_kill_browser = true

  before(:all) do
    @cmr_last_name = get_random_word << " encounter-uat"
    @date = "March 10, 2009"
    @description = get_unique_name(3) << " encounter-uat"
    @admin_note = get_unique_name(3) << " encounter-uat"
    @clinical_note = get_unique_name(3) << " encounter-uat"
  end

  after(:all) do
    @cmr_last_name = nil
    @date = nil
    @description = nil
    @admin_note = nil
    @clinical_note = nil
  end

  it "should create a basic CMR" do
    @browser.open "/trisano/cmrs"
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it 'should add an encounter' do
    edit_cmr(@browser)
    @browser.type('css=input[id$=participations_encounter_attributes_encounter_date]', @date)
    @browser.type('css=textarea[id$=participations_encounter_attributes_description]', @description)
    save_cmr(@browser)
    @browser.get_html_source.include?("2009-03-10").should be_true
    @browser.get_html_source.include?(@description).should be_true
  end

  it 'should add an admin note and a clinical note to the encounter' do
    @browser.click("link=Edit Encounter")
    @browser.wait_for_page_to_load($load_time)

    enter_note(@browser, @admin_note, { :is_admin => true })
    save_and_continue(@browser)
    enter_note(@browser, @clinical_note)
    save_and_continue(@browser)

    @browser.get_html_source.include?(@admin_note).should be_true
    @browser.get_html_source.include?(@clinical_note).should be_true
  end

  it "should filter notes for encounter events in edit mode" do
    note_count(@browser).should eql(6)
    note_count(@browser, "Administrative").should eql(5)
    note_count(@browser, "Clinical").should eql(1)

    @browser.click("admin-notes")
    sleep(2)
    note_count(@browser).should eql(5)
    note_count(@browser, "Administrative").should eql(5)
    note_count(@browser, "Clinical").should eql(0)

    @browser.click("clinical-notes")
    sleep(2)
    note_count(@browser).should eql(1)
    note_count(@browser, "Administrative").should eql(0)
    note_count(@browser, "Clinical").should eql(1)

    @browser.click("all-notes")
    sleep(2)
    note_count(@browser).should eql(6)
    note_count(@browser, "Administrative").should eql(5)
    note_count(@browser, "Clinical").should eql(1)
  end

  it "should filter notes for encounter events in show mode" do
    save_and_exit(@browser)

    note_count(@browser).should eql(7)
    note_count(@browser, "Administrative").should eql(6)
    note_count(@browser, "Clinical").should eql(1)

    @browser.click("admin-notes")
    sleep(2)
    note_count(@browser).should eql(6)
    note_count(@browser, "Administrative").should eql(6)
    note_count(@browser, "Clinical").should eql(0)

    @browser.click("clinical-notes")
    sleep(2)
    note_count(@browser).should eql(1)
    note_count(@browser, "Administrative").should eql(0)
    note_count(@browser, "Clinical").should eql(1)

    @browser.click("all-notes")
    sleep(2)
    note_count(@browser).should eql(7)
    note_count(@browser, "Administrative").should eql(6)
    note_count(@browser, "Clinical").should eql(1)
  end

  it "should aggregate notes on the parent morbidity event's show mode" do
    @browser.click("link=#{@cmr_last_name}")
    @browser.wait_for_page_to_load($load_time)
    # With the two morb notes and four encounter notes, we should have six on the morb event
    note_count(@browser).should eql(9)
  end

end
