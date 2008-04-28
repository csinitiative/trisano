require File.dirname(__FILE__) + '/../spec_helper'

describe Question do
  before(:each) do
    @question = Question.new
  end

  it "should be valid" do
    @question.should be_valid
  end
end
