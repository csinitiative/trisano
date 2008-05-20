require File.dirname(__FILE__) + '/../spec_helper'

describe FormElement do
  before(:each) do
    @form_element = FormElement.new
  end

  it "should be valid" do
    @form_element.should be_valid
  end
end

describe "Quesiton FormElement" do
  before(:each) do
    @form_element = QuestionElement.create
  end

  it "should destroy associated question on destroying with dependencies" do
    question = Question.create({:question_text => "Que?", :data_type => "single_line_text"})
    form_element_id = @form_element.id
    question_id = question.id
    @form_element.question = question
    
    FormElement.exists?(form_element_id).should be_true
    Question.exists?(question_id).should be_true
    
    @form_element.destroy_with_dependencies
    
    FormElement.exists?(form_element_id).should be_false
    Question.exists?(question_id).should be_false
    
  end
  
end
