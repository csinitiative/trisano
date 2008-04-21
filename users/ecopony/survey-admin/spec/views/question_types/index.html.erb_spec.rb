require File.dirname(__FILE__) + '/../../spec_helper'

describe "/question_types/index.html.erb" do
  include QuestionTypesHelper
  
  before(:each) do
    question_type_98 = mock_model(QuestionType)
    question_type_98.should_receive(:name).and_return("MyString")
    question_type_98.stub!(:html_form_type).and_return("input-text")
    question_type_98.stub!(:has_answer_set).and_return(true)
    question_type_99 = mock_model(QuestionType)
    question_type_99.should_receive(:name).and_return("MyString")
    question_type_99.stub!(:html_form_type).and_return("input-text")
    question_type_99.stub!(:has_answer_set).and_return(true)

    assigns[:question_types] = [question_type_98, question_type_99]
  end

  it "should render list of question_types" do
    render "/question_types/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

