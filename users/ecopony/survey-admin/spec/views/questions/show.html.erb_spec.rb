require File.dirname(__FILE__) + '/../../spec_helper'

describe "/questions/show.html.erb" do
  include QuestionsHelper
  
  before(:each) do
    
    question_type = mock_model(QuestionType)
    question_type.stub!(:name).and_return("Multi-select")
    
    @question = mock_model(Question)
    @question.stub!(:text).and_return("MyString")
    @question.stub!(:help).and_return("MyString")
    @question.stub!(:question_type).and_return(question_type)

    assigns[:question] = @question
  end

  it "should render attributes in <p>" do
    render "/questions/show.html.haml"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
  end
end

