require File.dirname(__FILE__) + '/spec_helper'

# $dont_kill_browser = true

describe 'Form Builder Admin Short Name' do
  
  before(:all) do
    @form_name = get_unique_name(2) + " short-uat"
    @original_question_text = get_unique_name(2)  + " question short-uat"
    @short_name_text = get_unique_name(2)  + " sn"
  end
  
  after(:all) do
    @form_name = nil
    @original_question_text = nil
  end
  
  it 'should allow for short name entry' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions").should be_true
    add_question_to_view(@browser, "Default View", { :question_text => @original_question_text,
        :data_type => "Single line text", 
        :short_name => @short_name_text
      }).should be_true

    @browser.is_text_present(@short_name_text).should be_true
    
  end
    
end