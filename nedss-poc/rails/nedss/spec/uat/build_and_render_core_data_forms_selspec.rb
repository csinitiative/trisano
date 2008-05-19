require File.dirname(__FILE__) + '/spec_helper'
  
describe "Using Form Builder to manipulte core-data fields" do
  
  it "should create a form using core data fields" do
    @browser.open "/nedss/"
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load "30000"

    unless @browser.is_text_present "Core Data Form"
      @browser.click "link=New form"
      @browser.wait_for_page_to_load "30000"
      @browser.type "form_name", "Core Data Form"
      @browser.select "form_disease_id", "label=Amebiasis"
      @browser.click "form_submit"
      @browser.wait_for_page_to_load "30000"

      @browser.click "link=Form Builder"
      @browser.wait_for_page_to_load "30000"

      @browser.click "link=Add a core data element"
      wait_for_element_present("new-question-form")
      @browser.type "question_question_text", "Middle Name:"
      @browser.select "question_core_data_attr", "label=Patient Middle Name"
      @browser.click "question_submit"
      wait_for_element_not_present("new-question-form")

      @browser.click "link=Add a core data element"
      wait_for_element_present("new-question-form")
      @browser.type "question_question_text", "DOB:"
      @browser.select "question_core_data_attr", "label=Patient Birth Date"
      @browser.click "question_submit"
      wait_for_element_not_present("new-question-form")

      @browser.click "//input[@value='Publish']"
      @browser.wait_for_page_to_load "30000"
      @browser.is_text_present("Form was successfully published").should be_true
    end
  end

  it "Should create a new CMR" do
    @browser.click "link=New CMR"
    @browser.wait_for_page_to_load "30000"
    @browser.type "event_active_patient__active_primary_entity__person_last_name", "Green"
    @browser.type "event_active_patient__active_primary_entity__person_first_name", "Joe"
    @browser.click "//ul[@id='tabs']/li[2]/a/em"
    @browser.select "event_disease_disease_id", "label=Amebiasis"
    @browser.click "//ul[@id='tabs']/li[6]/a/em"
    @browser.select "event_event_status_id", "label=Under Investigation"
    @browser.click "event_submit"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("CMR was successfully created").should be_true
  end

  it "should render and save core-data fields" do
    @browser.click "link=Edit"
    @browser.wait_for_page_to_load "30000"
    @browser.click "//ul[@id='tabs']/li[7]/a/em"
    @browser.type "event_active_patient__active_primary_entity__person__middle_name", "Quincy"
    @browser.type "event_active_patient__active_primary_entity__person__birth_date", "02-28-1950"
    @browser.click "event_submit"
    @browser.wait_for_page_to_load "30000"
    @browser.is_text_present("CMR was successfully updated").should be_true
  end

  it "should maintain values on re-edit" do
    @browser.click "link=Edit"
    @browser.wait_for_page_to_load "30000"
    @browser.click "//ul[@id='tabs']/li[7]/a/em"
    @browser.get_value("event_active_patient__active_primary_entity__person__middle_name").should eql("Quincy")
    @browser.get_value("event_active_patient__active_primary_entity__person__birth_date").should eql("1950-02-28")
  end
end
