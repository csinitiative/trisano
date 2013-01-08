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

 #$dont_kill_browser = true

describe 'Form Builder Admin Deactivate Functionality' do

  before(:all) do
    @form_name = get_unique_name(2) + " da-uat"
    @cmr_last_name = get_unique_name(1) + " da-uat"
    @disease = get_random_disease
    @jurisdiction = get_random_jurisdiction
    @question_text = "How are you doing?"
  end

  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @disease = nil
    @jurisdiction = nil
    @question_text = nil
  end

  it 'should create and publish a form' do
    create_new_form_and_go_to_builder(@browser, @form_name, @disease, @jurisdiction).should be_true
    add_question_to_view(@browser, "Default View", {:question_text => @question_text, :data_type => "Single line text", :short_name => get_random_word})
    publish_form(@browser)
  end
  
  it 'should create a CMR, edit, and save it to lock in form assignments' do
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease, @jurisdiction)
    edit_cmr(@browser)
    save_cmr(@browser)
    @browser.get_html_source.include?(@form_name).should be_true
  end
  
  it 'should deactivate the form' do
    click_nav_forms(@browser)
    click_resource_edit(@browser, "forms", @form_name)
    click_deactivate_form(@browser, @form_name).should be_true
    @browser.is_text_present("Form was successfully deactivated").should be_true
  end
  
  it 'existing CMR should still have its form' do
    click_nav_cmrs(@browser)
    click_resource_edit(@browser, "cmrs", @cmr_last_name)
    @browser.get_html_source.include?(@form_name).should be_true
  end
  
  it 'should create a second CMR and save it' do
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease, @jurisdiction)
  end
  
  it 'should not have assigned the deactivated form to the new CMR' do
    @browser.is_text_present(@form_name).should be_false
  end
  
end

