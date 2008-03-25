require File.dirname(__FILE__) + '/../spec_helper'

describe RoleMembership, "loaded from fixtures" do
  
  fixtures :users, :role_memberships, :roles, :entities
  
  before(:each) do
    @role_membership = role_memberships(:default_user_admin_role_southeastern_district)
  end

  it "should be valid" do
    @role_membership.should be_valid
  end
  
end

describe RoleMembership, "validation prevents duplicate role membership creation" do
  
  fixtures :users, :role_memberships, :roles, :entities
  
  before(:each) do
    @role_membership = role_memberships(:default_user_admin_role_southeastern_district)
  end

  it "duplicate should not be valid" do
    @role = roles(:administrator)
    @user = users(:default_user)
    @jurisdiction = entities(:Southeastern_District)
    @duplicate_membership = RoleMembership.new(:role => @role, :user => @user, :jurisdiction => @jurisdiction)
    @duplicate_membership.should_not be_valid
  end
  
end
