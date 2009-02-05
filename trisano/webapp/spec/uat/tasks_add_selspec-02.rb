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

describe 'Adding a task to a CMR' do
  
  #$dont_kill_browser = true
  
  before(:all) do
    @cmr_last_name = get_random_word << " task-uat"
    @disease = get_random_disease
    @show_task_name = get_random_word << " task-uat"
    @show_task_description = get_random_word << " task-uat"
  end
  
  after(:all) do
    @cmr_last_name = nil
    @disease = nil
    @show_task_name = nil
    @show_task_description = nil
  end
  
  it "should create a basic CMR" do
    @browser.open "/trisano/cmrs"
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it 'should add a task from show mode' do
    @browser.click("link=Add Task")
    @browser.wait_for_page_to_load($load_time)
    @browser.type("task_name", @show_task_name)
    @browser.type("task_description", @show_task_description)
    @browser.select("task_category", "Appointment")
    @browser.select("task_priority", "Low")
    @browser.type("task_due_date", "September 23, 2020")
    @browser.click("task_submit")
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("Task was successfully created.").should be_true
    @browser.is_text_present(@show_task_name).should be_true
  end

  it 'should display the task in edit mode' do
    edit_cmr(@browser)
    @browser.is_text_present(@show_task_name).should be_true
  end
  
  it 'should display the task in show mode' do
    show_cmr(@browser)
    @browser.is_text_present(@show_task_name).should be_true
  end

end
