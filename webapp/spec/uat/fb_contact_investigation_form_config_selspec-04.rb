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
 
describe 'form builder investigation form for contacts' do
  
  # $dont_kill_browser = true
  
  before(:all) do
    @form_name = get_unique_name(2)  << " cf-uat"
    @cmr_last_name = get_unique_name(1)  << " cf-uat"
    @contact_last_name = get_unique_name(1)  << " cf-uat"
    
    @question_text = get_unique_name(2)  << " cf-uat"
    @answer = get_unique_name(2)  << " cf-uat"
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @contact_last_name = nil
    
    @question_text = nil
    @answer = nil
  end
  
  it 'should create a new form' do
    create_new_form_and_go_to_builder(@browser, @form_name, "Plague", "All Jurisdictions", "Contact Event").should be_true
    add_question_to_view(@browser, "Default View", {:question_text => @question_text, :data_type => "Single line text", :short_name => get_random_word})
  end
    
  it "should publish the form and create an investigatable CMR with a contact" do
    publish_form(@browser).should be_true
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "Plague", "Bear River Health Department").should be_true
    edit_cmr(@browser).should be_true
    add_contact(@browser, {:last_name => @contact_last_name, :first_name => "John", :disposition => "Unable to locate"})
    save_cmr(@browser).should be_true
    click_link_by_order(@browser, "edit-event", 1)
    @browser.wait_for_page_to_load($load_time)
  end
  
  it 'should have the investigation form' do
    @browser.get_html_source.include?(@form_name).should be_true
    @browser.get_html_source.include?(@question_text).should be_true
  end
    
  it 'should allow answers to be saved' do
    answer_investigator_question(@browser, @question_text, @answer).should be_true
    save_contact_event(@browser).should be_true
    @browser.get_html_source.include?(@answer).should be_true
  end
  
end
  
