require File.dirname(__FILE__) + '/../../spec_helper'

describe "/answers/show.html.erb" do
  include AnswersHelper
  
  before(:each) do
    @answer = mock_model(Answer)
    @answer.stub!(:text).and_return("MyString")

    assigns[:answer] = @answer
  end

  it "should render attributes in <p>" do
    render "/answers/show.html.haml"
    response.should have_text(/MyString/)
  end
end

