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

require File.dirname(__FILE__) + '/spec_helper'

# $dont_kill_browser = true

describe 'System functionality for routing and workflow' do

  before(:all) do
    @event_queue_name = get_unique_name(1)
    @aids_person_1 = get_unique_name(2)
    @aids_person_2 = get_unique_name(2)
    @anthrax_person_1 = get_unique_name(2)
  end
  
  after(:all) do
    @event_queue_name = nil
    @aids_person_1 = nil
    @aids_person_2 = nil
    @anthrax_person_1 = nil
  end

  it "should create a new event_queue" do
    @browser.open "/trisano/admin"
    @browser.wait_for_page_to_load $load_time
    current_user = @browser.get_selected_label("user_id")
    if current_user != "default_user"
      switch_user(@browser, "default_user")
    end

    @browser.click "admin_queues"
    @browser.wait_for_page_to_load $load_time
    
    @browser.click "create_event_queue"
    @browser.wait_for_page_to_load $load_time

    @browser.type "event_queue_queue_name", @event_queue_name
    @browser.select "event_queue_jurisdiction_id", "label=Utah County Health Department"

    @browser.click "event_queue_submit"
    @browser.wait_for_page_to_load $load_time

    @browser.is_text_present('Event queue was successfully created.').should be_true
  end

  it "should create three CMRs" do
    click_nav_new_cmr(@browser).should be_true
    add_demographic_info(@browser, :last_name => @aids_person_1)
    add_clinical_info(@browser, :disease => "AIDS")
    
    save_cmr(@browser).should be_true

    click_nav_new_cmr(@browser).should be_true
    add_demographic_info(@browser, :last_name => @aids_person_2)
    add_clinical_info(@browser, :disease => "AIDS")
    save_cmr(@browser).should be_true

    click_nav_new_cmr(@browser).should be_true
    add_demographic_info(@browser, :last_name => @anthrax_person_1)
    add_clinical_info(@browser, :disease => "Anthrax")
    save_cmr(@browser).should be_true
  end

  it "should filter the CMR list by disease" do
    click_nav_cmrs(@browser)
    change_cmr_view(@browser, {:diseases => ["AIDS"]})
    
    @browser.is_text_present(@aids_person_1).should be_true
    @browser.is_text_present(@aids_person_2).should be_true
    @browser.is_text_present(@anthrax_person_1).should be_false

    change_cmr_view(@browser, {:diseases => ["Anthrax"]})

    @browser.is_text_present(@aids_person_1).should be_false
    @browser.is_text_present(@aids_person_2).should be_false
    @browser.is_text_present(@anthrax_person_1).should be_true

    change_cmr_view(@browser, {:diseases => ["Anthrax","AIDS"]})

    @browser.is_text_present(@aids_person_1).should be_true
    @browser.is_text_present(@aids_person_2).should be_true
    @browser.is_text_present(@anthrax_person_1).should be_true
  end
  
end
