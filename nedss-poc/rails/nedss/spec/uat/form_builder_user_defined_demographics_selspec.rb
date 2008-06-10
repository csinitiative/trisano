require File.dirname(__FILE__) + '/spec_helper'
require 'hpricot'
 
describe 'Form Builder User-defined Demographics' do
  
  it 'should create a new form with a new demographic question' do
    @browser.open "/nedss/forms"
    @browser.click "link=New form"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "form_name", "Demo graphics User Defined Question"
    @browser.select "form_disease_id", "label=Yellow fever"
    @browser.select "form_jurisdiction_id", "label=Central Utah Public Health Department"
    @browser.click "form_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.click "link=Form Builder"
    @browser.wait_for_page_to_load($load_time)
    @browser.click "link=Add a core tab configuration"
    wait_for_element_present("new-core-view-form")
    @browser.select "core_view_element_name", "label=Demographics"
    @browser.click "core_view_element_submit"
    wait_for_element_not_present("new-core-view-form")
    @browser.click("name=add-question")
    wait_for_element_present("new-question-form")
    @browser.type "question_element_question_attributes_question_text", "Current employer:"
    @browser.select "question_element_question_attributes_data_type", "label=Single line text"
    @browser.click "question_element_submit"
    wait_for_element_not_present("new-question-form")
    @browser.click "link=Add a question"
    wait_for_element_present("new-question-form")
    @browser.type "question_element_question_attributes_question_text", "Standard question?"
    @browser.select "question_element_question_attributes_data_type", "label=Single line text"
    @browser.click "question_element_submit"
    wait_for_element_not_present("new-question-form")
    @browser.click "//input[@value='Publish']"
    @browser.wait_for_page_to_load($load_time)
  end
  
  it 'should create a new CMR' do
    @browser.click "link=New CMR"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "event_active_patient__active_primary_entity__person_last_name", "Yellow"
    @browser.type "event_active_patient__active_primary_entity__person_first_name", "Demo"
    @browser.click "//ul[@id='tabs']/li[2]/a/em"
    @browser.select "event_disease_disease_id", "label=Yellow fever"
    @browser.click "//ul[@id='tabs']/li[6]/a/em"
    @browser.select "event_active_jurisdiction_secondary_entity_id", "label=Central Utah Public Health Department"
    @browser.select "event_event_status_id", "label=Under Investigation"
    @browser.click "event_submit"
    @browser.wait_for_page_to_load($load_time)
  end
  
  it 'should allow form answers to be saved' do
    @browser.click "link=Edit"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "event_answers_1_text_answer", "csi-employment"
    @browser.click "event_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.click "link=Edit"
    @browser.wait_for_page_to_load($load_time)
    @browser.get_value("css=input[class=demographic-supplemental]").should == "csi-employment"
  end
  
end
