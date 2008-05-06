require File.dirname(__FILE__) + '/spec_helper'

describe 'Form Builder Admin' do

  it 'should create a new form and allow navigation to builder' do
    @browser.open "/nedss/cmrs"
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load "30000"
    @browser.click "link=New form"
    @browser.wait_for_page_to_load "30000"
    @browser.type "form_name", "African Tick Bite Test"
    @browser.click "form_submit"
    @browser.wait_for_page_to_load "30000"
    @browser.click "link=Form Builder"
    @browser.wait_for_page_to_load "30000"
  end
  
  it 'should add four questions' do
    @browser.click "link=Add a question"
    sleep 2
    @browser.is_element_present("new-question-form").should be_true
    @browser.type "question_question_text", "Did you go into the tall grass?"
    @browser.select "question_data_type", "label=Drop-down select list"
    @browser.click "question_submit"
    sleep 2
    @browser.is_element_present("new-question-form").should be_false
    @browser.is_text_present("Did you go into the tall grass?").should be_true
    @browser.click "link=Add a question"
    sleep 2
    @browser.is_element_present("new-question-form").should be_true
    @browser.type "question_question_text", "Did you see the tick that got you?"
    @browser.select "question_data_type", "label=Radio buttons"
    @browser.click "question_submit"
    sleep 2
    @browser.is_element_present("new-question-form").should be_false
    @browser.is_text_present("Did you see the tick that got you?").should be_true
    @browser.click "link=Add a question"
    sleep 2
    @browser.is_element_present("new-question-form").should be_true
    @browser.type "question_question_text", "Describe the tick."
    @browser.select "question_data_type", "label=Multi-line text"
    @browser.click "question_submit"
    sleep 2
    @browser.is_element_present("new-question-form").should be_false
    @browser.is_text_present("Describe the tick.").should be_true
    @browser.click "link=Add a question"
    sleep 2
    @browser.is_element_present("new-question-form").should be_true
    @browser.type "question_question_text", "Could you describe the tick?"
    @browser.select "question_data_type", "label=Radio buttons"
    @browser.click "question_submit"
    sleep 2
    @browser.is_element_present("new-question-form").should be_false
    @browser.is_text_present("Could you describe the tick?").should be_true
  end
  
  it 'should add three value sets' do
    @browser.click "link=Add value set"
    sleep 2
    @browser.is_element_present("new-value-set-form").should be_true
    @browser.type "value_set_element_name", "Yes/No/Maybe"
    @browser.click "link=Add a value"
    @browser.click "link=Add a value"
    @browser.click "link=Add a value"
    sleep 2
    @browser.type "value_set_element_value_attributes__name", "Yes"
    @browser.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][1]", "No"
    @browser.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][2]", "Maybe"
    @browser.click "value_set_element_submit"
    sleep 2
    @browser.is_element_present("new-value-set-form").should be_false
    @browser.is_text_present("Yes/No/Maybe").should be_true
    @browser.click "link=Add value set"
    sleep 2
    @browser.is_element_present("new-value-set-form").should be_true
    @browser.type "value_set_element_name", "Yes/No"
    @browser.click "link=Add a value"
    @browser.click "link=Add a value"
    sleep 2
    @browser.type "value_set_element_value_attributes__name", "Yes"
    @browser.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][1]", "No"
    @browser.click "value_set_element_submit"
    sleep 2
    @browser.is_element_present("new-value-set-form").should be_false
    @browser.click "link=Add value set"
    sleep 2
    @browser.is_element_present("new-value-set-form").should be_true
    @browser.type "value_set_element_name", "Yes/No"
    @browser.click "link=Add a value"
    @browser.click "link=Add a value"
    sleep 2
    @browser.type "value_set_element_value_attributes__name", "Yes"
    @browser.type "document.forms[0].elements['value_set_element[value_attributes][][name]'][1]", "No"
    @browser.click "value_set_element_submit"
    sleep 2
    @browser.is_element_present("new-value-set-form").should be_false
  end
  
  it 'should reorder the last two questions' do
    @browser.click "link=Reorder questions"
    sleep 2
    @browser.get_eval("nodes = window.document.getElementById(\"reorder-list\").childNodes; thirdItem =nodes[2].id.toString().substring(9); fourthItem =nodes[3].id.toString().substring(9); thirdItem > fourthItem").should == "false"
    @browser.drag_and_drop "//ul[@id='reorder-list']/li[4]", "0,-20"
    @browser.get_eval("nodes = window.document.getElementById(\"reorder-list\").childNodes; thirdItem =nodes[2].id.toString().substring(9); fourthItem =nodes[3].id.toString().substring(9); thirdItem > fourthItem").should == "true"
  end
  
end


