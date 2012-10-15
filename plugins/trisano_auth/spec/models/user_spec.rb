# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

    it 'should not repeat passwords for 10 times' do
      @user.should be_valid

      @user.password = 'Test1234!'
      @user.password_confirmation = 'Test1234!'
      @user.should be_valid

      @user.password = 'Helo1234!'
      @user.password_confirmation = 'Helo1234!'
      @user.should be_valid

      @user.password = 'Test1234!'
      @user.password_confirmation = 'Test1234!'
      @user.should_not be_valid

      ["One1234!", "Two1234!", "Thre1234!", "Four1234!", "Five1234!", "Six1234!", "Seven1234!", "Eight1234!", "Nine1234!"].each do |p|
        u.password = p
        u.password_confirmation = p
        u.save!
      end

      @user.password = "Helo1234!"
      @user.password_confirmation = "Helo1234!"
      @user.save.should_not be_true
    end

    it 'should allow the same password on the eleventh time' do
      @user.password = "Valid1234!"
      @user.password_confirmation = "Valid1234!"
      @user.save!

      ["One1234!", "Two1234!", "Thre1234!", "Four1234!", "Five1234!", "Six1234!", "Seven1234!", "Eight1234!", "Nine1234!", "Ten1234!"].each do |p|
        u.password = p
        u.password_confirmation = p
        u.save!
      end

      @user.password = "Valid1234!"
      @user.password_confirmation = "Valid1234!"
      @user.save.should be_true
      @user.old_passwords.length.should == 10
    end

    it 'should be valid with a password, and password confirmation' do
      @user.should be_valid
    end


    it 'should not be valid without a password' do
      @user.password = nil
      @user.should_not be_valid
      @user.save.should be_false
      @user.errors.empty?.should be_false
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

    it "new password should be different from the old one" do
       @user.password = "Test1234!"
       @user.password_confirmation = "Test1234!"
       @user.save!

       @user.password = "Test1234!"
       @user.password_confirmation= "Test1234!"
       @user.valid?.should be_false
       @user.errors.full_messages.first.should == "New password should be different from the old one."
    end

    it "should require current password to be supplied on every password change" do
       @user.password = "Nest1234!"
       @user.password_confirmation= "Nest1234!"
       @user.current_password = "Invalid"
       @user.valid?.should be_false
       @user.errors.full_messages.first.should == "Current password is invalid."
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
