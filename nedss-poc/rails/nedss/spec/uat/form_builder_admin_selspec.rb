require File.dirname(__FILE__) + '/spec_helper'

describe 'Form Builder Admin' do
  
  it 'should create a new form and allow navigation to builder' do
    @browser.open "/nedss/cmrs"
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load "30000"
    @browser.click "link=New form"
    @browser.wait_for_page_to_load "30000"
    @browser.type "form_name", NedssHelper.get_unique_name(4) + " UAT"
    @browser.click "form_submit"
    @browser.wait_for_page_to_load "30000"
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

  it 'should add four questions' do    
    @browser.click "link=Add a question"
    wait_for_element_present("new-question-form")
    @browser.type "question_element_question_attributes_question_text", "Did you go into the tall grass?"
    @browser.select "question_element_question_attributes_data_type", "label=Drop-down select list"
    @browser.click "question_element_submit"    
    wait_for_element_not_present("new-question-form")
    @browser.is_text_present("Did you go into the tall grass?").should be_true
    @browser.click "link=Add a question"
    wait_for_element_present("new-question-form")
    @browser.type "question_element_question_attributes_question_text", "Did you see the tick that got you?"
    @browser.select "question_element_question_attributes_data_type", "label=Drop-down select list"
    @browser.click "question_element_submit"
    wait_for_element_not_present("new-question-form")
    @browser.is_text_present("Did you see the tick that got you?").should be_true
    @browser.click "link=Add a question"    
    wait_for_element_present("new-question-form")
    @browser.type "question_element_question_attributes_question_text", "Describe the tick."
    @browser.select "question_element_question_attributes_data_type", "label=Drop-down select list"
    @browser.click "question_element_submit"    
    wait_for_element_not_present("new-question-form")
    @browser.is_text_present("Describe the tick.").should be_true
    @browser.click "link=Add a question"    
    wait_for_element_present("new-question-form")
    @browser.type "question_element_question_attributes_question_text", "Could you describe the tick?"
    @browser.select "question_element_question_attributes_data_type", "label=Radio buttons"
    @browser.click "question_element_submit"    
    wait_for_element_not_present("new-question-form")
    @browser.is_text_present("Could you describe the tick?").should be_true
  end
  
  it 'should add three value sets' do
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
    @browser.click "link=Add value set"
    wait_for_element_present("new-value-set-form")
    @browser.type "value_set_element_name", "Yes/No"
    @browser.click "link=Add a value"
    @browser.click "link=Add a value"
    wait_for_element_present("value_set_element_new_value_element_attributes__name")
    @browser.type "value_set_element_new_value_element_attributes__name", "Yes"
    @browser.type "document.forms[0].elements['value_set_element[new_value_element_attributes][][name]'][1]", "No"
    @browser.click "value_set_element_submit"
    wait_for_element_not_present("new-value-set-form")    
    @browser.click "link=Add value set"
    wait_for_element_present("new-value-set-form")
    @browser.type "value_set_element_name", "Yes/No"
    @browser.click "link=Add a value"
    @browser.click "link=Add a value"
    wait_for_element_present("value_set_element_new_value_element_attributes__name")
    @browser.type "value_set_element_new_value_element_attributes__name", "Yes"
    @browser.type "document.forms[0].elements['value_set_element[new_value_element_attributes][][name]'][1]", "No"
    @browser.click "value_set_element_submit"
    wait_for_element_not_present("new-value-set-form")
  end
  
  it 'should reorder the last two questions' do
    @browser.click "link=Reorder elements"
    wait_for_element_present("reorder-list")
    @browser.get_eval("nodes = window.document.getElementById(\"reorder-list\").childNodes; thirdItem =nodes[2].id.toString().substring(9); fourthItem =nodes[3].id.toString().substring(9); thirdItem > fourthItem").should == "false"
    @browser.drag_and_drop "//ul[@id='reorder-list']/li[4]", "0,-20"
    @browser.get_eval("nodes = window.document.getElementById(\"reorder-list\").childNodes; thirdItem =nodes[2].id.toString().substring(9); fourthItem =nodes[3].id.toString().substring(9); thirdItem > fourthItem").should == "true"
  end
  
  it 'should edit a value set' do
    
    @browser.click "link=Edit value set"
    wait_for_element_present("edit-value-set-form")
    @browser.is_text_present("Edit Value Set").should be_true
    
    @browser.type "value_set_element_name", "Edited"
    @browser.click "link=Remove"
    @browser.click "link=Remove"
    @browser.click "value_set_element_submit"
    wait_for_element_not_present("edit-value-set-form")
    @browser.is_text_present("Value Set: Edited").should be_true
    @browser.click "link=Edit value set"
    wait_for_element_present("edit-value-set-form")
    
    # Find a better way to sniff out the value we want to edit, XPath or some other method
    @browser.type "document.forms[0].elements[4]", "Edited value"
    
    # Find a better way to sniff out the No radio button
    @browser.check "document.forms[0].elements[6]"
    
    @browser.click "value_set_element_submit"
    wait_for_element_not_present("edit-value-set-form")
    
    @browser.is_text_present("Edited value").should be_true
    @browser.is_text_present("Maybe").should be_false
    @browser.is_text_present("Inactive").should be_true
    
    @browser.click "link=Edit value set"
    wait_for_element_present("edit-value-set-form")
    @browser.click "link=Add a value"
    wait_for_element_present("value_set_element_new_value_element_attributes__name")
    @browser.type "value_set_element_new_value_element_attributes__name", "Added after value"
    @browser.click "value_set_element_submit"
    wait_for_element_not_present("edit-value-set-form")
    @browser.is_text_present("Added after value").should be_true

  end
  
#  it 'should publish' do
#    @browser.click "//input[@value='Publish']"
#    @browser.wait_for_page_to_load "30000"
#    @browser.is_text_present("Form was successfully published").should be_true
#  end
  
#  it 'should have generated a form in the investigator view' do
#    @browser.click "link=New CMR"
#    @browser.wait_for_page_to_load "30000"
#    @browser.is_text_present("Did you go into the tall grass?").should be_true
#  end
  
  
  # Go over to the invetigator side and look for a question
  # Come back to the Form builder, delete and re-publish
  # Go back and look again
  # Should be gone
end


