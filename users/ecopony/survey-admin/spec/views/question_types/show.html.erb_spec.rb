require File.dirname(__FILE__) + '/../../spec_helper'

describe "/question_types/show.html.erb" do
  include QuestionTypesHelper
  
  before(:each) do
    @question_type = mock_model(QuestionType)
    @question_type.stub!(:name).and_return("MyString")
    @question_type.stub!(:description).and_return("MyString")

    assigns[:question_type] = @question_type
  end

  it "should render attributes in <p>" do
    render "/question_types/show.html.haml"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
  end
end

