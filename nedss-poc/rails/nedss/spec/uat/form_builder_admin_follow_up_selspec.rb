require File.dirname(__FILE__) + '/spec_helper'

# $dont_kill_browser = true

describe 'Form Builder Admin Standard Follow-Up Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) + " fu-uat"
    @cmr_last_name = get_unique_name(1) + " fu-uat"
    @original_question_text = get_unique_name(2)  + " question fu-uat"
    @follow_up_question_text = get_unique_name(2)  + " question fu-uat"
    @follow_up_answer =  get_unique_name(2)  + " answer fu-uat"    
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @original_question_text = nil
    @follow_up_question_text = nil
    @follow_up_answer =  nil
  end
  
  it 'should handle standard follow-ups.' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions")
    add_question_to_view(@browser, "Default View", {:question_text => @original_question_text, :data_type => "Single line text"})
    add_follow_up_to_question(@browser, @original_question_text, "Yes")
    add_question_to_follow_up(@browser, "Follow up for: 'Yes'", {:question_text => @follow_up_question_text, :data_type => "Single line text"})
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department")
    
    edit_cmr(@browser)
    @browser.is_text_present(@follow_up_question_text).should be_false
    
    # Enter the answer that meets the follow-up condition
    answer_investigator_question(@browser, @original_question_text, "Yes")
    @browser.click("link=#{@form_name}") # A bit of a kluge. Clicking this link essential generates the onChange needed to process the follow-up logic
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    @browser.is_text_present(@follow_up_question_text).should be_true
    
    # Enter an answer that does not meet the follow-up condition
    answer_investigator_question(@browser, @original_question_text, "No match")
    @browser.click("link=#{@form_name}")
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    @browser.is_text_present(@follow_up_question_text).should be_false
    
    # Back to a match, enter follow up answer and submit
    answer_investigator_question(@browser, @original_question_text, "Yes")
    @browser.click("link=#{@form_name}")
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    answer_investigator_question(@browser, @follow_up_question_text, @follow_up_answer)
     
    save_cmr(@browser)
    @browser.is_text_present(@follow_up_answer).should be_true
    
    edit_cmr(@browser)
    # Enter an answer that does not meet the follow-up condition
    answer_investigator_question(@browser, @original_question_text, "No match")
    @browser.click("link=#{@form_name}")
    sleep(2) # Replace this with something better -- need to make sure the round trip to process condition has happened
    save_cmr(@browser)
    @browser.is_text_present(@follow_up_answer).should be_false
    
  end
    
end