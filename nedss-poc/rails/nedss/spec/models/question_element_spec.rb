require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionElement do
  before(:each) do
    @question_element = QuestionElement.new
  end

  it "should be valid" do
    @question_element.should be_valid
  end
  
  it "should determine if it is multi-valued" do
    pending
  end
  
  it "should determine if it is multi-valued and empty" do
    pending
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should bootstrap the question" do
      section_element = SectionElement.create({:form_id => 1, :name => "Section 1"})
      
      question_element = QuestionElement.new({
          :parent_element_id => section_element.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text"}
        })
        
      saved = question_element.save_and_add_to_form
      saved.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      retrieved_question_element.question.should_not be_nil
      retrieved_question_element.question.question_text.should eql("Did you eat the fish?")
    end
    
    it "should fail if the associated question is not valid" do
      section_element = SectionElement.create({:form_id => 1, :name => "Section 1"})
      
      question_element = QuestionElement.new({
          :parent_element_id => section_element.id,
          :question_attributes => {:data_type => "single_line_text"}
        })
      
      saved = question_element.save_and_add_to_form
      saved.should be_nil
      
      begin
        retrieved_question_element = FormElement.find(question_element.id)
      rescue
        # No-op
      ensure
        retrieved_question_element.should be_nil
      end
    end
    
    it "should be receive a tree id" do
      pending
    end
    
  end
  
  describe "when added to the library" do
    
    it "should have a tree id" do
      pending
    end
    
    it "should be be a template" do
      pending
    end
    
    it "should be a copy of the question it was created from" do
      pending
    end
    
  end
  
end
