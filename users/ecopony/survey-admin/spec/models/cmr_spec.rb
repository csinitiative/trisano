require File.dirname(__FILE__) + '/../spec_helper'

describe Cmr do
  before(:each) do
    @cmr = Cmr.new
  end

  it "should be valid" do
    @cmr.should be_valid
  end
end
