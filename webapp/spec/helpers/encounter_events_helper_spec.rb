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

require File.dirname(__FILE__) + '/../spec_helper'

describe EncounterEventsHelper do
  before do
    @user = Factory(:user)
    @role = Factory(:role)
    @priv = Privilege.find_by_priv_name('update_event') || Factory(:privilege, :priv_name => 'update_event')
    @role.privileges << @priv
  end

  describe "basic controls helpers" do
    before(:each) do
      @encounter_event = Factory.create(:encounter_event)
      @jurisdiction = @encounter_event.jurisdiction.secondary_entity
      @user.role_memberships.create(:role => @role, :jurisdiction => @jurisdiction)
    end

    it 'should draw basic controls without show' do
      result =  helper.basic_encounter_event_controls(@encounter_event, false)
      result.include?("Show").should be_false
      result.include?("Edit").should be_true
      result.include?("Delete").should be_true
    end

    it 'should draw basic controls with show' do
      result =  helper.basic_encounter_event_controls(@encounter_event)
      result.include?("Show").should be_true
      result.include?("Edit").should be_true
      result.include?("Delete").should be_true
    end

    it 'should draw basic controls without delete' do
      @encounter_event.stubs(:deleted_at).returns(1.day.ago)
      result =  helper.basic_encounter_event_controls(@encounter_event)
      result.include?("Show").should be_true
      result.include?("Edit").should be_true
      result.include?("Delete").should be_false
    end
  end

  describe "building a list of users for the investigator drop down" do

    it 'should add the current user to the list of users' do
      encounter_event = Factory.create(:encounter_event)
      helper.users_for_investigation_select(encounter_event).should == [@user]
    end

  end

end
