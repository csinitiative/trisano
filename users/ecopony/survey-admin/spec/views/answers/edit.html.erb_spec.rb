require File.dirname(__FILE__) + '/../../spec_helper'

describe "/answers/edit.html.erb" do
  include AnswersHelper
  
  before do
    @answer = mock_model(Answer)
    @answer.stub!(:text).and_return("MyString")
    assigns[:answer] = @answer
  end

  it "should render edit form" do
    render "/answers/edit.html.haml"
    
    response.should have_tag("form[action=#{answer_path(@answer)}][method=post]") do
      with_tag('input#answer_text[name=?]', "answer[text]")
    end
  end
end


