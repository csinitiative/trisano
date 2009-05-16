# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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
 
describe 'form builder core-tab questions for contacts' do
  
  # $dont_kill_browser = true
  
  before(:all) do
    @form_name = get_unique_name(2)  << " cct-uat"
    @cmr_last_name = get_unique_name(1)  << " cct-uat"
    @contact_last_name = get_unique_name(1)  << " cct-uat"
    
    @demo_question_text = get_unique_name(2)  << " cct-uat"
    @demo_answer = get_unique_name(2)  << " cct-uat"
    
    @clinical_question_text = get_unique_name(2)  << " cct-uat"
    @clinical_answer = get_unique_name(2)  << " cct-uat"
    
    @laboratory_question_text = get_unique_name(2)  << " cct-uat"
    @laboratory_answer = get_unique_name(2)  << " cct-uat"
    
    @epi_question_text = get_unique_name(2)  << " cct-uat"
    @epi_answer = get_unique_name(2)  << " cct-uat"
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @contact_last_name = nil
    
    @demo_question_text = nil
    @demo_answer = nil
    
    @clinical_question_text = nil
    @clinical_answer = nil
    
    @laboratory_question_text = nil
    @laboratory_answer = nil
    
    @epi_question_text = nil
    @epi_answer  = nil
  end
  
    
  it 'should create a new form with user-defined, core-tab questions' do
    create_new_form_and_go_to_builder(@browser, @form_name, "Cryptosporidiosis", "All Jurisdictions", "Contact event").should be_true
      
    add_core_tab_configuration(@browser, DEMOGRAPHICS).should be_true
    add_question_to_view(@browser, DEMOGRAPHICS, {:question_text =>@demo_question_text, :data_type => "Single line text", :short_name => get_random_word}).should be_true
      
    add_core_tab_configuration(@browser, CLINICAL).should be_true
    add_question_to_view(@browser, CLINICAL, {:question_text =>@clinical_question_text, :data_type => "Single line text", :short_name => get_random_word}).should be_true
      
    add_core_tab_configuration(@browser, LABORATORY).should be_true
    add_question_to_view(@browser, LABORATORY, {:question_text =>@laboratory_question_text, :data_type => "Single line text", :short_name => get_random_word}).should be_true
      
    add_core_tab_configuration(@browser, EPI).should be_true
    add_question_to_view(@browser, EPI, {:question_text =>@epi_question_text, :data_type => "Single line text", :short_name => get_random_word}).should be_true
    
  end
    
  it "should publish the form and create an investigatable CMR with a contact" do
    publish_form(@browser).should be_true
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "Cryptosporidiosis", "Bear River Health Department").should be_true
    edit_cmr(@browser).should be_true
    add_contact(@browser, {:last_name => @contact_last_name, :first_name => "John", :disposition => "Unable to locate"})
    save_cmr(@browser).should be_true
    click_link_by_order(@browser, "edit-contact-event", 1)
    @browser.wait_for_page_to_load($load_time)
  end
  
  it 'should place user-defined questions on the correct tabs' do
    assert_tab_contains_question(@browser, DEMOGRAPHICS, @demo_question_text).should be_true
    assert_tab_contains_question(@browser, CLINICAL, @clinical_question_text).should be_true
    assert_tab_contains_question(@browser, LABORATORY, @laboratory_question_text).should be_true
    assert_tab_contains_question(@browser, EPI, @epi_question_text).should be_true
  end
    
  it 'should allow answers to be saved' do
    click_core_tab(@browser, DEMOGRAPHICS)
    answer_investigator_question(@browser, @demo_question_text, @demo_answer).should be_true
      
    click_core_tab(@browser, CLINICAL)
    answer_investigator_question(@browser, @clinical_question_text, @clinical_answer).should be_true
      
    click_core_tab(@browser, LABORATORY)
    answer_investigator_question(@browser, @laboratory_question_text, @laboratory_answer).should be_true
      
    click_core_tab(@browser, EPI)
    answer_investigator_question(@browser, @epi_question_text, @epi_answer).should be_true
    
    save_contact_event(@browser).should be_true
    
    @browser.is_text_present(@demo_answer).should be_true
    @browser.is_text_present(@clinical_answer).should be_true
    @browser.is_text_present(@laboratory_answer).should be_true
    @browser.is_text_present(@epi_answer).should be_true
  end
  
  it 'should place user-defined questions on the correct tabs in show mode' do
    assert_tab_contains_question(@browser, DEMOGRAPHICS, @demo_question_text).should be_true
    assert_tab_contains_question(@browser, CLINICAL, @clinical_question_text).should be_true
    assert_tab_contains_question(@browser, LABORATORY, @laboratory_question_text).should be_true
    assert_tab_contains_question(@browser, EPI, @epi_question_text).should be_true
  end
  
end
  
