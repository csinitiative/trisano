require File.dirname(__FILE__) + '/../../spec_helper'

describe "/answers/new.html.erb" do
  include AnswersHelper
  
  before(:each) do
    @answer = mock_model(Answer)
    @answer.stub!(:new_record?).and_return(true)
    @answer.stub!(:text).and_return("MyString")
    @answer.stub!(:answer_set_id).and_return(1)
    assigns[:answer] = @answer
  end

  it "should render new form" do
    render "/answers/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", answers_path) do
      with_tag("input#answer_text[name=?]", "answer[text]")
    end
  end
end


