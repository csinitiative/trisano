require File.dirname(__FILE__) + '/../spec_helper'

describe User, "loaded from fixtures" do
  
  fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements
  
  before(:each) do
    @user = users(:default_user)
    @jurisdiction = Entity.find(entities(:Southeastern_District).id)
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
    @user.has_role_in?(@jurisdiction).should be_true
  end
  
  it "should have an entitlement in the Southeastern District" do
    @user.has_entitlement_in?(@jurisdiction).should be_true
  end
  
  it "should have one admin jurisdiction id" do
    @user.admin_jurisdiction_ids.size.should == 1
  end
  
  it "should have one entitlement jurisdiction id" do
    @user.entitlement_jurisdiction_ids.size.should == 1
  end
end

describe User, "with admin role removed and investigator role added" do
  
  fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements
  
  before(:each) do
    @user = users(:default_user)
    admin_role = @user.role_memberships.detect { |rm| rm.role_id == roles(:administrator).id and rm.jurisdiction_id == entities(:Southeastern_District).id}
    admin_role.destroy
    role = roles(:investigator)
    jurisdiction = entities(:Southeastern_District)
    @user.role_memberships << RoleMembership.new(:role => role, :jurisdiction => jurisdiction)
    @user.role_memberships.reload
    @user.entitlements.reload
  end
  
  it "should not be an admin" do
    @user.is_admin?.should be_false
  end
  
  it "should be an investigator" do
    @user.is_investigator?.should be_true
  end
  
  it "should not have administrator privileges in Southeastern District" do
    @user.is_entitled_to_in?(privileges(:administer), entities(:Southeastern_District)).should be_false
  end
  
  it "should have view privileges in Southeastern District" do
    @user.is_entitled_to_in?(privileges(:view), entities(:Southeastern_District)).should be_true
  end

  it "should have update privileges in Southeastern District" do
    @user.is_entitled_to_in?(privileges(:update), entities(:Southeastern_District)).should be_true
  end
  
end

describe User, "modified to remove all roles and privileges in Southeastern District" do
  
  fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements
  
  before(:each) do
    @user = users(:default_user)
    admin_role = @user.role_memberships.detect { |rm| rm.role_id == roles(:administrator).id and rm.jurisdiction_id == entities(:Southeastern_District).id}
    admin_role.destroy
    @user.role_memberships.reload
    @user.entitlements.reload
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
  
  fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements
  
  before(:each) do
    @user = users(:default_user)
  end
  
  it "should not be valid" do
    role = roles(:administrator)
    jurisdiction = entities(:Southeastern_District)
    @user.role_memberships << RoleMembership.new(:role => role, :jurisdiction => jurisdiction)
    @user.should_not be_valid
  end
  
end

# This can be added in when the remove/create action in RoleMembership is modified; as
# of now, role memberships are not updated, although this probably needs to change.
#describe User, "with a directly modified role membership" do
#  
#  fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements
#  
#  before(:each) do
#    @user = users(:default_user)
#    admin_role_to_change = @user.role_memberships.detect { |rm| rm.role_id == roles(:administrator).id and rm.jurisdiction_id == entities(:Southeastern_District).id}
#    admin_role_to_change.role = roles(:investigator)
#    admin_role_to_change.save
#    @user.role_memberships.reload
#    @user.entitlements.reload
#  end
#  
#  it "should have an entitlement in the Southeastern District" do
#    @user.has_entitlement_in?(entities(:Southeastern_District)).should be_true
#  end
#  
#  it "should be an investigator" do
#    @user.is_investigator?.should be_true
#  end
#  
#  it "should not be an administrator" do
#    @user.is_admin?.should be_false
#  end
#  
#  it "should have not have administer privileges in Southeastern District" do
#    @user.is_entitled_to_in?(privileges(:administer), entities(:Southeastern_District)).should be_false
#  end
#  
#end
