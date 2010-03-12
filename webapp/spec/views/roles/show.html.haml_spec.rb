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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/roles/show.html.haml" do
  include RolesHelper
  
  before(:each) do
    @user = mock_user
    assigns[:user] = @user
    @role = Factory.create(:role)
    @role.stubs(:role_name).returns("role name")
    @role.stubs(:description).returns("role description")
    @role.stubs(:role_memberships).returns([])
    @role.stubs(:privileges_roles).returns([])
    assigns[:role] = @role
  end

  it "should render attributes in <p>" do
    render "/roles/show.html.haml"
  end
end

