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

# $dont_kill_browser = true

describe 'Form Builder Admin Push Functionality' do

  before(:all) do
    @first_form_name = get_unique_name(2) + " pu-uat"
    @second_form_name = get_unique_name(2) + " pu-uat"
    @cmr_last_name = get_unique_name(1) + " pu-uat"
    @disease = get_random_disease
    @jurisdiction = get_random_jurisdiction
    @question_text = "How are you doing?"
  end

  after(:all) do
    @first_form_name = nil
    @second_form_name = nil
    @cmr_last_name = nil
    @disease = nil
    @jurisdiction = nil
    @question_text = nil
  end

  it 'should create and publish a form' do
    create_new_form_and_go_to_builder(@browser, @first_form_name, @disease, @jurisdiction).should be_true
    add_question_to_view(@browser, "Default View", {:question_text => @question_text, :data_type => "Single line text", :short_name => get_random_word})
    publish_form(@browser)
  end
  
  it 'should create a CMR, edit, and save it to lock in form assignments' do
    create_basic_investigatable_cmr(@browser, @cmr_last_name, @disease, @jurisdiction)
    edit_cmr(@browser)
    save_cmr(@browser)
    @browser.get_html_source.include?(@first_form_name).should be_true
  end
  
  it 'should create and publish a second form' do
    create_new_form_and_go_to_builder(@browser, @second_form_name, @disease, @jurisdiction).should be_true
    add_question_to_view(@browser, "Default View", {:question_text => @question_text, :data_type => "Single line text", :short_name => get_random_word})
    publish_form(@browser)
  end
  
  it 'existing CMR should not have the second form before the push' do
    click_nav_cmrs(@browser)
    click_resource_edit(@browser, "cmrs", @cmr_last_name)
    @browser.get_html_source.include?(@second_form_name).should be_false
  end
  
  it 'should push second form' do
    click_nav_forms(@browser)
    click_resource_edit(@browser, "forms", @second_form_name)
    click_push_form(@browser, @second_form_name).should be_true
    @browser.get_html_source.include?("Form was successfully pushed to events").should be_true
  end
  
  it 'existing CMR should have the second form after the push' do
    click_nav_cmrs(@browser)
    click_resource_edit(@browser, "cmrs", @cmr_last_name)
    @browser.get_html_source.include?(@second_form_name).should be_true
  end
  
end

