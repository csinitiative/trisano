require File.dirname(__FILE__) + '/spec_helper'

describe 'Add disease-specific questions around any event-level field' do

  before(:all) do    
    @form_name = get_unique_name(2) + " el_fields"
    @cmr_last_name = get_unique_name(2) + " el_fields"
  end

  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
  end

  [{:name => 'Results reported to clinician date', :tab_name => 'reporting_tab'},
   {:name => 'Date first reported to public health', :tab_name => 'reporting_tab'},
   {:name => 'LHD case status', :tab_name => 'administrative_tab'},
   {:name => 'UDOH case status', :tab_name => 'administrative_tab'},
   {:name => 'Outbreak associated', :tab_name => 'administrative_tab'},
   {:name => 'Outbreak', :tab_name => 'administrative_tab'},
   {:name => 'Jurisdiction responsible for investigation', :tab_name => 'administrative_tab'},
   {:name => 'Event status', :tab_name => 'administrative_tab'},
   {:name => 'Date investigation started', :tab_name => 'administrative_tab'},
   {:name => 'Date investigation completed', :tab_name => 'administrative_tab'},
   {:name => 'Event name', :tab_name => 'administrative_tab'},
   {:name => 'Date review completed by UDOH', :tab_name => 'administrative_tab'},
   {:name => 'Imported from', :tab_name => 'epi_tab'}
  ].each do |test| 
  
    it "should support before and after on the '#{test[:name]}' field" do
      disease_name = "African Tick Bite Fever"
      before_question = "Before #{test[:name]} " + get_unique_name(2)
      after_question = "After #{test[:name]} " + get_unique_name(2)
      before_answer = "Before #{test[:name]} answer" + get_unique_name(2) 
      after_answer = "After #{test[:name]} answer" + get_unique_name(2)     

      create_new_form_and_go_to_builder(@browser, @form_name, disease_name, "All Jurisdictions").should be_true
      add_core_field_config(@browser, test[:name])
      add_question_to_before_core_field_config(@browser, test[:name], {:question_text => before_question, :data_type => "Single line text"})
      add_question_to_after_core_field_config(@browser, test[:name], {:question_text => after_question, :data_type => "Single line text"})
      publish_form(@browser)
      
      create_basic_investigatable_cmr(@browser, @cmr_last_name, disease_name, "Bear River Health Department")
      edit_cmr(@browser)
      @browser.is_text_present(before_question).should be_true
      @browser.is_text_present(test[:name]).should be_true
      @browser.is_text_present(after_question).should be_true
      answer_investigator_question(@browser, before_question, before_answer)
      answer_investigator_question(@browser, after_question, after_answer)

      save_cmr(@browser)
      @browser.is_text_present(before_answer).should be_true
      @browser.is_text_present(after_answer).should be_true
      @browser.is_element_present("#{:xpath}=//div[@id='#{test[:tab_name]}']//label[text()='#{before_question}']").should be_true
      @browser.is_element_present("#{:xpath}=//div[@id='#{test[:tab_name]}']//label[text()='#{after_question}']").should be_true
    end

  end

end
