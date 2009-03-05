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

describe EncounterEventsHelper do

  describe "basic controls helpers" do

    it 'should draw basic controls' do
      pending
    end

  end
  
  describe "building a list of users for the investigator drop down" do

    fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements
    
    it 'should add the current user to the list of users' do

      User.stub!(:current_user).and_return(users(:default_user))
      
      # Debt: Test exhibits knowledge of the internals. Need some more fixture/mock work to beef this up.
      # The following just does a sanity check to make sure that the base search for users in the method
      # under test does not return any users.
      users =  User.investigators_for_jurisdictions(User.current_user.jurisdictions_for_privilege(:update_event))
      users.should be_empty
      
      users = helper.users_for_investigation_select
      users.size.should == 1
      users[0].user_name.should == users(:default_user).user_name
    end

  end
    
end
