require File.dirname(__FILE__) + '/spec_helper'

# $dont_kill_browser = true

describe 'Form Builder Admin Delete Element Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) + " fu-uat"
    @cmr_last_name = get_unique_name(1) + " fu-uat"
    @tab_name = get_unique_name(2)  + " tab fu-uat"
    @section_name = get_unique_name(2)  + " section fu-uat"
    @question_text = get_unique_name(2)  + " question fu-uat"
    @value_set_question_text = get_unique_name(2)  + " question fu-uat"
    @value_set_name = get_unique_name(2)  + " vs fu-uat"
    @value_set_value_one = get_unique_name(2)  + " vsv fu-uat"
    @value_set_value_two = get_unique_name(2)  + " vsv fu-uat"
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @tab_name = nil
    @section_name = nil
    @question_text = nil
    @value_set_question_text = nil
    @value_set_name = nil
    @value_set_value_one = nil
    @value_set_value_two = nil
  end
  
  it 'should handle standard follow-ups.' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions")
    
    add_view(@browser, @tab_name)
    add_section_to_view(@browser, "Default View", @section_name)
    add_question_to_view(@browser, "Default View", {:question_text => @question_text, :data_type => "Single line text"})
    add_question_to_view(@browser, "Default View", {:question_text => @value_set_question_text, :data_type => "Drop-down select list"})
    
    # Could use a value set helper
    @browser.click "link=Add value set"
    wait_for_element_present("new-value-set-form")
    @browser.type "value_set_element_name", @value_set_name
    @browser.click "link=Add a value"
    @browser.click "link=Add a value"
    wait_for_element_present("value_set_element_new_value_element_attributes__name")
    @browser.type "value_set_element_new_value_element_attributes__name", @value_set_value_one
    @browser.type "document.forms['value-set-element-new-form'].elements['value_set_element[new_value_element_attributes][][name]'][1]",@value_set_value_two
    @browser.click "value_set_element_submit"
    wait_for_element_not_present("new-value-set-form")
    
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department")
    edit_cmr(@browser)
    
    @browser.is_text_present(@tab_name).should be_true
    @browser.is_text_present(@section_name).should be_true
    @browser.is_text_present(@question_text).should be_true
    @browser.is_text_present(@value_set_value_one).should be_true
    @browser.is_text_present(@value_set_value_two).should be_true
    
    click_nav_forms(@browser)
    click_build_form(@browser, @form_name)
    
    delete_view(@browser, @tab_name)
    delete_section(@browser, @section_name)
    delete_question(@browser, @question_text)
    delete_value_set(@browser, @value_set_name)
    
    publish_form(@browser)
    click_nav_cmrs(@browser)
    click_resource_edit(@browser, "cmrs", @cmr_last_name)
   
    @browser.is_text_present(@tab_name).should be_false
    @browser.is_text_present(@section_name).should be_false
    @browser.is_text_present(@question_text).should be_false
    @browser.is_text_present(@value_set_value_one).should be_false
    @browser.is_text_present(@value_set_value_two).should be_false
    
  end
    
end