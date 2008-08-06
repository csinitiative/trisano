require File.dirname(__FILE__) + '/../spec_helper'

describe ValueSetElement do
  before(:each) do
    @value_set_element = ValueSetElement.new
    @value_set_element.name = "Test"
  end

  it "should be valid" do
    @value_set_element.should be_valid
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should be a child of the question provided" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @value_set_element.form_id = question_element.form_id
      @value_set_element.parent_element_id = question_element.id
      @value_set_element.save_and_add_to_form
      @value_set_element.parent_id.should_not be_nil
      question_element = FormElement.find(question_element.id)
      question_element.children[0].id.should == @value_set_element.id 
    end
    
    it "should be receive a tree id" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @value_set_element.form_id = question_element.form_id
      @value_set_element.parent_element_id = question_element.id
      @value_set_element.save_and_add_to_form
      @value_set_element.tree_id.should_not be_nil
      @value_set_element.tree_id.should eql(question_element.tree_id)
    end
    
  end
end
