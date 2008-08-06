require File.dirname(__FILE__) + '/../spec_helper'

describe Entitlement do
  before(:each) do
    @entitlement = Entitlement.new
  end

  it "should be valid" do
    @entitlement.should be_valid
  end
end
