require File.dirname(__FILE__) + '/../../spec_helper'

describe "/answer_sets/index.html.erb" do
  include AnswerSetsHelper
  
  before(:each) do
    answer_set_98 = mock_model(AnswerSet)
    answer_set_98.should_receive(:name).and_return("MyString")
    answer_set_99 = mock_model(AnswerSet)
    answer_set_99.should_receive(:name).and_return("MyString")

    assigns[:answer_sets] = [answer_set_98, answer_set_99]
  end

  it "should render list of answer_sets" do
    render "/answer_sets/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

