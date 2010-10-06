# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

describe CoreFieldsController do

  describe "handling an administrator's request" do
    before do
      mock_user
      get :index
    end

    it "returns successfully" do
      response.should be_success
    end

    it "renders the index view" do
      response.should render_template('index')
    end
  end

  describe "handling a request from an non-administrative user" do
    before do
      mock_user
      @user.stubs(:is_admin?).returns(false)
      get :index
    end

    it "forbids access" do
      response.response_code.should == 403
    end
  end

end

