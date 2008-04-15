require File.dirname(__FILE__) + '/../../spec_helper'

describe "/questions/index.html.erb" do
  include QuestionsHelper
  
  before(:each) do
    question_98 = mock_model(Question)
    question_98.should_receive(:text).and_return("MyString")
    question_99 = mock_model(Question)
    question_99.should_receive(:text).and_return("MyString")

    assigns[:questions] = [question_98, question_99]
  end

  it "should render list of questions" do
    render "/questions/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

