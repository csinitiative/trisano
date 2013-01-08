# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
