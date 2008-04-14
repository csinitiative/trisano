require File.dirname(__FILE__) + '/../spec_helper'

describe Jurisdiction do
  before(:each) do
    @jurisdiction = Jurisdiction.new
  end

  it "should be valid" do
    @jurisdiction.should be_valid
  end
end
