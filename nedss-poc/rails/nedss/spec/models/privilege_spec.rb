require File.dirname(__FILE__) + '/../spec_helper'

describe Privilege do
  before(:each) do
    @privilege = Privilege.new
  end

  it "should be valid" do
    @privilege.should be_valid
  end
end
