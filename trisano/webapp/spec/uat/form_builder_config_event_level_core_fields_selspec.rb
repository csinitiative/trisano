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

  it "should support before and after on the 'Date reported to clinician' field" do
    name = "Results reported to clinician date"
    disease_name = "African Tick Bite Fever"
    before_question = "Before #{name} " + get_unique_name(2)
    after_question = "After #{name} " + get_unique_name(2)
    before_answer = "Before #{name} answer" + get_unique_name(2) 
    after_answer = "After #{name} answer" + get_unique_name(2)     

    create_new_form_and_go_to_builder(@browser, @form_name, disease_name, "All Jurisdictions").should be_true
    add_core_field_config(@browser, name)
    add_question_to_before_core_field_config(@browser, name, {:question_text => before_question, :data_type => "Single line text"})
    add_question_to_after_core_field_config(@browser, name, {:question_text => after_question, :data_type => "Single line text"})
    publish_form(@browser)

    create_basic_investigatable_cmr(@browser, @cmr_last_name, disease_name, "Bear River Health Department")
    edit_cmr(@browser)
    @browser.is_text_present(before_question).should be_true
    @browser.is_text_present(name).should be_true
    @browser.is_text_present(after_question).should be_true
    answer_investigator_question(@browser, before_question, before_answer)
    answer_investigator_question(@browser, after_question, after_answer)

    save_cmr(@browser)
    @browser.is_text_present(before_answer).should be_true
    @browser.is_text_present(after_answer).should be_true
    @browser.is_element_present("#{:xpath}=//div[@id='reporting_tab']//label[text()='#{before_question}']").should be_true
  end

end
