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
require RAILS_ROOT + '/app/helpers/application_helper'

describe EventsHelper do
  include ApplicationHelper
  include EventsHelperSpecHelper
  include EventsSpecHelper

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
      @event = Factory.create(:morbidity_event)
      @encounter_event = Factory.create(:encounter_event)
      @encounter_event.stubs(:parent_event).returns(@event)
      @encounter_event.stubs(:safe_call_chain).with(:parent_event, :disease_event, :disease, :disease_name).returns("Bubonic,Plague")
      helper.original_patient_controls(@encounter_event).include?(@event.party.full_name).should be_true
      helper.original_patient_controls(@encounter_event).include?("Bubonic,Plague").should be_true
    end

  end

  describe "association recorded helper" do

    it 'should return false if the provided association is empty' do
      @event = Factory.create(:morbidity_event)
      @event.stubs(:contact_child_events).returns([])
      helper.association_recorded?(@event.contact_child_events).should be_false
    end

    it 'should return false if the first record in the association is a new record' do
      contact = Factory.build(:contact_event)
      helper.association_recorded?([contact]).should be_false
    end

    it 'should return true if association has a persisted object in it' do
      contact = Factory.create(:contact_event)
      helper.association_recorded?([contact]).should be_true
    end

  end

  describe 'rendering' do
    it "should render core field help text" do
      @core_field = CoreField.create!({ :event_type => :morbidity_event,
                                        :key => "morbidity_event[test_attribute]",
                                        :help_text => "Here is some help text"})
      @event = Factory.create(:morbidity_event)
      @fb = mock
      @fb.expects(:core_field).with(:test_attribute).returns(@core_field)
      result = helper.render_core_field_help_text(:test_attribute, @fb, @event)
      result.should have_tag('p', "Here is some help text")
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

describe EventsHelper, "rendering core elements" do
  describe "on an event" do
    before do
      @core_field = Factory.create(:cmr_core_field,
                                   :key => 'morbidity_event[test_attribute]',
                                   :disease_specific => true)
      @fb = ExtendedFormBuilder.new('morbidity_event', nil, nil, {}, nil)
      helper.stubs(:core_element_renderers).returns({})
      helper.output_buffer = ""
      @event = Factory.create(:morbidity_event)
      assigns[:event] = @event
    end

    it "does nothing if core field isn't rendered for this event" do
      helper.core_element(:test_attribute, @fb, :horiz) do
        fail "block shouldn't be called"
      end
      helper.output_buffer.should == ""
    end

    it "renders field if field should be rendered for this event" do
      @core_field.update_attributes!(:disease_specific => false)
      helper.core_element(:test_attribute, @fb, :horiz) do
        helper.concat('<p>This should render</p>')
      end
      helper.output_buffer.should have_tag('p', 'This should render')
    end
  end

  describe "on person entity" do
    before do
      @core_field = Factory.create(:cmr_core_field,
                                   :key => 'person_entity[test_attribute]',
                                   :disease_specific => true)
      @fb = ExtendedFormBuilder.new('person_entity', nil, nil, {}, nil)
      helper.stubs(:core_element_renderers).returns({})
      helper.output_buffer = ""
    end

    it "ignores rendered? for disease specific fields" do
      helper.core_element(:test_attribute, @fb, :horiz) do
        helper.concat('<p>This should render</p>')
      end
      helper.output_buffer.should have_tag('p', 'This should render')
    end

    it "ignores rendered? for core fields" do
      @core_field.update_attributes!(:disease_specific => false)
      helper.core_element(:test_attribute, @fb, :horiz) do
        helper.concat('<p>This should render</p>')
      end
      helper.output_buffer.should have_tag('p', 'This should render')
    end
  end
end
