require File.dirname(__FILE__) + '/../../spec_helper'

describe "/answer_sets/show.html.erb" do
  include AnswerSetsHelper
  
  before(:each) do
    @answer_set = mock_model(AnswerSet)
    @answer_set.stub!(:name).and_return("MyString")

    assigns[:answer_set] = @answer_set
  end

  it "should render attributes in <p>" do
    render "/answer_sets/show.html.erb"
    response.should have_text(/MyString/)
  end
end

