require File.dirname(__FILE__) + '/../spec_helper'

describe Question do
  before(:each) do
    @section_element = SectionElement.create
    @question = Question.new(:parent_id => @section_element.id)
  end

  it "should be valid" do
    @question.should be_valid
  end
  

  describe "when created" do
    
    it "should bootstrap the question element" do
      @question.save!
      @question.question_element_id.should_not be_nil
      
      question_element = FormElement.find(@question.question_element_id)
      question_element.should_not be_nil
      
    end
    
  end
  
end
