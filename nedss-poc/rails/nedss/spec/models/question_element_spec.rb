require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionElement do
  before(:each) do
    @question_element = QuestionElement.new
  end

  it "should be valid" do
    @question_element.should be_valid
  end
end
