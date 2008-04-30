require File.dirname(__FILE__) + '/../spec_helper'

describe AnswerSetElement do
  before(:each) do
    @answer_set_element = AnswerSetElement.new
  end

  it "should be valid" do
    @answer_set_element.should be_valid
  end
end
