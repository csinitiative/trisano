require File.dirname(__FILE__) + '/spec_helper'

# $dont_kill_browser = true

describe 'Form Builder Admin Question Alignment Functionality' do
  
  before(:all) do
    @form_name = get_unique_name(2) + " fu-uat"
    @cmr_last_name = get_unique_name(1) + " fu-uat"
    @question_text = get_unique_name(2)  + " question fu-uat"
  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil
    @question_text = nil
  end
  
  it 'should handle standard follow-ups.' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions")
    @question_id = add_question_to_view(@browser, "Default View", {
        :question_text => @question_text, 
        :data_type => "Single line text", 
        :style => "Horizontal"
      }
    )
    
    publish_form(@browser)
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department")
    edit_cmr(@browser)
    
    @browser.is_text_present(@question_text).should be_true
    published_question_id = get_question_investigate_div_id(@browser, @question_text)
    @browser.get_eval("window.document.getElementById(\"question_investigate_#{published_question_id}\").attributes[0].nodeValue").should eql("horiz")
  end
    
end