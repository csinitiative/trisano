require File.dirname(__FILE__) + '/../spec_helper'

describe User, "loaded from fixtures" do
  
  fixtures :users, :role_memberships, :roles, :entities, :entitlements
  
  # Add entitlement fixtures
  # Test entitlments
  # Run through and remove extra fixture references
  
  before(:each) do
    @user = users(:default_user)
  end

  it "should be valid" do
    @user.should be_valid
  end
  
  it "should be invalid without a UID" do
    @user.uid = ""
    @user.should_not be_valid
  end
  
  it "should be invalid without a user name" do
    @user.user_name = ""
    @user.should_not be_valid
  end
  
  it "should be an admin" do
    @user.is_admin?.should be_true
  end
  
  it "should not be an investigator" do
    @user.is_investigator?.should be_false
  end
  
  it "should have a role in the Southeastern District" do
    @user.has_role_in?(entities(:Southeastern_District)).should be_true
  end
  
  it "should have an entitlement in the Southeastern District" do
    @user.has_entitlement_in?(entities(:Southeastern_District)).should be_true
  end
  
end

describe User, "modified with an investigator role" do
  
  fixtures :users, :role_memberships, :roles, :entities
  
  # Test entitlements
  
  before(:each) do
    @user = users(:default_user)
    @user.remove_role_membership(roles(:administrator), entities(:Southeastern_District))
    @user.add_role_membership(roles(:investigator), entities(:Southeastern_District))
  end
  
  
  it "should not be an admin" do
    @user.is_admin?.should be_false
  end
  
  it "should be an investigator" do
    @user.is_investigator?.should be_true
  end
  
end

describe User, "modified to remove roles and privileges in Southeastern District" do
  
  fixtures :users, :role_memberships, :roles, :entities, :entitlements, :privileges
  
  # Test entitlements
  
  before(:each) do
    @user = users(:default_user)
    @user.remove_role_membership(roles(:administrator), entities(:Southeastern_District))
    @user.remove_entitlement(privileges(:administer), entities(:Southeastern_District))
  end
  
  it "should not have a role in the Southeastern District" do
    @user.has_role_in?(entities(:Southeastern_District)).should be_false
  end
  
  it "should not have an entitlement in the Southeastern District" do
    @user.has_entitlement_in?(entities(:Southeastern_District)).should be_false
  end
  
  it "should no longer be an admin" do
    @user.is_admin?.should be_false
  end
  
end

describe User, "modified to add duplicate roles" do
  
  fixtures :users, :role_memberships, :roles, :entities, :entitlements, :privileges
  
  before(:each) do
    @user = users(:default_user)
  end
  
  it "should not be valid" do
    @role = roles(:administrator)
    @jurisdiction = entities(:Southeastern_District)
    @user.add_role_membership(@role, @jurisdiction)
    @user.should_not be_valid
  end
  
end

describe User, "modified to add new roles and privileges in Southeastern District" do
  
  fixtures :users, :role_memberships, :roles, :entities, :entitlements, :privileges
  
  before(:each) do
    @user = users(:default_user)
    @user.add_entitlement(privileges(:view), entities(:Southeastern_District))
  end
  
  it "should have an entitlement in the Southeastern District" do
    @user.has_entitlement_in?(entities(:Southeastern_District)).should be_true
  end
  
  # Need to add implementations for checking privileges for a jurisdiction
  
end
