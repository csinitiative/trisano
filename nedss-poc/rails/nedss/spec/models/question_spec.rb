require File.dirname(__FILE__) + '/../spec_helper'

describe Question do
  before(:each) do
    @question = Question.new
    @question.question_text = "Did you eat the fish?"
    @question.data_type = "single_line_text"
  end

  it "should be valid" do
    @question.should be_valid
  end
  
end