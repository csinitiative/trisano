require File.dirname(__FILE__) + '/spec_helper'

describe 'Form Builder Admin' do
  
  before(:all) do
    @form_name = NedssHelper.get_unique_name(4) + " fb uat"
    
    @question_to_delete_text = "Describe the tick " + NedssHelper.get_unique_name(4) + " fb uat" 
    @question_to_edit_text = "Can you describe the tick " + NedssHelper.get_unique_name(4) + " fb uat" 
    @question_to_edit_modified_text = "Can you describe the tick edited " + NedssHelper.get_unique_name(4) + " fb uat" 
    @question_to_inactivate_text = "Did you see the tick that got you " + NedssHelper.get_unique_name(4) + " fb uat" 
    
    @user_defined_tab_text = "User-defined tab " + NedssHelper.get_unique_name(3) + " fb uat"
    @user_defined_tab_section_text = "User-defined tab section " + NedssHelper.get_unique_name(3) + " fb uat"
    @user_defined_tab_question_text = "User-defined tab questoin " + NedssHelper.get_unique_name(3) + " fb uat" 
    
    @cmr_last_name = NedssHelper.get_unique_name(2) + " fb uat"
  end
  
  after(:all) do
    @form_name = nil
    @question_to_delete_text = nil
    @question_to_edit_text = nil
    @question_to_edit_modified_text = nil
    @cmr_last_name = nil
  end
  
  it 'should create a new form and allow navigation to builder' do
    @browser.open "/nedss/cmrs"
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load "30000"
    @browser.click "link=New form"
    @browser.wait_for_page_to_load "30000"
    @browser.type "form_name", @form_name
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

  # Debt: The remaining examples had to be combined into one in order to have access
  # to saved IDs across what used to be separate examples.
  # The methods provide some segmentation of all of the activities of the large example.
  it 'should do all this stuff...' do
    
    add_questions
    reorder_elements
    add_value_sets
    edit_value_sets
    add_and_populate_tab
    publish
    
    validate_investigator_rendering
    
    navigate_to_form_edit
    delete_edit_and_inactivate_questions
    
    publish
    
    revalidate_investigator_rendering

  end
end

def add_questions
  @browser.click "link=Add a question"
  wait_for_element_present("new-question-form")
  @browser.type "question_element_question_attributes_question_text", "Did you go into the tall grass?"
  @browser.select "question_element_question_attributes_data_type", "label=Drop-down select list"
  @browser.click "question_element_submit"    
  wait_for_element_not_present("new-question-form")
  @browser.is_text_present("Did you go into the tall grass?").should be_true
  @browser.click "link=Add a question"
  wait_for_element_present("new-question-form")
  @browser.type "question_element_question_attributes_question_text", @question_to_inactivate_text
  @browser.select "question_element_question_attributes_data_type", "label=Drop-down select list"
  @browser.click "question_element_submit"
  wait_for_element_not_present("new-question-form")
  @browser.is_text_present(@question_to_inactivate_text).should be_true
    
  @question_to_inactivate_id = @browser.get_value("id=modified-element")
    
  @browser.click "link=Add a question"    
  wait_for_element_present("new-question-form")
  @browser.type "question_element_question_attributes_question_text", @question_to_delete_text
  @browser.select "question_element_question_attributes_data_type", "label=Multi-line text"
  @browser.click "question_element_submit"    
  wait_for_element_not_present("new-question-form")
  @browser.is_text_present(@question_to_delete_text).should be_true
    
  @question_to_delete_id = @browser.get_value("id=modified-element")
    
  @browser.click "link=Add a question"    
  wait_for_element_present("new-question-form")
  @browser.type "question_element_question_attributes_question_text", @question_to_edit_text
  @browser.select "question_element_question_attributes_data_type", "label=Drop-down select list"
  @browser.click "question_element_submit"    
  wait_for_element_not_present("new-question-form")
  @browser.is_text_present(@question_to_edit_text).should be_true
    
  @question_to_edit_id = @browser.get_value("id=modified-element")
end

def add_value_sets
  @browser.click "link=Add value set"
  wait_for_element_present("new-value-set-form")
  @browser.type "value_set_element_name", "Yes/No/Maybe"
  @browser.click "link=Add a value"
  @browser.click "link=Add a value"
  @browser.click "link=Add a value"
  wait_for_element_present("value_set_element_new_value_element_attributes__name")
  @browser.type "value_set_element_new_value_element_attributes__name", "Yes"
  @browser.type "document.forms['value-set-element-new-form'].elements['value_set_element[new_value_element_attributes][][name]'][1]", "No"
  @browser.type "document.forms['value-set-element-new-form'].elements['value_set_element[new_value_element_attributes][][name]'][2]", "Maybe"
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
  @browser.type "document.forms['value-set-element-new-form'].elements['value_set_element[new_value_element_attributes][][name]'][1]", "No"
  @browser.click "value_set_element_submit"
  wait_for_element_not_present("new-value-set-form")
  @browser.click "link=Add value set"
  wait_for_element_present("new-value-set-form")
  @browser.type "value_set_element_name", "Yes/No"
  @browser.click "link=Add a value"
  @browser.click "link=Add a value"
  wait_for_element_present("value_set_element_new_value_element_attributes__name")
  @browser.type "value_set_element_new_value_element_attributes__name", "Yes"
  @browser.type "document.forms['value-set-element-new-form'].elements['value_set_element[new_value_element_attributes][][name]'][1]", "No"
  @browser.click "value_set_element_submit"
  wait_for_element_not_present("new-value-set-form")
