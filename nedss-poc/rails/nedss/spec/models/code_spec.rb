require File.dirname(__FILE__) + '/../spec_helper'

describe Code do
  before(:each) do
    @code = Code.new
  end

  it "should be valid" do
    @code.should be_valid
  end
end
