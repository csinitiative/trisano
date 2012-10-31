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
    @privledged_user = Factory(:user)
    @unprivledged_user = Factory(:user)
    @current_user = create_user 
    @role = Factory(:role)
    @priv = Privilege.find_by_priv_name('update_event') || Factory(:privilege, :priv_name => 'update_event')
    @role.privileges << @priv
  end

  describe "basic controls helpers" do
    before(:each) do
      @encounter_event = Factory.create(:encounter_event)
      @jurisdiction = @encounter_event.jurisdiction.secondary_entity
      @privledged_user.role_memberships.create(:role => @role, :jurisdiction => @jurisdiction)
      @current_user.role_memberships.create(:role => @role, :jurisdiction => @jurisdiction)
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
      helper.users_for_investigation_select(encounter_event).should == [@current_user]
    end

  end

  # This test was added because investigators were not being collected
  # properly when building a new encounter event.  Specifically, until
  # the encounter event is saved, it doesn't know it's jursidiction.
  # However, if it's built from the parent record (which it should be)
  # we can look at the jursidiction of the morbidity event instead.
  describe "usage in webapp/app/views/events/_encounters_form.html.haml" do
    before do
      @morbidity_event = Factory.create(:morbidity_event)
      @encounter_event = @morbidity_event.encounter_child_events.build
      @jurisdiction = @morbidity_event.jurisdiction.place_entity
      @investegator_priv = Privilege.find_by_priv_name('investigate_event') || Factory(:privilege, :priv_name => 'investigate_event') 
      @investegator_role = Factory(:role)
      @investegator_role.privileges << @investegator_priv 
      @privledged_user.role_memberships.create(:role => @investegator_role, :jurisdiction => @jurisdiction)
    end
    
    it "should have no jursidiction defined on the encounter event" do
      assert_equal nil, @encounter_event.jurisdiction
    end
    it "should have a jurisdiction defined on the morbidity_event" do
      assert @morbidity_event.jurisdiction.is_a?(Jurisdiction)
      assert @morbidity_event.jurisdiction.place_entity.is_a?(PlaceEntity)
    end
    it "should use the parent_event to determine the jurisdiction when none is available for the encounter event" do
      assert_equal true, helper.users_for_investigation_select(@encounter_event).include?(@privledged_user)
      assert_equal false, helper.users_for_investigation_select(@encounter_event).include?(@unprivledged_user)
    end
  end 

end
