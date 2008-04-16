require File.dirname(__FILE__) + '/../spec_helper'

describe AnswerSet do
  before(:each) do
    @answer_set = AnswerSet.new
  end

  it "should be valid" do
    @answer_set.should be_valid
  end
end
