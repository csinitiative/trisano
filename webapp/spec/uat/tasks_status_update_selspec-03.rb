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

describe 'Marking a task as completed or as not applicable' do

  # Debt: This spec was originally done with great haste and is very much a
  # happy-path test.
  # Holes:
  #  * Sleeps
  #  * Test permissions
  #   * Create task for super user, task for investigator
  #   * Switch to investigator, try to update task for superuser, assert there's an error message
  # * Doesn't exercise contact tasks
  # * Doesn't test links from the dashboard
  # * Assertions against CSS classes could be too fragile

  # $dont_kill_browser = true
  
  before(:all) do
    @cmr_last_name = get_random_word << " ts-uat"
    @disease = get_random_disease
    @task_name = get_random_word << " ts-uat"
    @due_date = date_for_calendar_select(Date.today + 1)
  end
  
  after(:all) do
    @cmr_last_name = nil
    @disease = nil
    @task_name = nil
    @due_date = nil
  end
  
  it "should create a basic CMR" do
    @browser.open "/trisano/events"
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it 'should add a task' do
    add_task(@browser, {
        :task_name => @task_name,
        :task_category => 'Appointment',
        :task_priority => 'Low',
        :task_due_date => @due_date
      }).should be_true
  end

  it 'should mark the task as complete from the task page' do
    update_task_status(@browser, "Complete")
    @browser.get_html_source.include?("task-complete").should be_true
  end

  it 'should mark the task as not applicable from the task page' do
    update_task_status(@browser, "Not applicable")
    @browser.get_html_source.include?("task-not-applicable").should be_true
  end

  it 'should mark the task as complete from the CMR edit page' do
    @browser.click("link=Edit CMR")
    @browser.wait_for_page_to_load($load_time)
    update_task_status(@browser, "Complete")
    @browser.get_html_source.include?("task-complete").should be_true
  end

  it 'should mark the task as not applicable from the CMR edit page' do
    update_task_status(@browser, "Not applicable")
    @browser.get_html_source.include?("task-not-applicable").should be_true
  end

  it 'should mark the task as complete from the CMR show page' do
    @browser.click("link=Show")
    @browser.wait_for_page_to_load($load_time)
    update_task_status(@browser, "Complete")
    @browser.get_html_source.include?("task-complete").should be_true
  end

  it 'should mark the task as not applicable from the CMR show page' do
    update_task_status(@browser, "Not applicable")
    @browser.get_html_source.include?("task-not-applicable").should be_true
  end

  it 'all of the status changes should have generated clinical notes' do
    @browser.click("clinical-notes")
    sleep(3)
    note_count(@browser, "Clinical").should eql(6)
  end

end
