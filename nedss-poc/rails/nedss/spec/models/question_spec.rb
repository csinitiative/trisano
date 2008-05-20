require File.dirname(__FILE__) + '/../spec_helper'

describe Question do
  before(:each) do
    @question = Question.new
    @question.question_text = "Did you eat the fish?"
    @question.data_type = "single_line_text"
  end

  it "should be valid" do
    @question.should be_valid
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should bootstrap the question element" do
      section_element = SectionElement.create({:form_id => 1, :name => "Section 1"})
      @question.save_and_add_to_form(section_element.id)
      
      @question.question_element_id.should_not be_nil
      question_element = FormElement.find(@question.question_element_id)
      question_element.should_not be_nil
    end
    
  end
  
end
