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

  before(:each) do
    @user = Factory(:user)
    @role = Factory(:role)
    @priv = Privilege.find_by_priv_name("administer") || Factory(:privilege, :priv_name => 'administer')
    @role.privileges << @priv
    @jurisdiction = create_jurisdiction_entity
    @user.role_memberships.create(:role => @role, :jurisdiction => @jurisdiction)
  end

  after :each do
    reload_site_config
  end

  it "should be valid" do
    @user.should be_valid
  end

  it "should be invalid without a UID" do
    @user.uid = ""
    @user.should_not be_valid
  end

  it "should be invalid without a user name" do
    @user.user_name = ""
    @user.should_not be_valid
  end

  it "should be an admin" do
    @user.is_admin?.should be_true
  end

  it "should have zero jurisdiction id for view privilege" do
    @user.jurisdiction_ids_for_privilege(:view_event).size.should eql(0)
  end

  it "should have zero jurisdiction id for update privilege" do
    @user.jurisdiction_ids_for_privilege(:update_event).size.should eql(0)
  end

  it "should have one admin jurisdiction id" do
    @user.admin_jurisdiction_ids.size.should == 1
  end

  it 'should have errors on status if no status is set' do
    @user.status = ''
    @user.save
    @user.errors.on(:status).should == "can't be blank"
  end

  it "should allow a status of 'Active'" do
    @user.status = 'active'
    @user.save
    @user.errors.on(:status).should == nil
  end

  it "should allow a status of 'disabled'" do
    @user.status = 'disabled'
    @user.save
    @user.errors.on(:status).should == nil
  end

  it "should not allow a status with the incorrect case 'Disabled'" do
    @user.status = 'Disabled'
    @user.save
    @user.errors.on(:status).should_not == nil
  end

  it "even if a user has an invalid status of 'Disable' (capitalized), the user should be considered disabled" do
    ActiveRecord::Base.connection.update("UPDATE users SET status = 'Disabled' WHERE id = '#{@user.id}';")
    @user.reload
    @user.disabled?.should be_true
  end

  it "other statuses should cause errors" do
    @user.status = 'no_status'
    @user.save
    @user.errors.on(:status).should == "can only be Active or Disabled"
  end

  it "disabled? should be based on status" do
    @user.should_not be_disabled
    @user.status = 'disabled'
    @user.should be_disabled
  end

  it "should be able to check if it 'owns' a thing" do
    @user = Factory(:user)
    @email_address = Factory(:email_address)
    @user.email_addresses << @email_address
    @user.owns?(@email_address).should be_true
  end

  it "should detect expired password" do
     if User.column_names.include?("crypted_password")
       SITE_CONFIG[RAILS_ENV] = { :trisano_auth => { :password_expiry_date => 90, :password_expiry_notice_date => 14 } }
       @user.update_attribute(:password_last_updated, 91.days.ago)
       @user.password_expired?.should be_true

       @user.update_attribute(:password_last_updated, 80.days.ago)
       @user.password_expires_soon?.should be_true

       @user.update_attribute(:password_last_updated, Date.today)
       @user.password_expires_soon?.should be_false
       @user.password_expired?.should be_false

       SITE_CONFIG[RAILS_ENV] = { :trisano_auth => { :password_expiry_date => 0 } }
       @user.update_attribute(:password_last_updated, 12.years.ago)
       @user.password_expires_soon?.should be_false
       @user.password_expired?.should be_false

       SITE_CONFIG[RAILS_ENV] = { :trisano_auth => { } }
       @user.update_attribute(:password_last_updated, 12.years.ago)
       @user.password_expires_soon?.should be_false
       @user.password_expired?.should be_false
     end
  end

  describe "getting potential task assignees" do
    before do
      assignee = Factory(:user)
      priv = Privilege.find_by_priv_name("update_event") || Factory(:privilege, :priv_name => "update_event")
      role = Factory(:role)
      role.privileges << priv
      assignee.role_memberships.create(:role => role, :jurisdiction => @jurisdiction)

      assigner = Factory(:user)
      priv = Privilege.find_by_priv_name("assign_task_to_user") || Factory(:privilege, :priv_name => "assign_task_to_user")
      role = Factory(:role)
      role.privileges << priv
      assigner.role_memberships.create(:role => role, :jurisdiction => @jurisdiction)
    end

    it "should find users with update event in the provided jurisdiction" do
      assignees = User.task_assignees_for_jurisdictions(@jurisdiction.id)
      assignees.size.should == 1

      assignees = User.task_assignees_for_jurisdictions(create_jurisdiction_entity.id)
      assignees.size.should == 0
    end


    it 'should return users in jurisdiction where current user has assign_task_to_user rights' do
      User.default_task_assignees.size.should == 1
    end
  end

  context "is_entitled_to? accepts arrays of jurisdiction ids" do

    before(:each) do
      priv = Privilege.find_by_priv_name("update_event") || Factory("privilege", :priv_name => "update_event")
      @role.privileges << priv
    end

    it "and returns true the user has the privilege in one of the jurisdictions" do
      @user.is_entitled_to_in?(:update_event, [@jurisdiction.id, create_jurisdiction_entity.id]).should be_true
      @user.is_entitled_to_in?(:update_event, [create_jurisdiction_entity.id, create_jurisdiction_entity.id]).should be_false
    end
  end

  context '#store_as_task_view_settings' do
    it 'should reset to default settings w/  nil' do
      @user.store_as_task_view_settings(nil)
      @user.reload
      @user.task_view_settings.should == {:look_back => 0, :look_ahead => 0}
    end

    it 'should only store values that are meaningful as view settings' do
      settings_hash = {
        :look_ahead => 0,
        :look_back => 0,
        :disease_filter => [0, 1],
        :junk_value => 0,
        :tasks_ordered_by => :due_date}
      @user.store_as_task_view_settings(settings_hash)
      @user.task_view_settings.should == {
        :look_ahead => 0,
        :look_back => 0,
        :disease_filter => [0, 1],
        :tasks_ordered_by => :due_date}
    end


    it 'should treat an empty hash as default settings' do
      @user.store_as_task_view_settings({})
      @user.reload
      @user.task_view_settings.should == {:look_back => 0, :look_ahead => 0}
    end
  end

  context "state manager scopes" do

    before(:each) do
      create_role_with_privileges!('State Manager', :approve_event_at_state)
      create_user_in_role!('State Manager', 'Spongebob Squarepants')
      create_user_in_role!('State Manager', 'Patrick Star').disable
    end

    it "should find all state managers" do
      results = User.state_managers
      assert(results.map(&:best_name).include?('Spongebob Squarepants'),
             "'Spongebob' should have been included in state managers")
      assert(results.map(&:best_name).include?('Patrick Star'),
             "'Patrick Star' should have been included in state managers")

      non_managers = results.reject(&:state_manager?)
      non_managers.each {|nm| p nm.privs}
      assert(non_managers.empty?,
             "Expected zero non-managers, but received #{non_managers.inspect}")
    end

    it "should find active state managers" do
      results = User.state_managers.active
      assert(results.map(&:best_name).include?('Spongebob Squarepants'),
             "'Spongebob' should have been included in active state managers")
      assert(!results.map(&:best_name).include?('Patrick Star'),
             "'Patrick Star' should not have been included in active state managers")

      non_managers = results.reject(&:state_manager?)
      non_managers.each {|nm| p nm.privs}
      assert(non_managers.empty?,
             "Expected zero non-managers, but received #{non_managers.inspect}")
    end
  end

  context "encapsulated privilege checking" do
    before do
      @event = Factory.build(:morbidity_event)
      @event.jurisdiction.build(:secondary_entity_id => @jurisdiction.id)
      @event.save!

      priv = Privilege.find_by_priv_name("update_event") || Factory(:privilege, :priv_name => "update_event")
      @role.privileges << priv
    end

    it "checks user privileges against the event" do
      @user.can_update?(@event).should be_true
    end

    it "verifies if a user can access sensitive diseases" do
      @user.can_access_sensitive_diseases?(@event).should be_false

      @role.privileges << (Privilege.find_by_priv_name("access_sensitive_diseases") || Factory(:privilege, :priv_name => "access_sensitive_diseases"))
      @user.can_access_sensitive_diseases?(@event, true).should be_true
    end

    it "if the event has no jurisdiction or is nil, look for the sensitive disease privilege in any jurisdiction" do
      @role.privileges << (Privilege.find_by_priv_name("access_sensitive_diseases") || Factory(:privilege, :priv_name => "access_sensitive_diseases"))
      @event.stubs(:jurisdiction_entity_ids).returns([])
      @user.can_access_sensitive_diseases?(@event).should be_true
      @user.can_access_sensitive_diseases?(nil).should be_true
    end

  end

end
