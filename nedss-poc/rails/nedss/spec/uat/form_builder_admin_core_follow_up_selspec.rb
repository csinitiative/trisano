require File.dirname(__FILE__) + '/spec_helper'

 # $dont_kill_browser = true

describe 'Form Builder Admin Core Follow-Up Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) + " fu-uat"
    @cmr_last_name = get_unique_name(2) + " fu-uat"
    @follow_up_question_text = get_unique_name(2)  + " question fu-uat"
    @follow_up_answer =  get_unique_name(2)  + " answer fu-uat"    
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @follow_up_question_text = nil
    @follow_up_answer =  nil
  end
  
  it 'should handle core follow-ups.' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions").should be_true
    add_core_follow_up_to_view(@browser, "Default View", "2", "Patient birth gender")
    add_question_to_follow_up(@browser, "Core follow up, Condition: '2'", {:question_text => @follow_up_question_text, :data_type => "Single line text"})
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department")
    edit_cmr(@browser)
    @browser.is_text_present(@follow_up_question_text).should be_false
    
    # Enter the answer that meets the follow-up condition
    @browser.select("event_active_patient__active_primary_entity__person_birth_gender_id", "label=Female")
    click_core_tab(@browser, "Investigation") # This click triggers the onChange that triggers the condition processing
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    @browser.is_text_present(@follow_up_question_text).should be_true
    
    # Enter an answer that does not meet the follow-up condition
    @browser.select("event_active_patient__active_primary_entity__person_birth_gender_id", "label=Male")
    click_core_tab(@browser, "Investigation") # This click triggers the onChange that triggers the condition processing
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    @browser.is_text_present(@follow_up_question_text).should be_false

    # Back to a match, enter follow up answer and submit
    @browser.select("event_active_patient__active_primary_entity__person_birth_gender_id", "label=Female")
    click_core_tab(@browser, "Investigation") # This click triggers the onChange that triggers the condition processing
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    answer_investigator_question(@browser, @follow_up_question_text, @follow_up_answer)

    save_cmr(@browser)
    @browser.is_text_present(@follow_up_answer).should be_true
    
    edit_cmr(@browser)
    
    # Enter an answer that does not meet the follow-up condition
    @browser.select("event_active_patient__active_primary_entity__person_birth_gender_id", "label=Male")
    click_core_tab(@browser, "Investigation") # This click triggers the onChange that triggers the condition processing
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    
    save_cmr(@browser)
    @browser.is_text_present(@follow_up_answer).should be_false
    
  end
    
end