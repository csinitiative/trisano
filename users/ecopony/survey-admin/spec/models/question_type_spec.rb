require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionType do
  before(:each) do
    @question_type = QuestionType.new
  end

  it "should be valid" do
    @question_type.should be_valid
  end
end
