# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require File.dirname(__FILE__) + '/../spec_helper'

describe User, "loaded from fixtures" do
  
  fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements
  
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
  
  it "should have one jurisdiction id for view privilege" do
    @user.jurisdiction_ids_for_privilege(:view).size.should eql(1)
  end
  
  it "should have one jurisdiction id for update privilege" do
    @user.jurisdiction_ids_for_privilege(:update).size.should eql(1)
  end
  
  it "should have one admin jurisdiction id" do
    @user.admin_jurisdiction_ids.size.should == 1
  end
  
end

# describe User, "modified to remove all roles and privileges in Southeastern District" do
  
#   fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements
  
#   before(:each) do
#     @user = users(:default_user)
#     admin_role = @user.role_memberships.detect { |rm| rm.role_id == roles(:administrator).id and rm.jurisdiction_id == entities(:Southeastern_District).id}
#     admin_role.destroy
#     @user.role_memberships.reload
#     @user.entitlements.reload
#   end
  
#   it "should not have a role in the Southeastern District" do
#     @user.has_role_in?(entities(:Southeastern_District)).should be_false
#   end
  
#   it "should not have an entitlement in the Southeastern District" do
#     @user.has_entitlement_in?(entities(:Southeastern_District)).should be_false
#   end
  
#   it "should no longer be an admin" do
#     @user.is_admin?.should be_false
#   end
  
#   # All of the following fail with the array being nil. This does not sync with
#   # behavior from within the console where an empty array is returned.
#   # Dig in at some point.
#   #  it "should not have a juridiction for privilege view" do
#   #    @user.jurisdictions_for_privilege(:view).length.should eql(0)
#   #  end
#   #  
#   #  it "should not have a juridiction for privilege update" do
#   #    @user.jurisdictions_for_privilege(:update).length.should eql(0)
#   #  end
#   #  
#   #  it "should not have a juridiction privilege administer" do
#   #    @user.jurisdictions_for_privilege(:administer).length.should eql(0)
#   #  end
#   #  
#   #  it "should have no jurisdiction id for view privilege" do
#   #    @user.jurisdiction_ids_for_privilege(:view).size.should eql(0)
#   #  end
#   #  
#   #  it "should have no jurisdiction id for update privilege" do
#   #    @user.jurisdiction_ids_for_privilege(:update).size.should eql(0)
#   #  end
#   #  
#   #  it "should have no jurisdiction id for administer privilege" do
#   #    @user.jurisdiction_ids_for_privilege(:administer).size.should eql(0)
#   #  end
#   #  
#   #  it "should have no admin jurisdiction ids" do
#   #    @user.admin_jurisdiction_ids.size.should == 0
#   #  end
  
# end

# describe User, "modified to add duplicate roles" do
#   
#   fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements
#   
#   before(:each) do
#     @user = users(:default_user)
#   end
  
#   it "should not be valid" do
#     role = roles(:administrator)
#     jurisdiction = entities(:Southeastern_District)
#     @user.role_memberships << RoleMembership.new(:role => role, :jurisdiction => jurisdiction)
#     @user.should_not be_valid
#   end
  
# end

