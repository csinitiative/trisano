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

describe 'Adding a repeating task to a CMR' do
  
  # $dont_kill_browser = true
  
  before(:all) do
    @cmr_last_name = get_random_word << " task-uat"
    @disease = get_random_disease
    @task_name = get_random_word << " name task-uat"
    @task_notes = get_random_word << " note task-uat"
    @due_date = date_for_calendar_select(Date.today + 1)
    @until_date = date_for_calendar_select(Date.today + 7)
  end
  
  after(:all) do
    @cmr_last_name = nil
    @disease = nil
    @task_name = nil
    @task_note = nil
    @due_date = nil
    @until_date = nil
  end
  
  it "should create a basic CMR" do
    @browser.open "/trisano/cmrs"
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
  end

  it 'should add a repeating task' do
    add_task(@browser, {
        :task_name => @task_name,
        :task_notes => @task_notes,
        :task_category => 'Appointment',
        :task_priority => 'Low',
        :task_due_date => @due_date,
        :task_until_date => @until_date,
        :task_repeating_interval => 'Daily'
      }).should be_true

    num_times_text_appears(@browser, @task_name).should == 7
  end

  it 'should display the tasks in edit mode' do
    @browser.click "link=Edit CMR"
    @browser.wait_for_page_to_load($load_time)
    num_times_text_appears(@browser, @task_name).should == 8 # Includes the one in the notes
  end

  it 'should display the tasks in show mode' do
    show_cmr(@browser)
    num_times_text_appears(@browser, @task_name).should == 8 # Includes the one in the notes
  end

  it 'should have only added one note in addition to the standard admin CMR creation note' do
    note_count(@browser).should eql(2)
    note_count(@browser, "Administrative").should eql(1)
    note_count(@browser, "Clinical").should eql(1)
  end

end
