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


require 'spec_helper'

describe User do
  
  describe "When a user is new" do
    
    before(:each) do
      @user = User.new(Factory.attributes_for(:user))
      @user.password = 'changeme'
      @user.password_confirmation = 'changeme'
    end

    it 'should be valid with a password, and password confirmation' do
      @user.should be_valid
    end

    it 'should not be valid without a password' do
      user = User.new(Factory.attributes_for(:user))
      user.should_not be_valid
      user.save.should be_false
      user.errors.empty?.should be_false
    end

    it 'should not be valid without a password confirmation' do
      @user.password_confirmation = nil
      @user.should_not be_valid
      @user.save.should be_false
      @user.errors.empty?.should be_false
    end

    it "should not be valid with a password and password confirmation that don't match" do
      @user.password_confirmation = 'fixmeup'
      @user.should_not be_valid
      @user.save.should be_false
      @user.errors.empty?.should be_false
    end
  end

  describe "When a user exists" do

    before(:each) do
      @user = User.create(Factory.attributes_for(:user,
        :password => 'changeme',
        :password_confirmation => 'changeme'))
    end

    it 'should be valid with a password, and password confirmation' do
      @user.should be_valid
    end

    it 'should not be valid without a password' do
      @user = User.new(Factory.attributes_for(:user))
      @user.password = ''
      @user.password_confirmation = 'changeme'
      @user.should_not be_valid
      @user.save.should be_false
      @user.errors.empty?.should be_false
    end

    it 'should not be valid without a password confirmation' do
      @user.password_confirmation = nil
      @user.password = 'homerific'
      @user.should_not be_valid
      @user.save.should be_false
      @user.errors.empty?.should be_false
    end

    it "should not be valid with a password and password confirmation that don't match" do
      @user.password = 'homerific'
      @user.password_confirmation = 'fixmeup'
      @user.should_not be_valid
      @user.save.should be_false
      @user.errors.empty?.should be_false
    end

  end

  describe "loading default users" do
    it 'should load default users with auth attributes' do
      u = [
        {"uid" => 'chuck_j', "user_name" => 'chuck_j'}
      ]
      User.load_default_users(u)
      user = User.find_by_uid('chuck_j')
    end
  end
end
