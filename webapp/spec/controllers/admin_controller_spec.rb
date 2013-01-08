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

describe AdminController do

  describe "handling GET /admin" do
    
    before(:each) do
      mock_user
    end
    
    def do_get
      get :index
    end
    
    it "should be successful" do
      do_get
      response.should be_success
    end
    
    it "should render index template" do
      do_get
      response.should render_template('index')
    end
    
  end
  
  describe "handling GET /admin without an admin user on the request" do
    
    before(:each) do
      mock_user
      @user.stubs(:is_admin?).returns(false)
      @user.stubs(:user_name).returns("not_an_admin")
    end
    
    def do_get
      get :index
    end
    
    it "should be be a 403" do
      do_get
      response.response_code.should == 403
    end
    
  end
  
end
