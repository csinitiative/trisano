# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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
require RAILS_ROOT + '/app/helpers/application_helper'

describe EventsHelper do
  include ApplicationHelper
  include EventsHelperSpecHelper

  describe "jurisdiction routing controls" do

    before do
      @current_user = Factory.create(:privileged_user)
      add_privileges_for(@current_user)
    end

    describe "for morbidity events" do
      before do
        @event = Factory.build(:morbidity_event)
        @event.jurisdiction.build(:secondary_entity_id => @current_user.role_memberships.first.jurisdiction_id)
        @event.save!
      end

      it "should submit jurisdiction changes to cmr controller" do
        controls = helper.jurisdiction_routing_control(@event)
        controls.should =~ /action=[\"|\']\/cmrs/
      end
    end

    describe "for contact events" do
      before do
        @event = Factory.build(:contact_event)
        @event.jurisdiction.build(:secondary_entity_id => @current_user.role_memberships.first.jurisdiction_id)
        @event.save!
      end

      it "should submit jurisdiction changes to the contact controller" do
        controls = helper.jurisdiction_routing_control(@event)
        controls.should =~ /action=[\"|\']\/contact_events/
      end
    end

  end

  describe "the state_controls method" do

    before do
      @current_user = Factory(:privileged_user)
      add_privileges_for(@current_user)
    end

    describe "when a morb event state is 'asssigned to LHD'" do
      before(:each) do
        @event = Factory.create(:morbidity_event)
        login_as_super_user
        @event.assign_to_lhd(User.current_user.role_memberships.first.jurisdiction_id, [])
      end

      it "should return a properly constructed form that posts to the morbidity event's controller's state action" do
        form = helper.state_controls(@event)
        form.should =~ /action=[\"|\']\/cmrs\/\d+\/state/
      end
    end

    describe "when a contact event state is 'asssigned to LHD'" do
      before(:each) do
        @event = Factory.create(:contact_event)
        login_as_super_user
        @event.assign_to_lhd(User.current_user.role_memberships.first.jurisdiction_id, [])
      end

      it "should return a properly constructed form that posts to the morbidity event's controller's state action" do
        form = helper.state_controls(@event)
        form.should =~ /action=[\"|\']\/contact_events\/\d+\/state/
      end
    end
  end

  describe "original patient controls" do

    it 'should display the patient name and disease for the parent event' do
      @event = mock_event
      @encounter_event = mock_model(EncounterEvent)
      @encounter_event.stub!(:parent_event).and_return(@event)
      @encounter_event.stub!(:safe_call_chain).with(:parent_event, :disease_event, :disease, :disease_name).and_return("Bubonic,Plague")
      helper.original_patient_controls(@encounter_event).include?("Groucho Marx").should be_true
      helper.original_patient_controls(@encounter_event).include?("Bubonic,Plague").should be_true
    end

  end

  describe "association recorded helper" do

    it 'should return false if the provided association is empty' do
      @event = mock_event
      @event.stub!(:child_contact_events).and_return([])
      helper.association_recorded?(@event.child_contact_events).should be_false
    end

    it 'should return false if the first record in the association is a new record' do
      @event = mock_event
      @child_event_proxy = mock(Object)
      @new_record = mock(Object)
      @new_record.stub!(:new_record?).and_return(true)
      @child_event_proxy.stub!(:respond_to?).and_return(true)
      @child_event_proxy.stub!(:empty?).and_return(false)
      @child_event_proxy.stub!(:first).and_return(@new_record)
      @event.stub!(:child_contact_events).and_return(@child_event_proxy)
      helper.association_recorded?(@event.child_contact_events).should be_false
    end

    it 'should return true if association has a persisted object in it' do
      @event = mock_event
      @child_event_proxy = mock(Object)
      @new_record = mock(Object)
      @new_record.stub!(:new_record?).and_return(false)
      @child_event_proxy.stub!(:respond_to?).and_return(true)
      @child_event_proxy.stub!(:empty?).and_return(false)
      @child_event_proxy.stub!(:first).and_return(@new_record)
      @event.stub!(:child_contact_events).and_return(@child_event_proxy)
      helper.association_recorded?(@event.child_contact_events).should be_true
    end

  end

  describe 'rendering' do
    it "should render core field help text" do
      @core_field = CoreField.create!({ :event_type => :morbidity_event,
                                        :key => "morbidity_event[test_attribute]",
                                        :help_text => "Here is some help text"})
      @event = Factory.create(:morbidity_event)
      @fb = mock
      @fb.stub!(:core_path).and_return(:test_attribute => "morbidity_event[test_attribute]")
      helper.render_core_field_help_text(:test_attribute, @fb, @event).should =~ /Here is some help text/i
    end
  end

  describe "show and edit event links" do

    it "for Morbidity events" do
      assert_event_links(:morbidity_event, 'Show CMR', 'Edit CMR')
    end

    it "for Contact events" do
      assert_event_links(:contact_event, 'Show Contact', 'Edit Contact')
    end

    it "for Place events" do
      assert_event_links(:place_event, 'Show Place', 'Edit Place')
    end

    it "for Encounter events" do
      assert_event_links(:encounter_event, 'Show Encounter', 'Edit Encounter')
    end

  end
end
