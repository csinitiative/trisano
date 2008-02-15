require File.dirname(__FILE__) + '/../spec_helper'

describe Telephone do
  before(:each) do
    @phone = Telephone.new
  end

  it "should be valid without a properly formatted phone_number" do
    @phone.should_not be_valid
  end

  # TODO: test validations here
end
