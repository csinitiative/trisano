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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/roles/index.html.haml" do
  include RolesHelper
  
  before(:each) do
    role_98 = Factory.create(:role)
    role_98.stubs(:find).returns([@role])
    role_98.stubs(:role_name).returns("role name")
    role_98.stubs(:description).returns("role description")
    role_98.stubs(:role_memberships).returns([])
    role_98.stubs(:privileges_roles).returns([])

    assigns[:roles] = [role_98, role_98]
  end

  it "should render list of roles" do
    render "/roles/index.html.haml"
  end
end

