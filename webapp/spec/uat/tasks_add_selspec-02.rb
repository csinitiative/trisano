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

describe 'Adding a task to a CMR' do
  
  #$dont_kill_browser = true
  
  before(:all) do
    @cmr_last_name = get_random_word << " task-uat"
    @disease = get_random_disease
    @task_name = get_random_word << " name task-uat"
    @task_with_notes_name = get_random_word << " task-uat"
    @task_with_notes_notes = get_random_word << " task-uat"
    @task_assigned_name = get_random_word << " task-uat"
    @due_date = date_for_calendar_select(DateTime.now + 1)
  end
  
  after(:all) do
    @cmr_last_name = nil
    @disease = nil
    @task_name = nil
    @task_with_notes_name = nil
    @task_with_notes_notes = nil
    @task_assigned_name = nil
  end
  
  it "should create a basic CMR" do
    @browser.open "/trisano/cmrs"
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it 'should add a task with no notes from show mode' do
    add_task(@browser, {
        :task_name => @task_name,
        :task_category => 'Appointment',
        :task_priority => 'Low',
        :task_due_date => @due_date
      }).should be_true
  end

  it 'should add a task with notes from show mode' do
    @browser.click "link=Show CMR"
    @browser.wait_for_page_to_load($load_time)
    add_task(@browser, {
        :task_name => @task_with_notes_name,
        :task_notes => @task_with_notes_notes,
        :task_category => 'Appointment',
        :task_priority => 'Low',
        :task_due_date => @due_date
      }).should be_true
  end

  it 'should add a task and assign to a user from show mode' do
    @browser.click "link=Show CMR"
    @browser.wait_for_page_to_load($load_time)
    add_task(@browser, {
        :task_name => @task_assigned_name,
        :task_category => 'Appointment',
        :task_priority => 'Low',
        :task_due_date => @due_date,
        :task_user_id => 'data_entry_tech'
      }).should be_true
  end

  it 'should display the tasks in edit mode' do
    @browser.click "link=Edit CMR"
    @browser.wait_for_page_to_load($load_time)
    html_source = @browser.get_html_source
    html_source.include?(@task_name).should be_true
    html_source.include?(@task_with_notes_name).should be_true
    html_source.include?(@task_assigned_name).should be_true
  end
  
  it 'should display the tasks in show mode' do
    show_cmr(@browser)
    html_source = @browser.get_html_source
    html_source.include?(@task_name).should be_true
    html_source.include?(@task_with_notes_name).should be_true
    html_source.include?(@task_assigned_name).should be_true
  end

  it 'should have only added one note in addition to the standard admin CMR creation note' do
    note_count(@browser).should eql(2)
    note_count(@browser, "Administrative").should eql(1)
    note_count(@browser, "Clinical").should eql(1)
  end

  it 'should display the task notes as a clinical note' do
    @browser.click("clinical-notes")
    sleep(2)
    @browser.get_eval("selenium.browserbot.getCurrentWindow().$$('div[id^=note_]').findAll(function(n) { return n.innerHTML.indexOf('#{@task_with_notes_notes}') > 0; }).length").to_i.should eql(1)
  end

  # Debt: Weak test of task assignment. Maybe bust out into a separate task assignment spec when the dashboard is functional
  it 'should display the user name of the user to whom a task was assigned' do
    @browser.is_text_present("data_entry_tech").should be_true
  end

  it "shouldn't show the user assignment drop down for a non-manager user" do
    switch_user(@browser, "investigator")
    @browser.click("link=Add Task")
    @browser.is_element_present("task_user_id").should be_false
  end

end
