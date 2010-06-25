# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..


require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')
#require File.expand_path(File.dirname(__FILE__) + '/../factories/user_factories')

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

    it 'should not be valid without an email' do
      @user.should_not be_valid
      @user.save.should be_false
      @user.errors.empty?.should be_false
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

    it 'should not be valid with a duplicate email' do
      @user.save
      @user2 = User.new(Factory.attributes_for(:user))
      @user2.should_not be_valid
      @user2.save.should be_false
      @user2.errors.empty?.should be_false
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
