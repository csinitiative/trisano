require File.dirname(__FILE__) + '/../../spec_helper'

describe "/answers/index.html.erb" do
  include AnswersHelper
  
  before(:each) do
    answer_98 = mock_model(Answer)
    answer_98.should_receive(:text).and_return("MyString")
    answer_99 = mock_model(Answer)
    answer_99.should_receive(:text).and_return("MyString")

    assigns[:answers] = [answer_98, answer_99]
  end

  it "should render list of answers" do
    render "/answers/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

