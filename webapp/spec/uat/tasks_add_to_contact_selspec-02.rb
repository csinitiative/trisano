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

describe 'Adding a task to a contact' do
  
  #$dont_kill_browser = true
  
  before(:all) do
    @cmr_last_name = get_random_word << " ctask-uat"
    @contact_last_name = get_random_word << " ctask-uat"
    @disease = get_random_disease
    @task_name = get_random_word << " name task-uat"
    @task_with_notes_name = get_random_word << " task-uat"
    @task_with_notes_notes = get_random_word << " task-uat"
    @due_date = date_for_calendar_select(Date.today + 1)
  end
  
  after(:all) do
    @cmr_last_name = nil
    @contact_last_name = nil
    @disease = nil
    @task_name = nil
    @task_with_notes_name = nil
    @task_with_notes_notes = nil
    @due_date = nil
  end
  
  it "should create a basic CMR and a contact" do
    @browser.open "/trisano/cmrs"
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease).should be_true
    edit_cmr(@browser)
    add_contact(@browser, { :last_name => @contact_last_name } )
    save_cmr(@browser)
    @browser.click("link=Show Contact")
    @browser.wait_for_page_to_load($load_time)
  end

  it 'should add a task with no notes from contact show mode' do
    add_task(@browser, {
        :task_name => @task_name,
        :task_category => 'Appointment',
        :task_priority => 'Low',
        :task_due_date => @due_date
      }).should be_true
  end

  it 'should add a task with notes from contact show mode' do
    @browser.click "link=Show Contact"
    @browser.wait_for_page_to_load($load_time)
    add_task(@browser, {
        :task_name => @task_with_notes_name,
        :task_notes => @task_with_notes_notes,
        :task_category => 'Appointment',
        :task_priority => 'Low',
        :task_due_date => @due_date
      }).should be_true
  end

  it 'should display the tasks in contact edit mode' do
    @browser.click "link=Edit Contact"
    @browser.wait_for_page_to_load($load_time)
    html_source = @browser.get_html_source
    html_source.include?(@task_name).should be_true
    html_source.include?(@task_with_notes_name).should be_true
  end
  
  it 'should display the tasks in contact show mode' do
    show_contact(@browser)
    html_source = @browser.get_html_source
    html_source.include?(@task_name).should be_true
    html_source.include?(@task_with_notes_name).should be_true
  end

  it 'should only have added one note to the contact' do
    note_count(@browser).should eql(2)
    note_count(@browser, "Administrative").should eql(1)
    note_count(@browser, "Clinical").should eql(1)
  end
  
  it 'should display the task notes as a clinical note' do
    @browser.click("clinical-notes")
    sleep(2)
    @browser.get_eval("selenium.browserbot.getCurrentWindow().$$('div[id^=note_]').findAll(function(n) { return n.innerHTML.indexOf('#{@task_with_notes_notes}') > 0; }).length").to_i.should eql(1)
  end


end
