require File.dirname(__FILE__) + '/../spec_helper'

describe Program do
  before(:each) do
    @program = Program.new
  end

  it "should be valid" do
    @program.should be_valid
  end
end
