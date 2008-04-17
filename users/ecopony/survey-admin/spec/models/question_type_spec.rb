require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionType do
  before(:each) do
    @question_type = QuestionType.new
    @question_type.name = "text"
    @question_type.html_form_type = "input-text"
  end

  it "should be valid" do
    @question_type.should be_valid
  end
end
