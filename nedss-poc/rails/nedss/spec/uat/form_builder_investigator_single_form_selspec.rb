require File.dirname(__FILE__) + '/spec_helper'

describe "Form Builder Investigator Single Form" do
  
  it "should create a single test form" do
    @browser.open "/nedss"
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load "30000"

    unless @browser.is_text_present "Single_Form_Test"
      @browser.click "link=New form"
      @browser.wait_for_page_to_load "30000"
      @browser.type "form_name", "Single_Form_Test"
      @browser.type "form_description", "First AIDS Form"
      @browser.select "form_disease_id", "label=AIDS"
      @browser.click "form_submit"
      @browser.wait_for_page_to_load "30000"
      @browser.click "link=Form Builder"
      @browser.wait_for_page_to_load "30000"

      @browser.click "link=Add a question"
      wait_for_element_present("new-question-form")
      @browser.type "question_question_text", "Single-line text"
      @browser.select "question_data_type", "label=Single line text"
      @browser.type "question_size", "5"
      @browser.click "question_submit"
      wait_for_element_not_present("new-question-form")
      @browser.click "link=Add a question"
      wait_for_element_present("new-question-form")
      @browser.type "question_question_text", "Multi-line text"
      @browser.select "question_data_type", "label=Multi-line text"
      @browser.click "question_submit"
      wait_for_element_not_present("new-question-form")
      @browser.click "link=Add a question"
      wait_for_element_present("new-question-form")
      @browser.type "question_question_text", "Drop Down"
      @browser.select "question_data_type", "label=Drop-down select list"
      @browser.click "question_submit"
      wait_for_element_not_present("new-question-form")
      @browser.click "link=Add value set"
      wait_for_element_present("new-value-set-form")
      @browser.type "value_set_element_name", "Drop down values"
      @browser.click "link=Add a value"
      @browser.click "link=Add a value"
      @browser.click "link=Add a value"
      wait_for_element_present("value_set_element_value_attributes__name")
      @browser.type "value_set_element_value_attributes__name", "Value One"
      @browser.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][1]", "Value Two"
      @browser.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][2]", "Value Three"
      @browser.click "value_set_element_submit"
      wait_for_element_not_present("new-value-set-form")
      @browser.click "link=Add a question"
      wait_for_element_present("new-question-form")
      @browser.type "question_question_text", "Check boxes"
      @browser.select "question_data_type", "label=Checkboxes"
      @browser.click "question_submit"
      wait_for_element_not_present("new-question-form")
      @browser.click "link=Add value set"
      wait_for_element_present("new-value-set-form")
      @browser.type "value_set_element_name", "Check box values"
      @browser.click "link=Add a value"
      @browser.click "link=Add a value"
      @browser.click "link=Add a value"
      wait_for_element_present("value_set_element_value_attributes__name")
      @browser.type "value_set_element_value_attributes__name", "First Value"
      @browser.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][1]", "Second Value"
      @browser.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][2]", "Third Value"
      @browser.click "value_set_element_submit"
      wait_for_element_not_present("new-value-set-form")
      @browser.click "//input[@value='Publish']"
      @browser.wait_for_page_to_load "30000"
      @browser.is_text_present("Form was successfully published").should be_true
    end
  end

  it "Should create a test CMR" do
    @browser.click "link=New CMR"
    @browser.wait_for_page_to_load "30000"
    @browser.type "event_active_patient__active_primary_entity__person_last_name", "Doe"
    @browser.type "event_active_patient__active_primary_entity__person_first_name", "John"
    @browser.click "//ul[@id='tabs']/li[2]/a/em"
    @browser.select "event_disease_disease_id", "label=AIDS"
    @browser.click "//ul[@id='tabs']/li[6]/a/em"
    @browser.select "event_event_status_id", "label=Under Investigation"
    @browser.click "event_submit"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("CMR was successfully created").should be_true
  end

  it "should render one form." do
    @browser.click "link=Edit"
    @browser.wait_for_page_to_load "30000"
    @browser.get_xpath_count("//ul[@id='sub_form_tabs']/li").should eql("1")
  end

  it "should save entered data." do
    @browser.click "//ul[@id='tabs']/li[7]/a/em"
    @browser.type "event_answers_1_text_answer", "One"
    @browser.type "event_answers_2_text_answer", "Two"
    @browser.select "event_answers_3_text_answer", "label=Value Three"
    @browser.click "event_answers__4_check_box_answer_1"
    @browser.click "event_answers__4_check_box_answer_2"
    @browser.click "event_answers__4_check_box_answer_3"
    @browser.click "event_submit"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("CMR was successfully updated").should be_true
  end

  it "should maintain values on edit" do
    @browser.click "link=Edit"
    @browser.wait_for_page_to_load "30000"
    @browser.click "//ul[@id='tabs']/li[7]/a/em"
    @browser.get_value("event_answers_1_text_answer").should eql("One")
    @browser.get_value("event_answers_2_text_answer").should eql("Two")
    @browser.get_value("event_answers_3_text_answer").should eql("Value Three")
    @browser.is_checked("event_answers__4_check_box_answer_1").should be_true
    @browser.is_checked("event_answers__4_check_box_answer_2").should be_true
    @browser.is_checked("event_answers__4_check_box_answer_3").should be_true
  end
end
