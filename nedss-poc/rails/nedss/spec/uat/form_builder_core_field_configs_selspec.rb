require File.dirname(__FILE__) + '/spec_helper'
 
describe 'form builder core-field questions' do
  
  # $dont_kill_browser = true
  
  before(:all) do
    @form_name = get_unique_name(2)  + " ud-fu-uat"
    @cmr_last_name = get_unique_name(1)  + " ud-fu-uat"
    
    @patient_question_text = get_unique_name(2)  + " ud-fu-uat"
    @patient_answer = get_unique_name(2)  + " ud-fu-uat"
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    
    @patient_question_text = nil
    @patient_answer = nil
  end
  
  it 'should create a new form with user-defined, core-field questions' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions").should be_true
    add_core_field_config(@browser, "Patient last name").should be_true
    add_question_to_core_field_config(@browser, "Patient last name", {:question_text =>@patient_question_text, :data_type => "Single line text"}).should be_true
  end
    
  it "should publish the form and create an investigatable CMR" do
    publish_form(@browser).should be_true
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department").should be_true
    edit_cmr(@browser).should be_true
  end
  
  it 'should place user-defined core-field questions on the correct tab' do
    assert_tab_contains_question(@browser, DEMOGRAPHICS, @patient_question_text).should be_true
  end
    
  it 'should allow answers to be saved' do
    click_core_tab(@browser, DEMOGRAPHICS)
    answer_investigator_question(@browser, @patient_question_text, @patient_answer).should be_true
    save_cmr(@browser).should be_true
    @browser.is_text_present(@patient_answer).should be_true
  end
  
end
  
