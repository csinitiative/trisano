require File.dirname(__FILE__) + '/spec_helper'
 
describe 'form builder user-defined, core-tab questions' do
  
  $dont_kill_browser = true
  
  before(:all) do
    @form_name = get_unique_name(2)  + " ud-fu-uat"
    @cmr_last_name = get_unique_name(1)  + " ud-fu-uat"
    
    @demo_question_text = get_unique_name(2)  + " ud-fu-uat"
    @demo_answer = get_unique_name(2)  + " ud-fu-uat"
    
    @clinical_question_text = get_unique_name(2)  + " ud-fu-uat"
    @clinical_answer = get_unique_name(2)  + " ud-fu-uat"
    
    @laboratory_question_text = get_unique_name(2)  + " ud-fu-uat"
    @laboratory_answer = get_unique_name(2)  + " ud-fu-uat"
    
    @contacts_question_text = get_unique_name(2)  + " ud-fu-uat"
    @contacts_answer = get_unique_name(2)  + " ud-fu-uat"
    
    @epi_question_text = get_unique_name(2)  + " ud-fu-uat"
    @epi_answer = get_unique_name(2)  + " ud-fu-uat"
    
    @reporting_question_text = get_unique_name(2)  + " ud-fu-uat"
    @reporting_answer = get_unique_name(2)  + " ud-fu-uat"
    
    @admin_question_text = get_unique_name(2)  + " ud-fu-uat"
    @admin_answer = get_unique_name(2)  + " ud-fu-uat"
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    
    @demo_question_text = nil
    @demo_answer = nil
    
    @clinical_question_text = nil
    @clinical_answer = nil
    
    @laboratory_question_text = nil
    @laboratory_answer = nil
    
    @contacts_question_text = nil
    @contacts_answer = nil
    
    @epi_question_text = nil
    @epi_answer  = nil
    
    @reporting_question_text = nil
    @reporting_answer = nil
    
    @admin_question_text = nil
    @admin_answer = nil
  end
  
    
  it 'should create a new form with user-defined, core-tab questions' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions").should be_true
      
    add_core_tab_configuration(@browser, DEMOGRAPHICS)
    add_question_to_view(@browser, DEMOGRAPHICS, {:question_text =>@demo_question_text, :data_type => "Single line text"})
      
    add_core_tab_configuration(@browser, CLINICAL)
    add_question_to_view(@browser, CLINICAL, {:question_text =>@clinical_question_text, :data_type => "Single line text"})
      
    add_core_tab_configuration(@browser, LABORATORY)
    add_question_to_view(@browser, LABORATORY, {:question_text =>@laboratory_question_text, :data_type => "Single line text"})
      
    add_core_tab_configuration(@browser, CONTACTS)
    add_question_to_view(@browser, CONTACTS, {:question_text =>@contacts_question_text, :data_type => "Single line text"})
      
    add_core_tab_configuration(@browser, EPI)
    add_question_to_view(@browser, EPI, {:question_text =>@epi_question_text, :data_type => "Single line text"})
      
    add_core_tab_configuration(@browser, REPORTING)
    add_question_to_view(@browser, REPORTING, {:question_text =>@reporting_question_text, :data_type => "Single line text"})
      
    add_core_tab_configuration(@browser, ADMIN)
    add_question_to_view(@browser, ADMIN, {:question_text =>@admin_question_text, :data_type => "Single line text"})
      
  end
    
  it "should publish the form and create an investigatable CMR" do
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department")
    edit_cmr(@browser)
  end
  
  it 'should place user-defined questions on the correct tabs' do
    assert_tab_contains_question(@browser, DEMOGRAPHICS, @demo_question_text).should be_true
    assert_tab_contains_question(@browser, CLINICAL, @clinical_question_text).should be_true
    assert_tab_contains_question(@browser, LABORATORY, @laboratory_question_text).should be_true
    assert_tab_contains_question(@browser, CONTACTS, @contacts_question_text).should be_true
    assert_tab_contains_question(@browser, EPI, @epi_question_text).should be_true
    assert_tab_contains_question(@browser, REPORTING, @reporting_question_text).should be_true
    assert_tab_contains_question(@browser, ADMIN, @admin_question_text).should be_true
  end
    
  it 'should allow answers to be saved' do
    click_core_tab(@browser, DEMOGRAPHICS)
    answer_investigator_question(@browser, @demo_question_text, @demo_answer)
      
    click_core_tab(@browser, CLINICAL)
    answer_investigator_question(@browser, @clinical_question_text, @clinical_answer)
      
    click_core_tab(@browser, LABORATORY)
    answer_investigator_question(@browser, @laboratory_question_text, @laboratory_answer)
      
    click_core_tab(@browser, CONTACTS)
    answer_investigator_question(@browser, @contacts_question_text, @contacts_answer)
      
    click_core_tab(@browser, EPI)
    answer_investigator_question(@browser, @epi_question_text, @epi_answer)
      
    click_core_tab(@browser, REPORTING)
    answer_investigator_question(@browser, @reporting_question_text, @reporting_answer)
      
    click_core_tab(@browser, ADMIN)
    answer_investigator_question(@browser, @admin_question_text, @admin_answer)
      
    save_cmr(@browser)
    
    @browser.is_text_present(@demo_answer).should be_true
    @browser.is_text_present(@clinical_answer).should be_true
    @browser.is_text_present(@laboratory_answer).should be_true
    @browser.is_text_present(@contacts_answer).should be_true
    @browser.is_text_present(@epi_answer).should be_true
    @browser.is_text_present(@reporting_answer).should be_true
    @browser.is_text_present(@admin_answer).should be_true
  end
  
end
  
