require File.dirname(__FILE__) + '/../spec_helper'

describe Answer do
  before(:each) do
    @answer = Answer.new
  end

  it "should be valid" do
    @answer.should be_valid
  end
end