describe User, "Setting role memberships and entitlements via User attributes" do

  fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements, :entities, :places
  
  describe "on a new user" do
    before(:each) do
      @user = User.new( {:user_name => "Joe", :uid => "joe"} )
    end

    describe "assigning one admin role in the Southeastern District" do

      before(:each) do
        @user.attributes = { 
          :role_membership_attributes => [
            { :role_id => roles(:administrator).id, :jurisdiction_id => entities(:Southeastern_District).id }
          ]
        }
      end

      it "should have one role_membership of administrator in the southeastern district" do
        lambda {@user.save}.should change {RoleMembership.count + User.count}.by(2)
        @user.roles.length.should == 1
        @user.roles.first.role_name.should == roles(:administrator).role_name
        @user.role_memberships.length.should == 1
        @user.role_memberships.first.jurisdiction_id.should == entities(:Southeastern_District).id
      end

      it "should be an admin" do
        @user.save
        @user.is_admin?.should be_true
      end
  
      it "should not be an investigator" do
        @user.save
        @user.is_investigator?.should be_false
      end
  
      it "should have administrator privileges in Southeastern District" do
        @user.save
        @user.is_entitled_to_in?(:administer, entities(:Southeastern_District).id).should be_true
      end
   
      it "should have view privileges in Southeastern District" do
        @user.save
        @user.is_entitled_to_in?(:view, entities(:Southeastern_District).id).should be_true
      end
 
      it "should have update privileges in Southeastern District" do
        @user.save
        @user.is_entitled_to_in?(:update, entities(:Southeastern_District).id).should be_true
      end
   
      it "should have a juridiction in the Southeastern District for privilege view" do
        @user.save
        @user.jurisdictions_for_privilege(:view).length.should eql(1)
        @user.jurisdictions_for_privilege(:view).first.name.should eql(places(:Southeastern_District).name)
      end
   
      it "should have one jurisdiction id for view privilege" do
        @user.save
        @user.jurisdiction_ids_for_privilege(:view).size.should eql(1)
      end
   
      it "should have one jurisdiction id for update privilege" do
        @user.save
        @user.jurisdiction_ids_for_privilege(:update).size.should eql(1)
      end
   
      it "should have one jurisdiction id for administer privilege" do
        @user.save
        @user.jurisdiction_ids_for_privilege(:administer).size.should eql(1)
      end
    end

    describe "assigning one admin role and one investigator role in the Southeastern District" do
      before(:each) do
        @user.attributes = { 
          :role_membership_attributes => [
            { :role_id => roles(:administrator).id, :jurisdiction_id => entities(:Southeastern_District).id },
            { :role_id => roles(:investigator).id, :jurisdiction_id => entities(:Southeastern_District).id }
          ]
        }
      end

      it "should have 2 roles in the southeastern district" do
        lambda {@user.save}.should change {RoleMembership.count + User.count}.by(3)
        @user.roles.length.should == 2
        @user.role_memberships.length.should == 2
        @user.role_memberships[0].jurisdiction_id.should == entities(:Southeastern_District).id
        @user.role_memberships[1].jurisdiction_id.should == entities(:Southeastern_District).id
      end

      it "should be an admin" do
        @user.save
        @user.is_admin?.should be_true
      end
  
      it "should be an investigator" do
        @user.save
        @user.is_investigator?.should be_true
      end
  
      it "should have administrator privileges in Southeastern District" do
        @user.save
        @user.is_entitled_to_in?(:administer, entities(:Southeastern_District).id).should be_true
      end
   
      it "should have view privileges in Southeastern District" do
        @user.save
        @user.is_entitled_to_in?(:view, entities(:Southeastern_District).id).should be_true
      end
 
      it "should have update privileges in Southeastern District" do
        @user.save
        @user.is_entitled_to_in?(:update, entities(:Southeastern_District).id).should be_true
      end
   
      it "should have a juridiction in the Southeastern District for privilege view" do
        @user.save
        @user.jurisdictions_for_privilege(:view).length.should eql(1)
        @user.jurisdictions_for_privilege(:view).first.name.should eql(places(:Southeastern_District).name)
      end
   
      it "should have one jurisdiction id for view privilege" do
        @user.save
        @user.jurisdiction_ids_for_privilege(:view).size.should eql(1)
      end
   
      it "should have one jurisdiction id for update privilege" do
        @user.save
        @user.jurisdiction_ids_for_privilege(:update).size.should eql(1)
      end
   
      it "should have one jurisdiction id for administer privilege" do
        @user.save
        @user.jurisdiction_ids_for_privilege(:administer).size.should eql(1)
      end
    end

    describe "assigning one admin role in the Southeastern District and an investigator role in Davis County" do
      before(:each) do
        @user.attributes = { 
          :role_membership_attributes => [
            { :role_id => roles(:administrator).id, :jurisdiction_id => entities(:Southeastern_District).id },
            { :role_id => roles(:investigator).id, :jurisdiction_id => entities(:Davis_County).id }
          ]
        }
      end

      it "should save properly" do
        lambda {@user.save}.should change {RoleMembership.count + User.count}.by(3)
        @user.roles.length.should == 2
        @user.role_memberships.length.should == 2
        rm_ids = @user.role_memberships.collect { |rm| rm.jurisdiction_id }
        rm_ids.include?(entities(:Southeastern_District).id).should be_true
        rm_ids.include?(entities(:Davis_County).id).should be_true
      end

      it "should be an admin" do
        @user.save
        @user.is_admin?.should be_true
      end
  
      it "should be an investigator" do
        @user.save
        @user.is_investigator?.should be_true
      end
  
      it "should have administrator privileges in Southeastern District" do
        @user.save
        @user.is_entitled_to_in?(:administer, entities(:Southeastern_District).id).should be_true
      end
   
      it "should not have administrator privileges in Southeastern District" do
        @user.save
        @user.is_entitled_to_in?(:administer, entities(:Davis_County).id).should_not be_true
      end

      it "should have view privileges in Southeastern District" do
        @user.save
        @user.is_entitled_to_in?(:view, entities(:Southeastern_District).id).should be_true
      end
 
      it "should have view privileges in Davis County" do
        @user.save
        @user.is_entitled_to_in?(:view, entities(:Davis_County).id).should be_true
      end
 
      it "should have update privileges in Southeastern District" do
        @user.save
        @user.is_entitled_to_in?(:update, entities(:Southeastern_District).id).should be_true
      end
   
      it "should have update privileges in Davis County" do
        @user.save
        @user.is_entitled_to_in?(:update, entities(:Davis_County).id).should be_true
      end
   
      it "should have two juridictions for privilege view" do
        @user.save
        @user.jurisdictions_for_privilege(:view).length.should eql(2)
        juris = @user.jurisdictions_for_privilege(:view).collect { |juri| juri.name }
        juris.include?(places(:Southeastern_District).name).should be_true
        juris.include?(places(:Davis_County).name).should be_true
      end
   
      it "should have two jurisdiction id for update privilege" do
        @user.save
        @user.jurisdiction_ids_for_privilege(:update).size.should eql(2)
      end
   
      it "should have one jurisdiction id for administer privilege" do
        @user.save
        @user.jurisdiction_ids_for_privilege(:administer).size.should eql(1)
      end
    end

    describe "assigning the same role and jurisdiction twice" do
      before(:each) do
        @user.attributes = { 
          :role_membership_attributes => [
            { :role_id => roles(:administrator).id, :jurisdiction_id => entities(:Davis_County).id },
            { :role_id => roles(:administrator).id, :jurisdiction_id => entities(:Davis_County).id }
          ]
        }
      end

      it "should save properly" do
        lambda {@user.save}.should change {RoleMembership.count + User.count}.by(2)
        @user.roles.length.should == 1
        @user.role_memberships.length.should == 1
        @user.role_memberships[0].jurisdiction_id.should == entities(:Davis_County).id
      end
    end
  end

  describe "on an existing user" do
    before(:each) do
      @user = users(:default_user)
    end

    describe "adding a new role in a new jurisdiction" do
      before(:each) do
        @user.attributes = { 
          :role_membership_attributes => [
            { :role_id => @user.role_memberships.first.role_id, :jurisdiction_id => @user.role_memberships.first.jurisdiction_id},
            { :role_id => roles(:investigator).id, :jurisdiction_id => entities(:Davis_County).id }
          ]
        }
      end

      it "should save properly" do
        @user.save
        @user.role_memberships.length.should == 2
        rm_ids = @user.role_memberships.collect { |rm| rm.jurisdiction_id }
        rm_ids.include?(entities(:Southeastern_District).id).should be_true
        rm_ids.include?(entities(:Davis_County).id).should be_true
      end
    end

    describe "removing all existing roles" do
      before(:each) do
        @user.attributes = { 
          :role_membership_attributes => {}
        }
      end

      it "should save properly" do
        @user.roles.length.should == 0
        @user.role_memberships.length.should == 0
      end
    end

    describe "removing one of two roles" do
      before(:each) do
        @user.attributes = { 
          :role_membership_attributes => [
            { :role_id => @user.role_memberships.first.role_id, :jurisdiction_id => @user.role_memberships.first.jurisdiction_id},
            { :role_id => roles(:investigator).id, :jurisdiction_id => entities(:Davis_County).id }
          ]
        }
        @user.save
      end

      it "should first have two roles" do
        @user.roles.length.should == 2
        @user.role_memberships.length.should == 2
      end

      it "should have one role after deleting the other" do
        @user.attributes = { 
          :role_membership_attributes => [
            { :role_id => roles(:investigator).id, :jurisdiction_id => entities(:Davis_County).id }
          ]
        }
        @user.save
        @user.roles.length.should == 1
        @user.role_memberships.length.should == 1
      end
    end
 end
end
