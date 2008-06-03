require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionElement do
  before(:each) do
    @question_element = QuestionElement.new
  end

  it "should be valid" do
    @question_element.should be_valid
  end
  
  it "should determine if it is multi-valued" do
    
    question_element = QuestionElement.new({:question_attributes => {:data_type => "single_line_text"}})
    question_element.is_multi_valued?.should be_false
    
    question_element.update_attributes({:question_attributes => {:data_type => "multi_line_text"}})
    question_element.is_multi_valued?.should be_false
    
    question_element.update_attributes({:question_attributes => {:data_type => "drop_down"}})
    question_element.is_multi_valued?.should be_true
    
    question_element.update_attributes({:question_attributes => {:data_type => "radio_button"}})
    question_element.is_multi_valued?.should be_true
    
    question_element.update_attributes({:question_attributes => {:data_type => "check_box"}})
    question_element.is_multi_valued?.should be_true
    
    question_element.update_attributes({:question_attributes => {:data_type => "date"}})
    question_element.is_multi_valued?.should be_false
    
    question_element.update_attributes({:question_attributes => {:data_type => "phone"}})
    question_element.is_multi_valued?.should be_false
    
  end
  
  it "should determine if it is multi-valued and empty" do
    
    question_element = QuestionElement.new({:tree_id => 1})
    question = Question.new({:data_type => "drop_down", :question_text => "Was it fishy"})
    question_element.question = question
    question_element.save

    question_element.is_multi_valued?.should be_true
    question_element.is_multi_valued_and_empty?.should be_true
    
    follow_up_element = FollowUpElement.new({:tree_id => 1, :name => "Follow it", :condition => "Yes"})
    follow_up_element.save
    question_element.add_child(follow_up_element)
    
    question_element.is_multi_valued_and_empty?.should be_true
    
    value_set_element = ValueSetElement.new({:tree_id => 1, :name => "Y/N"})
    value_set_element.save
    question_element.add_child(value_set_element)

    question_element.is_multi_valued_and_empty?.should be_false
    
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
  
end
