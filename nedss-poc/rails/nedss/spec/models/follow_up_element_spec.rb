require File.dirname(__FILE__) + '/../spec_helper'

describe FollowUpElement do
  before(:each) do
    @follow_up_element = FollowUpElement.new
    @follow_up_element.form_id = 1
    @follow_up_element.name = "Follow up"
    @follow_up_element.condition = "Yes"
  end

  it "should be valid" do
    @follow_up_element.should be_valid
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should be a child of the question provided" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.save_and_add_to_form
      @follow_up_element.parent_id.should_not be_nil
      question_element = FormElement.find(question_element.id)
      question_element.children[0].id.should == @follow_up_element.id 
    end
    
    it "should be receive a tree id" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.save_and_add_to_form
      @follow_up_element.tree_id.should_not be_nil
      @follow_up_element.tree_id.should eql(question_element.tree_id)
    end
    
  end
  
end
