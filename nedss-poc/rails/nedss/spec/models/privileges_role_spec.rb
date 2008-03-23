require File.dirname(__FILE__) + '/../spec_helper'

describe PrivilegesRole do
  before(:each) do
    @privileges_role = PrivilegesRole.new
  end

  it "should be valid" do
    @privileges_role.should be_valid
  end
end
