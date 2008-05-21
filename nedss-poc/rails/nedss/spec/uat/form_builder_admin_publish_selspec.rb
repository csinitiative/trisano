require File.dirname(__FILE__) + '/spec_helper'

describe 'Form Builder Admin Publish' do

  it 'should create a new form and allow navigation to builder' do
    @browser.open "/nedss/cmrs"
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load "30000"
    @browser.click "link=New form"
    @browser.wait_for_page_to_load "30000"
    @browser.type "form_name", "African Tick Bite Publish Test"
    @browser.click "form_submit"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Not Published").should be_true
    @browser.click "link=Form Builder"
    @browser.wait_for_page_to_load "30000"
  end
  
  it 'should add a section' do    
    @browser.click "link=Add a section"
    wait_for_element_present("new-section-form")
    @browser.type "section_element_name", "Section 1"
    @browser.click "section_element_submit"
    wait_for_element_not_present("new-section-form")
    @browser.is_text_present("Section configuration was successfully created.").should be_true
  end

  it 'should add two questions' do
    @browser.click "link=Add a question"
    wait_for_element_present("new-question-form")
    @browser.type "question_element_question_attributes_question_text", "Did you go into the tall grass?"
    @browser.select "question_element_question_attributes_data_type", "label=Drop-down select list"
    @browser.click "question_element_submit"    
    wait_for_element_not_present("new-question-form")
    @browser.is_text_present("Did you go into the tall grass?").should be_true
    @browser.click "link=Add a question"
    wait_for_element_present("new-question-form")
    @browser.type "question_element_question_attributes_question_text", "Describe the tick."
    @browser.select "question_element_question_attributes_data_type", "label=Multi-line text"
    @browser.click "question_element_submit"    
    wait_for_element_not_present("new-question-form")
    @browser.is_text_present("Describe the tick.").should be_true
  end
  
  it 'should add one value set' do
    @browser.click "link=Add value set"
    wait_for_element_present("new-value-set-form")
    @browser.type "value_set_element_name", "Yes/No/Maybe"
    @browser.click "link=Add a value"
    @browser.click "link=Add a value"
    @browser.click "link=Add a value"
    wait_for_element_present("value_set_element_new_value_element_attributes__name")
    @browser.type "value_set_element_new_value_element_attributes__name", "Yes"
    @browser.type "document.forms[0].elements['value_set_element[new_value_element_attributes][][name]'][1]", "No"
    @browser.type "document.forms[0].elements['value_set_element[new_value_element_attributes][][name]'][2]", "Maybe"
    @browser.click "value_set_element_submit"
    wait_for_element_not_present("new-value-set-form")
    @browser.is_text_present("Yes/No/Maybe").should be_true
  end
  
  it 'should publish' do
    @browser.click "//input[@value='Publish']"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("Form was successfully published").should be_true
  end
end
