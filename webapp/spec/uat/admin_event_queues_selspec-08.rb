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
require 'active_support'

 # $dont_kill_browser = true

describe 'Managing event queues' do

  before(:all) do
    @queue_name_1 = get_unique_name(2)
    @queue_name_2 = get_unique_name(2)
  end
  
  it "should allow adding new event queues" do
    @browser.open "/trisano/admin"
    current_user = @browser.get_selected_label("user_id")
    if current_user != "default_user"
      switch_user(@browser, "default_user")
    end

    @browser.click "admin_queues"
    @browser.wait_for_page_to_load($load_time)
    
    @browser.click "create_event_queue"
    @browser.wait_for_page_to_load($load_time)

    @browser.type "event_queue_queue_name", @queue_name_1
    @browser.select "event_queue_jurisdiction_id", "label=Utah County Health Department"

    @browser.click "event_queue_submit"
    @browser.wait_for_page_to_load($load_time)

    @browser.is_text_present('Event queue was successfully created.').should be_true
    @browser.is_text_present(@queue_name_1).should be_true
    @browser.is_text_present('Utah County Health Department').should be_true
  end

  it "should allow editing an event queue" do
    @browser.click "link=Edit"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "event_queue_queue_name", @queue_name_2
    @browser.click "event_queue_submit"
    @browser.wait_for_page_to_load($load_time)
   
    @browser.is_text_present('Event queue was successfully updated.').should be_true
    @browser.is_text_present(@queue_name_2).should be_true
  end

  it "should allow deleting an event queue" do
    @browser.click "link=Delete"
    @browser.wait_for_page_to_load($load_time)
   
    @browser.is_text_present(@queue_name_2).should_not be_true
    @browser.is_text_present('Utah County Health Department').should_not be_true
  end

  it "should not be accessible to non-admins" do
    switch_user(@browser, "lhd_manager").should be_true
    @browser.is_text_present('You do not have administrative rights').should be_true
  end
    
end

