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
 
describe 'copying forms' do
  
  # $dont_kill_browser = true

  before :all do
    @form_name = get_unique_name(2) + " copy_form"
    @cmr_last_name = get_unique_name(1) + " copy_form"
    @contact_last_name = get_unique_name(1) + " copy_form"
    @disease_name = "Lyme disease"
    @jurisdiction = "All Jurisdictions"
    @event_type = "Morbidity Event"
  end

  after :all do
    @form_name = nil
    @cmr_last_name = nil
    @contact_last_name = nil
    @disease_name = nil
    @jurisdiction = nil
    @event_type = nil
  end

  it 'should create a new form' do 
    create_new_form_and_go_to_builder(@browser, @form_name, @disease_name, @jurisdiction, @event_type).should be_true
  end

  it 'should build the form' do
    name = "Patient first name"
    add_core_field_config(@browser, name)
    add_question_to_before_core_field_config(@browser, name, {:question_text => 'b4 quest', :data_type => "Single line text", :help_text => 'b4 text', :short_name => 'b4_text'})
    add_question_to_after_core_field_config(@browser, name, {:question_text => 'aft quest', :data_type => "Single line text", :help_text => 'aft text', :short_name => 'aft_text'})
    add_section_to_view(@browser, 'Default View', {:section_name => 'Section 1'})
    add_question_to_section(@browser, 'Section 1', 
      :question_text => 'drop down question',
      :data_type => "Drop-down select list",
      :short_name => 'drop_down_question')
    add_value_set_to_question(@browser,
      'drop down question',
      'Yes/No/Maybe',
      [{ :name => "Yes" }, { :name => "No" }, { :name => "Maybe" }]
    )

    publish_form(@browser).should be_true
  end

  it 'should copy the form' do
    copy_form_and_open_in_form_builder(@browser, @form_name).should be_true
    @browser.is_text_present('b4 quest').should be_true
    @browser.is_text_present('aft quest').should be_true    
    @browser.is_text_present('drop down question').should be_true
    @browser.is_text_present('Yes/No/Maybe').should be_true
    @browser.is_text_present('Yes').should be_true
    @browser.is_text_present('No').should be_true
    @browser.is_text_present('Maybe').should be_true
  end

  it 'should be able to publish the form copy' do
    publish_form(@browser)
  end
  
end
