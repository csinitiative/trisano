require File.dirname(__FILE__) + './spec_helper'

# $dont_kill_browser = true

describe 'Form Builder Admin' do
  
  before(:all) do
  end
  
  after(:all) do
  end
  
  it 'create large form' do
    create_new_form_and_go_to_builder(@browser, "Benchmark Form", "African Tick Bite Fever", "All Jurisdictions")
    
    (1..10).each do |section_count|
      section_name = "Section #{section_count}"
      add_section_to_view(@browser, 'Default View', section_name)
      
      (1..5).each do |question_count|
        question_text = "Single line question #{section_count} -- #{question_count}"
        add_question_to_section(@browser, section_name, {
            :question_text => question_text, 
            :data_type => "Single line text"}
        )
      end
      
      (1..5).each do |question_count|
        question_text = "Drop-down select question #{section_count} -- #{question_count}"
        add_question_to_section(@browser, section_name, {
            :question_text => question_text, 
            :data_type => "Drop-down select list"}
        )
        add_value_set_to_question(@browser, question_text, "Yes/No/Maybe", "Yes", "No", "Maybe") 
      end  
    end
    
  end
end