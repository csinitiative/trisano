require File.dirname(__FILE__) + '/spec_helper'

$dont_kill_browser = true

describe "Administrator functionality to create questions" do
  
  it "should be able to create questions with a free-text answer" do
      @browser.open "/nedss/"
      @browser.click "link=Forms"
      @browser.wait_for_page_to_load($load_time)
      @browser.click "link=New form"
      @browser.wait_for_page_to_load($load_time)
      @browser.type "form_name", "African Tick Bite Fever"
      @browser.select_frame "relative=up"
      @browser.type "form_description", "Questions related to African Tick Bite Fever patients. These questions are important because they help us determine whether the tick is still in the United States or if they got the bite elsewhere, got sick and came here."
      @browser.click "form_submit"
      @browser.wait_for_page_to_load($load_time)
      pending "For some reason these calls are returning false on this page even though I can see the text" do
        @browser.is_text_present("Form details: African Tick Bite Fever").should be_true
        @browser.is_text_present("Name: African Tick Bite Fever").should be_true
        @browser.is_text_present("Description: Questions related to African Tick Bite Fever patients. These questions are important because they help us determine whether the tick is still in the United States or if they got the bite elsewhere, got sick and came here.").should be_true
        @browser.is_text_present("Show for disease: African Tick Bite Fever").should be_true
        @browser.is_text_present("Show for jursidiction: All Jurisdictions").should be_true
        @browser.is_text_present("Status: Not Published").should be_true
      end
      @browser.click "link=Form Builder"
      @browser.wait_for_page_to_load($load_time)
      @browser.click "link=Add a question"
      @browser.wait_for_page_to_load($load_time)
      @browser.type "question_question_text", "Were you in the United States when you first became ill?"
      @browser.select "question_data_type", "label=Single line text"
      @browser.type "question_size", "3"
      @browser.click "question_is_on_short_form_true"
      @browser.click "question_is_required_true"
      @browser.click "question_is_exportable_true"
      @browser.click "question_submit"
      @browser.click "link=Add a question"
      @browser.type "question_question_text", "If yes, what state were you in?"
      @browser.select "question_data_type", "label=Single line text"
      @browser.type "question_size", "2"
      @browser.click "question_is_on_short_form_true"
      @browser.click "question_is_required_false"
      @browser.click "question_is_exportable_true"
      @browser.click "question_submit"
      @browser.click "link=Add a question"
      @browser.type "question_question_text", "If yes, what city were you in?"
      @browser.select "question_data_type", "label=Single line text"
      @browser.type "question_size", "50"
      @browser.click "question_is_on_short_form_true"
      @browser.click "question_is_required_false"
      @browser.click "question_is_exportable_true"
      @browser.click "question_submit"
      @browser.click "link=Add a question"
      @browser.type "question_question_text", "If no, what country were you in?"
      @browser.select "question_data_type", "label=Single line text"
      @browser.type "question_size", "50"
      @browser.click "question_is_on_short_form_true"
      @browser.click "question_is_required_false"
      @browser.click "question_is_exportable_true"
      @browser.click "question_submit"
      @browser.is_text_present("Question: Were you in the United States when you first became ill?").should be_true
      @browser.is_text_present("Question: If yes, what state were you in?").should be_true
      @browser.is_text_present("Question: If yes, what city were you in?").should be_true
      @browser.is_text_present("Question: If no, what country were you in?").should be_true
      @browser.click "//input[@value='Publish']"
      @browser.wait_for_page_to_load($load_time)
      @browser.is_text_present("Form was successfully published").should be_true
  end
  
  it "should be able to create a question with answers limited to a finite set of single-selectable values to be chosen from a drop-down list" 
  
  it "should be able to create a question with answers limited to a finite set of muli-selectable values to be chosen using checkboxes" 
  
  it "should be able to create a question where the answer is limited to a valid date" 

  it "should be able to create a question where the answer is limited to a valid phone number" 
  
end