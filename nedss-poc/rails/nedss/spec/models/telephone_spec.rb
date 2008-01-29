require File.dirname(__FILE__) + '/../spec_helper'

describe Telephone do
  before(:each) do
    @phone = Telephone.new
  end

  it "should be valid" do
    @phone.should be_valid
  end
end
