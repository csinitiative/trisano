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

describe 'Updating a task' do
  
  # $dont_kill_browser = true
  
  before(:all) do
    @cmr_last_name = get_random_word << " task-uat"
    @disease = get_random_disease
    @task_name = get_random_word << " name task-uat"
    @task_notes = get_random_word << " notes task-uat"
    @due_date = date_for_calendar_select(Date.today + 1)
    @edited_due_date = date_for_calendar_select(Date.today + 2)
  end
  
  after(:all) do
    @cmr_last_name = nil
    @disease = nil
    @task_name = nil
    @task_notes = nil
    @due_date = nil
    @edited_due_date = nil
  end
  
  it "should create a basic CMR" do
    @browser.open "/trisano/events"
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it 'should add a task' do
    add_task(@browser, {
        :task_name => @task_name,
        :task_notes => @task_notes,
        :task_category => 'Appointment',
        :task_priority => 'Low',
        :task_due_date => @due_date
      }).should be_true

    is_text_present_in(@browser, "tasks", @task_name).should be_true
    is_text_present_in(@browser, "tasks", @task_notes).should be_true
    is_text_present_in(@browser, "tasks", "Appointment").should be_true
    is_text_present_in(@browser, "tasks", "Low").should be_true
    is_text_present_in(@browser, "tasks", (Date.today + 1).strftime("%Y-%m-%d")).should be_true
    is_text_present_in(@browser, "tasks", "default_user").should be_true

  end

  it 'should edit the task' do
    edit_task(@browser, {
        :task_name => "New name",
        :task_notes => "New notes",
        :task_status => "Complete",
        :task_category => 'Treatment',
        :task_priority => 'High',
        :task_due_date => @edited_due_date,
        :task_user_id => 'state_manager'
      }).should be_true

    @browser.click "link=Show CMR"
    @browser.wait_for_page_to_load($load_time)

    is_text_present_in(@browser, "tasks", @task_name).should be_false
    is_text_present_in(@browser, "tasks", @task_notes).should be_false
    is_text_present_in(@browser, "tasks", "Appointment").should be_false
    is_text_present_in(@browser, "tasks", "Low").should be_false
    is_text_present_in(@browser, "tasks", (Date.today + 1).strftime("%Y-%m-%d")).should be_false
    is_text_present_in(@browser, "tasks", "default_user").should be_false
    
    is_text_present_in(@browser, "tasks", "New name").should be_true
    is_text_present_in(@browser, "tasks", "New notes").should be_true
    is_text_present_in(@browser, "tasks", "Treatment").should be_true
    is_text_present_in(@browser, "tasks", "High").should be_true
    is_text_present_in(@browser, "tasks", (Date.today + 2).strftime("%Y-%m-%d")).should be_true
    is_text_present_in(@browser, "tasks", "state_manager").should be_true

  end
  
end
