require File.dirname(__FILE__) + '/../spec_helper'

describe Question do
  before(:each) do
    @question = Question.new
    @question.text = "Did you eat the fish?"
    @question.question_type = QuestionType.new({:id => 1, :name => "Multi-select"})
  end

  it "should be valid" do
    @question.should be_valid
  end
end
