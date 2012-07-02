# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

describe 'Sorting tasks on the Dashboard' do
  
  #$dont_kill_browser = true
  
  before(:all) do
    @cmr_last_name = get_random_word << " task-sorting-uat"
    @disease = get_random_disease
    @task_name = get_random_word << " name task-sorting-uat"
    @task_with_notes_name = get_random_word << " task-sorting-uat"
    @task_with_notes_notes = get_random_word << " task-sorting-uat"
    @task_assigned_name = get_random_word << " task-sorting-uat"
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
    @browser.open "/trisano/events"
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it 'should add a bunch of tasks.' do
    [{ :task_name => 'z' + @task_name, 
        :task_category => 'Treatment',
        :task_priority => 'Low',
        :task_due_date => Date.today,
        :task_notes => 'z notes',
        :task_user_id => 'default_user' },
      { :task_name => 'a' + @task_name,
        :task_category => 'Appointment',
        :task_priority => 'High',
        :task_due_date => Date.today + 1,
        :task_notes => 'a notes',
        :task_user_id => 'default_user' }
    ].each do |task|
      add_task(@browser, task).should be_true
      @browser.click("link=Show CMR")
      @browser.wait_for_page_to_load($load_time)
    end
  end

  it 'should sort by columns' do
    @browser.click("//div[@id='head']//a/img")
    @browser.wait_for_page_to_load
    @browser.type('look_ahead', 7)
    @browser.type('look_back',  7)
    @browser.click('update_tasks_filter')
    @browser.wait_for_page_to_load
    ['Name', 'Description', 'Category', 'Priority'].each do |column|
      @browser.click("link=#{column}")
      sleep(3)
      @browser.get_text("//div[@id='tasks']//tbody/tr[1]/td[1]").should == (Date.today + 1).strftime("%Y-%m-%d")
      @browser.click("link=Due date")
      sleep(3)
      @browser.get_text("//div[@id='tasks']//tbody/tr[1]/td[1]").should == Date.today.strftime("%Y-%m-%d")
    end
  end

end
