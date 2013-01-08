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

describe 'Sytem functionality for routing and workflow' do

  before(:all) do
    @person_1 = get_unique_name(2)
    @person_2 = get_unique_name(2)
    @person_3 = get_unique_name(2)
    @uid = get_unique_name(1)+get_unique_name(1)
    @uname = get_unique_name(2)
  end

  it "should allow for new event_queues" do
    @browser.open "/trisano/admin"
    @browser.wait_for_page_to_load $load_time
    current_user = @browser.get_selected_label("user_id")
    if current_user != "default_user"
      switch_user(@browser, "default_user")
    end

    # We need a queue first
    @browser.click "admin_queues"
    @browser.wait_for_page_to_load $load_time

    @browser.click "create_event_queue"
    @browser.wait_for_page_to_load $load_time

    @browser.type "event_queue_queue_name", "Enterics"
    @browser.select "event_queue_jurisdiction_id", "label=Utah County Health Department"

    @browser.click "event_queue_submit"
    @browser.wait_for_page_to_load $load_time

    @browser.is_text_present('Event queue was successfully created.').should be_true
    @browser.is_text_present('Enterics').should be_true
    @browser.is_text_present('Utah County Health Department').should be_true
  end

  it "create a new morbidity event" do
    click_nav_new_cmr(@browser).should be_true
    add_demographic_info(@browser, {  :last_name => @person_1})
    first_reported_to_ph_date @browser, Date.today
    save_cmr(@browser).should be_true
  end

  it "should allow routing to a new jurisdiction with a note" do
    @browser.click "link=Route to Local Health Depts."
    @browser.get_selected_label('jurisdiction_id').should == "Unassigned"
    @browser.select "jurisdiction_id", "label=Central Utah"
    @browser.type "note", "Routing is cool!"
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load($load_time)
    @browser.get_selected_label('jurisdiction_id').should == "Central Utah"
    @browser.is_text_present("Event successfully routed.").should be_true
    @browser.get_html_source.include?("Routing is cool!").should be_true
  end

  it "should allow for accepting or rejecting a remote routing assignent" do
    @browser.is_checked("name=morbidity_event[workflow_action]").should be_false
    @browser.get_html_source.include?("Assigned to Local Health Dept.").should be_true
  end

  it "should set event to 'accepted' when 'accept' is clicked and add note" do
    @browser.type("morbidity_event[note]", "This is a note.")
    @browser.click("accept_accept")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Accepted by Local Health Dept.").should be_true
    @browser.get_html_source.include?("Accepted by Central Utah Public Health Department.").should be_true
    @browser.get_html_source.include?("This is a note.").should be_true
  end

  it "should allow routing to an investigator queue" do
    @browser.get_html_source.include?('Assign to queue:').should be_true
    @browser.select "morbidity_event__event_queue_id", "label=Enterics-UtahCounty"
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Event successfully routed").should be_true
  end

  it "should allow for accepting or rejecting a local routing assignent" do
    @browser.get_html_source.include?('<b>Enterics-UtahCounty</b>').should be_true
    @browser.is_checked("name=morbidity_event[workflow_action]").should be_false
  end

  it "should set event to 'under investigation' when 'accept' is clicked" do
    @browser.click("accept_accept")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Under Investigation").should be_true
    @browser.is_element_present("//table[@class='list']//div[@id='investigator_info']//*[text() = 'default_user']").should be_true
    @browser.get_html_source.include?("Event successfully routed").should be_true
  end

  it "should set event to 'investigation complete' when 'mark investigation complete' is clicked" do
    @browser.click("investigation_complete_btn")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Investigation Complete").should be_true
    @browser.get_html_source.include?("Completed investigation.").should be_true
  end

  it "should allow for accepting or rejecting a locally completed investigation" do
    @browser.get_html_source.include?("Reopen").should be_true
    @browser.get_html_source.include?("Approve").should be_true
  end

  it "should set event to 'Approved by LHD' when 'accept' is clicked" do
    @browser.click("approve_approve")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Approved by Local Health Dept.").should be_true
    @browser.get_html_source.include?("Event successfully routed").should be_true
  end

  it "should allow for accepting or rejecting a remotely completed investigation" do
    @browser.get_html_source.include?("Reopen").should be_true
    @browser.get_html_source.include?("Approve").should be_true
  end

  it "should set event to 'Approved by State' when 'accept' is clicked" do
    @browser.click("approve_approve")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Approved by State").should be_true
  end

  it "should allow for secondary jurisdictions" do
    click_nav_new_cmr(@browser).should be_true
    add_demographic_info(@browser, {  :last_name => @person_3})
    first_reported_to_ph_date @browser, Date.today
    save_cmr(@browser).should be_true

    @browser.click "link=Route to Local Health Depts."
    @browser.click "Davis_County"  #On
    @browser.click "Salt_Lake_Valley"  #On
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load($load_time)

    # Primary jurisdiction should be unchanged
    @browser.get_selected_label('jurisdiction_id').should == "Unassigned"

    # Status should be unchanged too
    @browser.get_html_source.include?("New").should be_true

    # Should see new jurisdictions
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Davis County')]").should be_true
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Salt Lake Valley')]").should be_true
  end

  it "should allow for secondary jurisdictions to be added" do
    @browser.click "link=Route to Local Health Depts."
    @browser.click "Bear_River"  # On
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Davis County')]").should be_true
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Salt Lake Valley')]").should be_true
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Bear River')]").should be_true
  end

  it "should allow for a subset of secondary jurisdictions to be removed" do
    @browser.click "link=Route to Local Health Depts."
    @browser.click "Davis_County"  # Off
    @browser.click "Salt_Lake_Valley"  # Off
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Davis County')]").should_not be_true
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Salt Lake Valley')]").should_not be_true
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Bear River')]").should be_true
  end

  it "should allow for all secondary jurisdictions to be removed" do
    @browser.click "link=Route to Local Health Depts."
    @browser.click "Bear_River"  # Off
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Davis County')]").should_not be_true
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Salt lake Valley')]").should_not be_true
    @browser.is_element_present("//table[@class='list']//div[@id='secondary_jurisdictions']//small[contains(text(), 'Bear River')]").should_not be_true
  end

  it "should not display controls for a user with entitlements in the secondary jurisdiction" do
    # Route it to bring up some action controls
    @browser.click "link=Route to Local Health Depts."
    @browser.select "jurisdiction_id", "label=Central Utah"
    @browser.click "Bear_River"   # On
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load($load_time)
    @browser.get_selected_label('jurisdiction_id').should == "Central Utah"

    switch_user(@browser, "surveillance_mgr").should be_true
    @browser.get_html_source.include?("Routing disabled").should be_true
    @browser.get_html_source.include?("Insufficient privileges to transition this event").should be_true
  end

  it "should deny access altogether when entitlements are outside any jurisdiction." do
    switch_user(@browser, "default_user").should be_true
    @browser.click "link=Route to Local Health Depts."
    @browser.click "Bear_River"  # Off
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load($load_time)
    switch_user(@browser, "surveillance_mgr")
    @browser.is_text_present("You have accessed an out-of-jurisdiction event.").should be_true
  end

  it 'should allow creating a new investigator' do
    switch_user(@browser, "default_user").should be_true
    navigate_to_user_admin(@browser)
    @browser.click "//input[@value='Create New User']"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "user_uid", @uid
    @browser.type "user_user_name", @uname
    add_role(@browser, { :role => "Investigator", :jurisdiction => "Central Utah Public Health Department"})
    @browser.click "user_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?('User was successfully created.').should be_true
    @browser.get_html_source.include?(@uid).should be_true
    @browser.get_html_source.include?(@uname).should be_true
    @browser.get_html_source.include?("Investigator").should be_true
    @browser.get_html_source.include?("Central Utah Public Health Department").should be_true
  end

  it 'should be able to route a cmr to an individual investigator' do
    click_nav_new_cmr(@browser).should be_true
    add_demographic_info(@browser, {  :last_name => @person_1})
    first_reported_to_ph_date @browser, Date.today
    save_cmr(@browser).should be_true

    @browser.click "link=Route to Local Health Depts."
    @browser.select "jurisdiction_id", "label=Central Utah"
    @browser.click "Bear_River"   # On
    @browser.click "route_event_btn"
    @browser.wait_for_page_to_load($load_time)
    @browser.get_selected_label('jurisdiction_id').should == "Central Utah"

    @browser.click("accept_accept")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Accepted by Local Health Dept.").should be_true

    @browser.get_html_source.include?('Assign to investigator:').should be_true
    @browser.select "morbidity_event__investigator_id", "label=#{@uname}"
    @browser.wait_for_page_to_load($load_time)

    @browser.get_html_source.include?("Event successfully routed").should be_true

    @browser.get_html_source.include?("Assign to queue").should be_true
    @browser.get_html_source.include?("Assigned to Investigator").should be_true
  end

  it "should allow for filtering the view" do
    current_user = @browser.get_selected_label("user_id")
    if current_user != "default_user"
      switch_user(@browser, "default_user")
    end

    # By Queue
    @browser.open "/trisano/admin"
    @browser.wait_for_page_to_load($load_time)
    @browser.click "admin_queues"
    @browser.wait_for_page_to_load($load_time)

    @browser.click "create_event_queue"
    @browser.wait_for_page_to_load($load_time)

    @browser.type "event_queue_queue_name", "Joe Investigator"
    @browser.select "event_queue_jurisdiction_id", "label=Summit County Public Health Department"

    @browser.click "event_queue_submit"
    @browser.wait_for_page_to_load($load_time)

    @browser.get_html_source.include?('Event queue was successfully created.').should be_true
    @browser.get_html_source.include?('JoeInvestigator').should be_true

    click_nav_new_cmr(@browser).should be_true
    add_demographic_info(@browser, {  :last_name => @person_2})
    first_reported_to_ph_date @browser, Date.today
    save_cmr(@browser).should be_true

    click_nav_new_cmr(@browser).should be_true
    add_demographic_info(@browser, {  :last_name => get_unique_name(2)})
    first_reported_to_ph_date @browser, Date.today
    save_cmr(@browser).should be_true

    @browser.open "/trisano/cmrs"
    @browser.click "link=Change View"
    @browser.add_selection "//select[@id='queues_selector']", "label=Enterics-UtahCounty"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load($load_time)

    @browser.get_html_source.include?(@person_1).should be_true
    @browser.get_html_source.include?(@person_2).should_not be_true

    @browser.click "link=Change View"
    @browser.add_selection "//select[@id='queues_selector']", "label=JoeInvestigator-SummitCounty"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load($load_time)

    @browser.get_html_source.include?(@person_1).should_not be_true
    @browser.get_html_source.include?(@person_2).should_not be_true

    # By state
    @browser.click "link=Change View"
    @browser.add_selection "//select[@id='states_selector']", "label=New"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load($load_time)

    @browser.get_html_source.include?(@person_1).should_not be_true
    @browser.get_html_source.include?(@person_2).should be_true

    @browser.click "link=Change View"
    @browser.add_selection "//div[@id='change_view']//select[@id='states_selector']", "label=Assigned to Investigator"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load($load_time)

    @browser.get_html_source.include?(@person_1).should be_true
    @browser.get_html_source.include?(@person_2).should_not be_true

    @browser.click "link=Change View"

    # By state and queue
    @browser.add_selection "//div[@id='change_view']//select[@id='states_selector']", "label=New"
    @browser.add_selection "//div[@id='change_view']//select[@id='queues_selector']", "label=Enterics-UtahCounty"
    @browser.click "set_as_default_view"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load($load_time)

    @browser.get_html_source.include?(@person_1).should_not be_true
    @browser.get_html_source.include?(@person_2).should_not be_true

    # By investigator
    @browser.click "link=Change View"
    @browser.add_selection "//div[@id='change_view']//select[@id='investigators_selector']", "label=#{@uname}"
    @browser.click "change_view_btn"
    @browser.wait_for_page_to_load($load_time)

    @browser.get_html_source.include?(@uname).should be_true
    @browser.get_xpath_count("//table[@class='list']//tr").should == "2"

    @browser.click "link=EVENTS"
    @browser.wait_for_page_to_load($load_time)

    @browser.get_html_source.include?(@person_1).should_not be_true
    @browser.get_html_source.include?(@person_2).should_not be_true
  end

end
