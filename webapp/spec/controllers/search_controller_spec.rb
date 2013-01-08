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
require 'spec_helper'

describe SearchController do

  before :all do
    destroy_fixture_data
  end

  after :all do
    Fixtures.reset_cache
  end

  context "the search form" do

    before :all do
      create_user
      @role = Factory(:role)
      @user.role_memberships.create(:jurisdiction => create_jurisdiction_entity, :role => @role)
      @role.privileges << (Privilege.find_by_priv_name('view_event') || Factory(:privilege, :priv_name => 'view_event'))
      @diseases = [Factory(:disease, :sensitive => false), Factory(:disease, :sensitive => true)]
    end

    it "does not return sensitive diseases if the user doesn't have that privilege" do
      get "events", nil, {:user_id => @user.uid}
      assigns[:diseases].should == @diseases[0,1]
    end

    it "returns sensitive diseases if the user has that privilege" do
      @role.privileges << (Privilege.find_by_priv_name("access_sensitive_diseases") || Factory(:privilege, :priv_name => "access_sensitive_diseases"))
      get "events", nil, {:user_id => @user.uid}
      assigns[:diseases].should == @diseases
    end
  end
end
