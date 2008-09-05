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

describe 'Sytem functionality for routing a CMR among jurisdictions' do

  it "should allow for new event_queues" do
    @browser.open "/trisano/admin"
    @browser.wait_for_page_to_load "30000"
    current_user = @browser.get_selected_label("user_id")
    if current_user != "default_user"
      switch_user(@browser, "default_user")
    end

    @browser.click "link=Event Queues"
    @browser.wait_for_page_to_load "30000"
    
    @browser.click "link=New event queue"
    @browser.wait_for_page_to_load "30000"

    @browser.type "event_queue_queue_name", "Enterics"
    @browser.select "event_queue_jurisdiction_id", "label=Utah County Health Department"

    @browser.click "event_queue_submit"
    @browser.wait_for_page_to_load "30000"

    @browser.is_text_present('Event queue was successfully created.').should be_true
    @browser.is_text_present('Enterics').should be_true
    @browser.is_text_present('Utah County Health Department').should be_true
  end

  it "should present all controls" do
    @browser.open "/trisano/cmrs"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("NEW CMR").should be_true
    @browser.is_text_present("New Morbidity Report").should be_true

    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', get_unique_name(2))
    save_cmr(@browser).should be_true

    @browser.is_text_present("NEW CMR").should be_true
    @browser.is_text_present("Edit").should be_true
    @browser.is_text_present("Route remotely to:").should be_true
  end

  it "should create new CMRs in the unassigned jurisdiction" do
    @browser.get_selected_label('jurisdiction_id').should == "Unassigned"
  end

  it "should allow routing to a new jurisdiction" do
    @browser.select "jurisdiction_id", "label=Bear River"
    @browser.wait_for_page_to_load "30000"
    @browser.get_selected_label('jurisdiction_id').should == "Bear River"
  end

  it "should allow for accepting or rejecting a remote routing assignent" do
    @browser.is_checked("name=morbidity_event[event_status_id]").should be_false
    @browser.is_text_present("Assigned to Local Health Dept.").should be_true
  end

  it "should set event to 'accepted' when 'accept' is clicked" do
    @browser.click("name=morbidity_event[event_status_id]")
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Accepted by Local Health Dept.").should be_true
  end

  it "should allow routing to an investigator queue" do
    @browser.is_text_present('Route locally to:').should be_true
    @browser.select "morbidity_event__event_queue_id", "label=Enterics-UtahCounty"
    @browser.wait_for_page_to_load "30000"
  end

  it "should allow for accepting or rejecting a local routing assignent" do
    @browser.is_text_present('Queue:  Enterics-UtahCounty').should be_true
    @browser.is_checked("name=morbidity_event[event_status_id]").should be_false
  end

  it "should set event to 'under investigation' when 'accept' is clicked" do
    @browser.click("name=morbidity_event[event_status_id]")
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Under Investigation").should be_true
  end

  it "should set event to 'investigation complete' when 'mark investigation complete' is clicked" do
    @browser.click("investigation_complete_btn")
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Investigation Complete").should be_true
  end

  it "should allow for accepting or rejecting a completed investigation" do
    @browser.is_text_present("Reopen").should be_true
    @browser.is_text_present("Approve").should be_true
  end

  it "should set event to 'Approved by LHD' when 'accept' is clicked" do
    @browser.click("name=morbidity_event[event_status_id]")
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Approved by LHD").should be_true
  end

  it "should not display routing controls for a less privileged user" do
    switch_user(@browser, "lhd_manager").should be_true

    @browser.is_text_present("Assigned Jurisdiction: Unassigned").should_not be_true
  end

end
