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

describe 'Navigating to an event from a task' do
  
  # $dont_kill_browser = true
  
  before(:all) do
    @cmr_last_name = get_random_word << " ctask-uat"
    @disease = get_random_disease
    @task_name = get_random_word << " name task-uat"
    @due_date = date_for_calendar_select(Date.today + 1)
  end
  
  after(:all) do
    @cmr_last_name = nil
    @disease = nil
    @task_name = nil
    @due_date = nil
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

  it 'should allow navigation to the event from the task form page' do
    @browser.click("link=Edit event")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Edit morbidity event:").should be_true
  end

  it 'should allow navigation to the event from the event edit page' do
    @browser.click("link=Edit event")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Edit morbidity event:").should be_true
  end

  it 'should allow navigation to the event from the event show page' do
    show_cmr(@browser)
    @browser.click("link=Edit event")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Edit morbidity event:").should be_true
  end

  it 'should allow navigation to the event from the dashboard' do
    click_logo(@browser)
    change_task_filter(@browser, { :look_ahead => "" })
    @browser.click("link=Edit event")
    @browser.wait_for_page_to_load($load_time)
    @browser.get_html_source.include?("Edit morbidity event:").should be_true
  end

end
