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

describe UsersController do

  before do
    @current_user = create_user
    @current_user.email_addresses << Factory.create(:email_address)

    @another_user = Factory.create(:user)
    @another_user.email_addresses << Factory.create(:email_address)
    User.stubs(:current_user).returns(@current_user)
  end

  describe "permissions" do
    it "should let anyone view their configured email addresses" do
      response = get :email_addresses
      response.status.should =~ /200/
    end
  end

  describe "allowing a user to change their own email address" do
    it "edit action should return success status" do
      response = get(:edit_email_address, :email_address_id => @current_user.email_addresses.first.id)
      response.status.should =~ /200/
    end

    it "update action should return success status" do
      response = put(:edit_email_address, :email_address_id => @current_user.email_addresses.first.id, :email_address => { :email_address => "modified@emailaddress.com" })
      response.status.should =~ /200/
    end
  end

  describe "preventing a user from changing another user's email address" do
    it "edit action should result in an error" do
      lambda{ get(:edit_email_address,
                  :email_address_id => @another_user.email_addresses.first.id
      )}.should raise_error
    end

    it "update action should result in an error" do
     lambda{ put(:edit_email_address,
                 :email_address_id => @another_user.email_addresses.first.id,
                 :email_address => {
                   :email_address => "modified@emailaddress.com"
                 }
     )}.should raise_error
    end
  end

end