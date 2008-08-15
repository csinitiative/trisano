# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

describe 'Form Builder Admin Delete Element Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) + " d-uat"
    @cmr_last_name = get_unique_name(1) + " d-uat"
    @tab_name = get_unique_name(2)  + " tab d-uat"
    @section_name = get_unique_name(2)  + " section d-uat"
    @question_text = get_unique_name(2)  + " question d-uat"
    @value_set_question_text = get_unique_name(2)  + " question d-uat"
    @value_set_name = get_unique_name(2)  + " vs d-uat"
    @value_set_value_one = get_unique_name(2)  + " vsv d-uat"
    @value_set_value_two = get_unique_name(2)  + " vsv d-uat"
    @value_set_value_three = get_unique_name(2)  + " vsv d-uat"
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @tab_name = nil
    @section_name = nil
    @question_text = nil
    @value_set_question_text = nil
    @value_set_name = nil
    @value_set_value_one = nil
    @value_set_value_two = nil
    @value_set_value_three = nil
  end
  
  it 'should delete questions, tabs, sections, and value sets' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions")
    
    add_view(@browser, @tab_name)
    add_section_to_view(@browser, "Default View", @section_name)
    add_question_to_view(@browser, "Default View", {:question_text => @question_text, :data_type => "Single line text"})
    add_question_to_view(@browser, "Default View", {:question_text => @value_set_question_text, :data_type => "Drop-down select list"})
    add_value_set_to_question(@browser, @value_set_question_text, @value_set_name, @value_set_value_one, @value_set_value_two, @value_set_value_three) 

    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department")
    edit_cmr(@browser)
    
    @browser.is_text_present(@tab_name).should be_true
    @browser.is_text_present(@section_name).should be_true
    @browser.is_text_present(@question_text).should be_true
    @browser.is_text_present(@value_set_value_one).should be_true
    @browser.is_text_present(@value_set_value_two).should be_true
    
    click_nav_forms(@browser)
    click_build_form(@browser, @form_name)
    
    delete_view(@browser, @tab_name).should be_true
    delete_section(@browser, @section_name).should be_true
    delete_question(@browser, @question_text).should be_true
    delete_value_set(@browser, @value_set_name).should be_true
    
    publish_form(@browser)
    click_nav_cmrs(@browser)
    click_resource_edit(@browser, "cmrs", @cmr_last_name)
   
    @browser.is_text_present(@tab_name).should be_false
    @browser.is_text_present(@section_name).should be_false
    @browser.is_text_present(@question_text).should be_false
    @browser.is_text_present(@value_set_value_one).should be_false
    @browser.is_text_present(@value_set_value_two).should be_false
    
  end
    
end