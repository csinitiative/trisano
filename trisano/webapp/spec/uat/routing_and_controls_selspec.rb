require File.dirname(__FILE__) + '/spec_helper'

# $dont_kill_browser = true

describe 'Sytem functionality for routing a CMR among jurisdictions' do

  it "should present all controls" do
    @browser.open "/trisano/cmrs"
    @browser.wait_for_page_to_load "30000"
    current_user = @browser.get_selected_label("user_id")
    if current_user != "default_user"
      switch_user(@browser, "default_user")
    end

    @browser.is_text_present("NEW CMR").should be_true
    @browser.is_text_present("New Morbidity Report").should be_true

    click_nav_new_cmr(@browser).should be_true
    @browser.type('morbidity_event_active_patient__active_primary_entity__person_last_name', get_unique_name(2))
    save_cmr(@browser).should be_true

    @browser.is_text_present("NEW CMR").should be_true
    @browser.is_text_present("Edit").should be_true
    @browser.is_text_present("Route to:").should be_true
  end

  it "should create new CMRs in the unassigned jurisdiction" do
    @browser.is_text_present("Assigned Jurisdiction: Unassigned").should be_true
  end

  it "should allow routing to a new jurisdiction" do
    @browser.select "jurisdiction_id", "label=Bear River Health Department"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Assigned Jurisdiction: Bear River Health Department").should be_true
    @browser.is_text_present("Assigned to Local Health Dept.").should be_true
  end

  it "should not display routing controls for a less privileged user" do
    switch_user(@browser, "lhd_manager").should be_true

    @browser.is_text_present("Assigned Jurisdiction: Unassigned").should_not be_true
  end

end
