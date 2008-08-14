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
