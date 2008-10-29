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

describe 'Sytem functionality for routing and workflow' do

  before(:all) do
    @person_1 = get_unique_name(2)
    @person_2 = get_unique_name(2)
    @person_3 = get_unique_name(2)
  end

  it "should allow for new event_queues" do
    @browser.open "/trisano/admin"
    @browser.wait_for_page_to_load "30000"
    current_user = @browser.get_selected_label("user_id")
    if current_user != "default_user"
      switch_user(@browser, "default_user")
    end

    # We need a queue first
    @browser.click "link=Event Queues"
    @browser.wait_for_page_to_load "30000"
    
    @browser.click "create_event_queue"
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

    # We need a CMR too
    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__person_last_name', @person_1)
    save_cmr(@browser).should be_true

    @browser.is_text_present("NEW CMR").should be_true
    @browser.is_text_present("Edit").should be_true
    @browser.is_text_present("Route to Local Health Depts.").should be_true
  end

  it "should allow routing to a new jurisdiction" do
    @browser.click "link=Route to Local Health Depts."
    @browser.get_selected_label('jurisdiction_id').should == "Unassigned"
    @browser.select "jurisdiction_id", "label=Central Utah"
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load "30000"
    @browser.get_selected_label('jurisdiction_id').should == "Central Utah"
  end

  it "should allow for accepting or rejecting a remote routing assignent" do
    @browser.is_checked("name=morbidity_event[event_status]").should be_false
    @browser.is_text_present("Assigned to Local Health Dept.").should be_true
  end

  it "should set event to 'accepted' when 'accept' is clicked" do
    @browser.click("name=morbidity_event[event_status]")
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
    @browser.is_checked("name=morbidity_event[event_status]").should be_false
  end

  it "should set event to 'under investigation' when 'accept' is clicked" do
    @browser.click("name=morbidity_event[event_status]")
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Under Investigation").should be_true
    @browser.is_element_present("//table[@class='listingforms']//div[@id='investigator_info']//*[text() = 'default_user']").should be_true
  end

  it "should set event to 'investigation complete' when 'mark investigation complete' is clicked" do
    @browser.click("investigation_complete_btn")
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Investigation Complete").should be_true
  end

  it "should allow for accepting or rejecting a locally completed investigation" do
    @browser.is_text_present("Reopen").should be_true
    @browser.is_text_present("Approve").should be_true
  end

  it "should set event to 'Approved by LHD' when 'accept' is clicked" do
    @browser.click("name=morbidity_event[event_status]")
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Approved by LHD").should be_true
  end

  it "should allow for accepting or rejecting a remotely completed investigation" do
    @browser.is_text_present("Reopen").should be_true
    @browser.is_text_present("Approve").should be_true
  end

  it "should set event to 'Approved by State' when 'accept' is clicked" do
    @browser.click("name=morbidity_event[event_status]")
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Approved by State").should be_true
  end

  it "should allow for secondary jurisdictions" do
    # We need another CMR 
    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__person_last_name', @person_3)
    save_cmr(@browser).should be_true

    @browser.is_text_present("NEW CMR").should be_true
    @browser.is_text_present("Edit").should be_true
    @browser.is_text_present("Route to Local Health Depts.").should be_true

    @browser.click "link=Route to Local Health Depts."
    @browser.click "Davis_County"  #On
    @browser.click "Salt_Lake_Valley"  #On
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load "30000"

    # Primary jurisdiction should be unchanged
    @browser.get_selected_label('jurisdiction_id').should == "Unassigned"

    # Status should be unchanged too
    @browser.is_text_present("New").should be_true

    # Should see new jurisdictions
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Davis County')]").should be_true
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Salt Lake Valley')]").should be_true
  end

  it "should allow for secondary jurisdictions to be added" do
    @browser.click "link=Route to Local Health Depts."
    @browser.click "Bear_River"  # On
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load "30000"
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Davis County')]").should be_true
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Salt Lake Valley')]").should be_true
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Bear River')]").should be_true
  end

  it "should allow for a subset of secondary jurisdictions to be removed" do
    @browser.click "link=Route to Local Health Depts."
    @browser.click "Davis_County"  # Off
    @browser.click "Salt_Lake_Valley"  # Off
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load "30000"
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Davis County')]").should_not be_true
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Salt Lake Valley')]").should_not be_true
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Bear River')]").should be_true
  end

  it "should allow for all secondary jurisdictions to be removed" do
    @browser.click "link=Route to Local Health Depts."
    @browser.click "Bear_River"  # Off
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load "30000"
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Davis County')]").should_not be_true
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Salt lake Valley')]").should_not be_true
    @browser.is_element_present("//table[@class='listingforms']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Bear River')]").should_not be_true
  end

  it "should not display controls for a user with entitlements in the secondary jurisdiction" do
    # Route it to bring up some action controls
    @browser.click "link=Route to Local Health Depts."
    @browser.select "jurisdiction_id", "label=Central Utah"
    @browser.click "Bear_River"   # On
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load "30000"
    @browser.get_selected_label('jurisdiction_id').should == "Central Utah"

    switch_user(@browser, "surveillance_mgr").should be_true
    @browser.is_text_present("Routing disabled").should be_true
    @browser.is_text_present("No action permitted").should be_true
  end

  it "should deny access altogether when entitlements are outside any jurisdiction." do
    switch_user(@browser, "default_user").should be_true
    @browser.click "link=Route to Local Health Depts."
    @browser.click "Bear_River"  # Off
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load "30000"
    switch_user(@browser, "surveillance_mgr")
    @browser.is_text_present("Permission denied: You do not have view privileges for this jurisdiction")
  end

  it "should allow for queues to specified" do
    @browser.open "/trisano"
    @browser.wait_for_page_to_load "30000"
    current_user = @browser.get_selected_label("user_id")
    if current_user != "default_user"
      switch_user(@browser, "default_user")
    end

    @browser.open "/trisano/admin"
    @browser.wait_for_page_to_load "30000"
    @browser.click "link=Event Queues"
    @browser.wait_for_page_to_load "30000"
    
    @browser.click "create_event_queue"
    @browser.wait_for_page_to_load "30000"

    @browser.type "event_queue_queue_name", "Joe Investigator"
    @browser.select "event_queue_jurisdiction_id", "label=Summit County Public Health Department"

    @browser.click "event_queue_submit"
    @browser.wait_for_page_to_load "30000"

    @browser.is_text_present('Event queue was successfully created.').should be_true
    @browser.is_text_present('JoeInvestigator').should be_true

    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__person_last_name', @person_2)
    save_cmr(@browser).should be_true

    @browser.open "/trisano/cmrs"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("NEW CMR").should be_true
    @browser.is_text_present("New Morbidity Report").should be_true

    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__person_last_name', get_unique_name(2))
    save_cmr(@browser).should be_true

    @browser.open "/trisano/cmrs"
    @browser.click "link=Change View"
    @browser.add_selection "queues[]", "label=Enterics-UtahCounty"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load "30000"

    @browser.is_text_present(@person_1).should be_true
    @browser.is_text_present(@person_2).should_not be_true

    @browser.click "link=Change View"
    @browser.add_selection "queues[]", "label=JoeInvestigator-SummitCounty"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load "30000"

    @browser.is_text_present(@person_1).should_not be_true
    @browser.is_text_present(@person_2).should_not be_true

    @browser.click "link=Change View"
    @browser.add_selection "states[]", "label=New"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load "30000"

    @browser.is_text_present(@person_1).should_not be_true
    @browser.is_text_present(@person_2).should be_true

    @browser.click "link=Change View"
    @browser.add_selection "states[]", "label=Assigned to Investigator"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load "30000"

    @browser.is_text_present(@person_1).should_not be_true
    @browser.is_text_present(@person_2).should_not be_true

    @browser.click "link=Change View"
    @browser.add_selection "states[]", "label=New"
    @browser.add_selection "queues[]", "label=Enterics-UtahCounty"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load "30000"

    @browser.is_text_present(@person_1).should be_true
    @browser.is_text_present(@person_2).should be_true

    @browser.click "link=Change View"
    @browser.add_selection "states[]", "label=New"
    @browser.add_selection "queues[]", "label=JoeInvestigator-SummitCounty"
    @browser.click "set_as_default_view"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load "30000"

    @browser.is_text_present(@person_1).should_not be_true
    @browser.is_text_present(@person_2).should be_true

    @browser.click "link=CMRS"
    @browser.wait_for_page_to_load "30000"

    @browser.is_text_present(@person_1).should_not be_true
    @browser.is_text_present(@person_2).should be_true
  end

end