end

def reorder_elements
  @browser.set_speed(500)
  reorderable_section = @browser.get_value("id=question-section")
  @browser.get_eval("nodes = window.document.getElementById(\"#{reorderable_section}\").childNodes; thirdItem =nodes[2].id.toString().substring(9); fourthItem =nodes[3].id.toString().substring(9); thirdItem > fourthItem").should == "false"
  @browser.drag_and_drop "//ul[@id='#{reorderable_section}']/li[4]", "0,-20"
  sleep(2)
  @browser.get_eval("nodes = window.document.getElementById(\"#{reorderable_section}\").childNodes; thirdItem =nodes[2].id.toString().substring(9); fourthItem =nodes[3].id.toString().substring(9); thirdItem > fourthItem").should == "true"
  @browser.set_speed(0)
end

def edit_value_sets
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
    
  @browser.type "document.forms['value-set-element-edit-form'].elements[4]", "Edited value"
  sleep(5)
  @browser.check "document.forms['value-set-element-edit-form'].elements[6]"
    
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

def add_and_populate_tab
  
  @browser.click "link=Add a tab"
  wait_for_element_present("new-view-form")
  @browser.type "view_element_name", @user_defined_tab_text
  @browser.click "view_element_submit"
  wait_for_element_not_present("new-view-form")
  
  @tab_element_id = @browser.get_value("id=modified-element")
  
  @browser.click "id=add-section-#{@tab_element_id}"
  wait_for_element_present("new-section-form")
  @browser.type "section_element_name", @user_defined_tab_section_text
  @browser.click "section_element_submit"
  wait_for_element_not_present("new-section-form")
  @browser.is_text_present("Section configuration was successfully created.").should be_true

  @tab_section_element_id = @browser.get_value("id=modified-element")

  @browser.click "id=add-question-#{@tab_section_element_id}"
  wait_for_element_present("new-question-form")
  @browser.type "question_element_question_attributes_question_text", @user_defined_tab_question_text
  @browser.select "question_element_question_attributes_data_type", "label=Multi-line text"
  @browser.click "question_element_submit"    
  wait_for_element_not_present("new-question-form")
  @browser.is_text_present(@user_defined_tab_question_text).should be_true
  
end

def publish
  @browser.click '//input[@value="Publish"]'
  @browser.wait_for_page_to_load "30000"
  @browser.is_text_present("Form was successfully published").should be_true
end

def validate_investigator_rendering
  @browser.click "link=New CMR"
  @browser.wait_for_page_to_load "30000"
  @browser.type "event_active_patient__active_primary_entity__person_last_name", @cmr_last_name
  @browser.type "event_active_patient__active_primary_entity__person_first_name", "Guy"
  @browser.click "//ul[@id='tabs']/li[2]/a/em"
  @browser.select "event_disease_disease_id", "label=African Tick Bite Fever"
  @browser.click "//ul[@id='tabs']/li[6]/a/em"
  @browser.select "event_active_jurisdiction_secondary_entity_id", "label=Bear River Health Department"
  @browser.select "event_event_status_id", "label=Under Investigation"
  @browser.click "event_submit"
  @browser.wait_for_page_to_load "30000"

  @browser.click "link=Edit"
  @browser.wait_for_page_to_load "30000"

  @browser.is_text_present(@question_to_delete_text).should be_true
  @browser.is_text_present(@question_to_edit_text).should be_true
  @browser.is_text_present(@question_to_inactivate_text).should be_true
  @browser.is_text_present(@question_to_edit_modified_text).should be_false
  @browser.is_text_present(@user_defined_tab_text).should be_true
  @browser.is_text_present(@user_defined_tab_section_text).should be_true
  @browser.is_text_present(@user_defined_tab_question_text).should be_true
  
end

def navigate_to_form_edit
  @browser.click "link=Forms"
  @browser.wait_for_page_to_load "30000"
  NedssHelper.click_build_form(@browser, @form_name)
end

def delete_edit_and_inactivate_questions
  @browser.click "id=delete-question-#{@question_to_delete_id}"
  wait_for_element_present("modified-element")
    
  @browser.click "id=edit-question-#{@question_to_edit_id}"
  wait_for_element_present("edit-question-form")
  @browser.type "question_element_question_attributes_question_text", @question_to_edit_modified_text
  @browser.click "question_element_submit"    
  wait_for_element_not_present("edit-question-form")
  @browser.is_text_present(@question_to_edit_text).should be_false
  @browser.is_text_present(@question_to_edit_modified_text).should be_true
    
  @browser.click "id=edit-question-#{@question_to_inactivate_id}"
  wait_for_element_present("edit-question-form")
  @browser.click "question_element_is_active_false"
  @browser.click "question_element_submit"    
  wait_for_element_not_present("edit-question-form")
end

def revalidate_investigator_rendering
  @browser.click "link=View CMRs"
  @browser.wait_for_page_to_load "30000"
  NedssHelper.click_resource_edit(@browser, "cmrs", @cmr_last_name)
  @browser.is_text_present(@question_to_delete_text).should be_false
  @browser.is_text_present(@question_to_edit_text).should be_false
  @browser.is_text_present(@question_to_inactivate_text).should be_false
  @browser.is_text_present(@question_to_edit_modified_text).should be_true
end
