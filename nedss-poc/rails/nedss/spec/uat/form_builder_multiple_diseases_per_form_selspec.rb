require File.dirname(__FILE__) + '/spec_helper'

describe 'form builder associating a form with multiple diseases' do

  before(:all) do
    @form_name = get_unique_name(4) + " fb uat"
    @question_1 = "One: " + get_unique_name(4) + " fb uat" 
    @question_2 = "Two: " + get_unique_name(4) + " fb uat" 
    @disease_1 = "Anthrax"
    @disease_2 = "Dengue"
    @cmr_last_name_1 = get_unique_name(1) + " fb uat"
    @cmr_last_name_2 = get_unique_name(1) + " fb uat"
  end

  it "should create a new form associated with #{@disease_1} and #{@disease_2}" do
    create_new_form_and_go_to_builder(@browser, @form_name, [@disease_1, @disease_2], "All Jurisdictions").should be_true
    add_question_to_view(@browser, "Default View", {:question_text => @question_1, :data_type => "Single line text"})
    add_question_to_view(@browser, "Default View", {:question_text => @question_2, :data_type => "Single line text"})

    publish_form(@browser)
    @browser.is_text_present("Form was successfully published").should be_true
    @browser.is_text_present(@disease_1).should be_true
    @browser.is_text_present(@disease_2).should be_true

    create_basic_investigatable_cmr(@browser, @cmr_last_name_1, @disease_1, "Bear River Health Department")
    edit_cmr(@browser)
    @browser.is_text_present(@question_1).should be_true
    @browser.is_text_present(@question_2).should be_true

    create_basic_investigatable_cmr(@browser, @cmr_last_name_2, @disease_2, "Bear River Health Department")
    edit_cmr(@browser)
    @browser.is_text_present(@question_1).should be_true
    @browser.is_text_present(@question_2).should be_true
  end
end
