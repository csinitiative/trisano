# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

describe Role, "loaded from fixtures" do

  fixtures :role_memberships, :roles, :privileges, :privileges_roles

  before(:each) do
    @role = roles(:administrator)
  end

  it "should be valid" do
    @role.should be_valid
  end

  it "should be invalid without a role name" do
    @role.role_name = ""
    @role.should_not be_valid
  end

  it "should have one privilege" do
    @role.privileges.size.should == 1
  end

  it "should have two privileges after update" do
    @role.update_attributes( { :privileges_role_attributes => [{ :privilege_id => privileges(:view) },
                             { :privilege_id => privileges(:update) }] } )
    @role.privileges.size.should == 2
  end

end

describe "on a new role" do

  fixtures :role_memberships, :roles, :privileges, :privileges_roles

  before(:each) do
    @role = Role.new( {:role_name => "New Role"} )
  end

  it "should have zero privileges" do
    @role.privileges.size.should == 0
  end

end
