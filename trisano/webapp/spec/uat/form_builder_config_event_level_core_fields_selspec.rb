require File.dirname(__FILE__) + '/spec_helper'

describe 'Add disease-specific questions around any event-level field' do

  [{:name => 'Results reported to clinician date', :tab_name => REPORTING},
    {:name => 'Date first reported to public health', :tab_name => REPORTING},
    {:name => 'LHD case status', :tab_name => ADMIN},
    {:name => 'UDOH case status', :tab_name => ADMIN},
    {:name => 'Outbreak associated', :tab_name => ADMIN},
    {:name => 'Outbreak', :tab_name => ADMIN},
    {:name => 'Jurisdiction responsible for investigation', :tab_name  => ADMIN},
    {:name => 'Event status', :tab_name  => ADMIN},
    {:name => 'Date investigation started', :tab_name  => ADMIN},
    {:name => 'Date investigation completed', :tab_name  => ADMIN},
    {:name => 'Event name', :tab_name  => ADMIN},
    {:name => 'Date review completed by UDOH', :tab_name  => ADMIN},
    {:name => 'Imported from', :tab_name => EPI}
  ].each do |test| 
  
    it "should support before and after on the '#{test[:name]}' field" do
      form_name = get_unique_name(2) + " el_fields"
      cmr_last_name = get_unique_name(1) + " el_fields"
      disease_name = "African Tick Bite Fever"
      before_question = "b4 #{test[:name]} " + get_unique_name(2)
      after_question = "af #{test[:name]} " + get_unique_name(2)
      before_answer = "b4 #{test[:name]} ans" + get_unique_name(2) 
      after_answer = "af #{test[:name]} ans" + get_unique_name(2)     

      create_new_form_and_go_to_builder(@browser, form_name, disease_name, "All Jurisdictions").should be_true
      add_core_field_config(@browser, test[:name])
      add_question_to_before_core_field_config(@browser, test[:name], {:question_text => before_question, :data_type => "Single line text"})
      add_question_to_after_core_field_config(@browser, test[:name], {:question_text => after_question, :data_type => "Single line text"})
      publish_form(@browser).should be_true
      
      create_basic_investigatable_cmr(@browser, cmr_last_name, disease_name, "Bear River Health Department")
      edit_cmr(@browser)
      @browser.is_text_present(before_question).should be_true
      @browser.is_text_present(after_question).should be_true
      answer_investigator_question(@browser, before_question, before_answer)
      answer_investigator_question(@browser, after_question, after_answer)

      save_cmr(@browser)
      @browser.is_text_present(before_answer).should be_true
      @browser.is_text_present(after_answer).should be_true
      assert_tab_contains_question(@browser, test[:tab_name], before_question).should be_true
      assert_tab_contains_question(@browser, test[:tab_name], after_question).should be_true
    end

  end

end
