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

describe 'Form Builder Admin Core Tab Follow-Up Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) + " tfu-uat"
    @cmr_last_name = get_unique_name(2) + " tfu-uat"
    @follow_up_question_text = get_unique_name(2)  + " question tfu-uat"
    @follow_up_answer =  get_unique_name(2)  + " answer tfu-uat"    
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @follow_up_question_text = nil
    @follow_up_answer =  nil
  end

  it 'should handle core follow-ups on tabs' do
    create_new_form_and_go_to_builder(@browser, @form_name, 'African Tick Bite Fever', 'All Jurisdictions').should be_true
    add_core_tab_configuration(@browser, 'Demographics')
    add_core_follow_up_to_view(@browser, "Demographics", "Code: Female (gender)", "Patient birth gender")
    add_question_to_follow_up(@browser, "Core follow up, Code condition: Female (gender)", {:question_text => @follow_up_question_text, :data_type => "Single line text"})
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department")
    edit_cmr(@browser)
    @browser.is_text_present(@follow_up_question_text).should be_false

    # Enter the answer that meets the follow-up condition
    @browser.select("morbidity_event_active_patient__active_primary_entity__person_birth_gender_id", "label=Female")
    click_core_tab(@browser, "Investigation") # This click triggers the onChange that triggers the condition processing
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    @browser.is_text_present(@follow_up_question_text).should be_true
    
    # Enter an answer that does not meet the follow-up condition
    @browser.select("morbidity_event_active_patient__active_primary_entity__person_birth_gender_id", "label=Male")
    click_core_tab(@browser, "Investigation") # This click triggers the onChange that triggers the condition processing
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    @browser.is_text_present(@follow_up_question_text).should be_false

    # Back to a match, enter follow up answer and submit
    @browser.select("morbidity_event_active_patient__active_primary_entity__person_birth_gender_id", "label=Female")
    click_core_tab(@browser, "Investigation") # This click triggers the onChange that triggers the condition processing
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    answer_investigator_question(@browser, @follow_up_question_text, @follow_up_answer)

    save_cmr(@browser)
    @browser.is_text_present(@follow_up_answer).should be_true
    edit_cmr(@browser)
    
    # Enter an answer that does not meet the follow-up condition
    @browser.select("morbidity_event_active_patient__active_primary_entity__person_birth_gender_id", "label=Male")
    click_core_tab(@browser, "Investigation") # This click triggers the onChange that triggers the condition processing
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    
    save_cmr(@browser)
    @browser.is_text_present(@follow_up_answer).should be_false
  end
end
