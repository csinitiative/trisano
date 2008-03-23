require File.dirname(__FILE__) + '/../spec_helper'

describe RoleMembership do
  before(:each) do
    @role_membership = RoleMembership.new
  end

  it "should be valid" do
    @role_membership.should be_valid
  end
end
