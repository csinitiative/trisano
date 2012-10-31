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
require RAILS_ROOT + '/app/helpers/application_helper'

describe EventsHelper do

  describe "jurisdiction routing controls" do

    before do
      @current_user = Factory.create(:privileged_user)
      add_privileges_for(@current_user)
    end

    describe "for morbidity events" do
      before do
        @event = Factory.build(:morbidity_event)
        @event.jurisdiction.place_entity = @current_user.role_memberships.first.jurisdiction
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
        @event.jurisdiction.place_entity = @current_user.role_memberships.first.jurisdiction
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

    before do
      @parent_event = Factory.create(:morbidity_event)
      @encounter_event = Factory.create(:encounter_event, :parent_event => @parent_event)
    end

    it 'should display the patient name and disease for the parent event' do
      helper.original_patient_controls(@encounter_event).include?(@parent_event.party.full_name).should be_true
    end

    it "displays the disease for the parent event" do
      @encounter_event.stubs(:safe_call_chain).with(:parent_event, :disease_event, :disease, :disease_name).returns("Bubonic,Plague")
      helper.original_patient_controls(@encounter_event).include?("Bubonic,Plague").should be_true
    end

    describe "when the parent event has multiple contacts" do

      before do
        @contact_event = Factory.create(:contact_event, :parent_event => @parent_event)

        @promoted_event = Factory.create(:contact_event, :parent_event => @parent_event)
        login_as_super_user
        @promoted_event.promote_to_morbidity_event
      end

      it "displays a contact navigation widget, if parent has multiple contacts" do
        helper.original_patient_controls(@contact_event).should have_tag('select.events_nav')
      end

      it "displays a navigation message for promoted contacts" do
        helper.original_patient_controls(@contact_event).should have_tag('option', '--- Promoted Contacts ---')
      end

      it "displays a navigation message for contacts" do
        helper.original_patient_controls(@promoted_event).should have_tag('option', '--- Related Contacts  ---')
      end

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
      @core_field = Factory.create(:cmr_core_field,
                                   :key => "morbidity_event[test_attribute]",
                                   :help_text => "Here is some help text")
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

describe EventsHelper, "rendering core elements and sections" do
  def given_before_partials
    mock = helper.stubs(:before_core_partials)
    mock.returns({ 'morbidity_event[test_attribute]' => [{:partial => 'before_partial'}],
        'person_entity[test_attribute]'   => [] })
    helper.stubs(:render).with({:partial => 'before_partial', :locals => {:f => @fb}}).returns('<p>before partial</p>')
  end

  def given_after_partials
    mock = helper.stubs(:after_core_partials)
    mock.returns({ 'morbidity_event[test_attribute]' => [{:partial => 'after_partial'}],
        'person_entity[test_attribute]'   => [] })
    helper.stubs(:render).with({:partial => 'after_partial', :locals => {:f => @fb}}).returns('<p>after partial</p>')
  end

  def given_no_replacement_partials
    mock = helper.stubs(:core_replacement_partial)
    mock = mock.returns({})
  end

  shared_examples_for "event core element renderer" do
    it "does nothing if core field isn't rendered for this event" do
      @core_field.update_attributes!(:disease_specific => true)
      helper.send(@method_to_test, :test_attribute, @fb, :horiz) do
        fail "block shouldn't be called"
      end
      helper.output_buffer.should == ""
    end

    it "renders field if field should be rendered for this event" do
      helper.send(@method_to_test, :test_attribute, @fb, :horiz) do
        helper.concat('<p>This should render</p>')
      end
      helper.output_buffer.should have_tag('p', 'This should render')
    end

    it "renders before partials" do
      helper.send(@method_to_test, :test_attribute, @fb, :horiz) do
        helper.concat('<p>This should render</p>')
      end
      helper.output_buffer.should have_tag('p', 'before partial')
    end

    it "renders after partials" do
      helper.send(@method_to_test, :test_attribute, @fb, :horiz) do
        helper.concat('<p>This should render</p>')
      end
      helper.output_buffer.should have_tag('p', 'after partial')
    end
  end

  shared_examples_for "entity core element renderer" do
    it "ignores rendered? for disease specific fields" do
      helper.send(@method_to_test, :test_attribute, @fb, :horiz) do
        helper.concat('<p>This should render</p>')
      end
      helper.output_buffer.should have_tag('p', 'This should render')
    end

    it "ignores rendered? for core fields" do
      @core_field.update_attributes!(:disease_specific => false)
      helper.send(@method_to_test, :test_attribute, @fb, :horiz) do
        helper.concat('<p>This should render</p>')
      end
      helper.output_buffer.should have_tag('p', 'This should render')
    end
  end

  describe "on an event" do
    before do
      @core_field = Factory.create(:cmr_core_field,
        :key => 'morbidity_event[test_attribute]',
        :disease_specific => false)
      @fb = ExtendedFormBuilder.new('morbidity_event', nil, nil, {}, nil)
      helper.output_buffer = ""
      @event = Factory.create(:morbidity_event)
      assigns[:event] = @event

      given_before_partials
      given_after_partials
      given_no_replacement_partials
    end

    describe "core element in edit mode" do
      before { @method_to_test = :core_element }
      it_should_behave_like "event core element renderer"
    end

    describe "core element in show mode" do
      before { @method_to_test = :core_element_show }
      it_should_behave_like "event core element renderer"
    end

    describe "core element in print mode" do
      before { @method_to_test = :core_element_print }
      it_should_behave_like "event core element renderer"
    end

    describe "core section in edit or show" do
      before { @method_to_test = :core_section }
      it_should_behave_like "event core element renderer"
    end

  end

  describe "on person entity" do
    before do
      @core_field = Factory.create(:cmr_core_field,
        :key => 'person_entity[test_attribute]',
        :disease_specific => true)
      @fb = ExtendedFormBuilder.new('person_entity', nil, nil, {}, nil)
      helper.output_buffer = ""

      given_before_partials
      given_after_partials
      given_no_replacement_partials
    end

    describe "in edit mode" do
      before { @method_to_test = :core_element }
      it_should_behave_like "entity core element renderer"
    end

    describe "in show mode" do
      before { @method_to_test = :core_element_show }
      it_should_behave_like "entity core element renderer"
    end

    describe "in print mode" do
      before { @method_to_test = :core_element_print }
      it_should_behave_like "entity core element renderer"
    end

  end
end

describe EventsHelper, "rendering replacement partials" do

  def given_no_before_partials
    mock = helper.stubs(:before_core_partials)
    mock.returns(Hash.new {|hash, key| hash[key] = []})
  end

  def given_no_after_partials
    mock = helper.stubs(:after_core_partials)
    mock.returns(Hash.new {|hash, key| hash[key] = []})
  end

  def given_replacement_partials
    mock = helper.stubs(:core_replacement_partial)
    mock = mock.returns({"morbidity_event[test_attribute]"=>{:partial=> 'replacement_partial'}})
    helper.stubs(:render).with({:partial => 'replacement_partial', :locals => {:f => @fb}}).returns('<p>replacement partial</p>')
  end

  shared_examples_for "disease-specific core element replacer" do
    it "renders the replacement content if core field is replaced for the event" do
      Factory.create(:core_fields_disease, :core_field => @core_field, :disease => @event.disease.disease, :rendered => true, :replaced => true)

      helper.send(@method_to_test, :test_attribute, @fb, :horiz) do
        helper.concat('<p>original content</p>')
      end

      helper.output_buffer.should have_tag('p', 'replacement partial')
    end

    it "doesn't render the replacement content if core field is not replaced for the event" do
      Factory.create(:core_fields_disease, :core_field => @core_field, :disease => @event.disease.disease, :rendered => true, :replaced => false)

      helper.send(@method_to_test, :test_attribute, @fb, :horiz) do
        helper.concat('<p>original content</p>')
      end

      helper.output_buffer.should have_tag('p', 'original content')
    end
  end

  describe "on an event with a disease with disease-specific core field mappings" do
    before(:each) do
      @core_field = Factory.create(:cmr_core_field,
        :key => 'morbidity_event[test_attribute]',
        :disease_specific => true)
      @fb = ExtendedFormBuilder.new('morbidity_event', nil, nil, {}, nil)
      helper.output_buffer = ""
      @event = Factory.create(:morbidity_event_with_disease)
      assigns[:event] = @event

      given_no_before_partials
      given_no_after_partials
      given_replacement_partials
    end

    describe "in edit mode" do
      before { @method_to_test = :core_element }
      it_should_behave_like "disease-specific core element replacer"
    end

    describe "in show mode" do
      before { @method_to_test = :core_element_show }
      it_should_behave_like "disease-specific core element replacer"
    end

    describe "in print mode" do
      before { @method_to_test = :core_element_print }
      it_should_behave_like "disease-specific core element replacer"
    end
  end

  shared_examples_for "non-disease-specific core element replacer" do
    it "renders the replacement content" do
      helper.send(@method_to_test, :test_attribute, @fb, :horiz) do
        helper.concat('<p>original content</p>')
      end

      helper.output_buffer.should have_tag('p', 'replacement partial')
    end
  end

  describe "on an event with a disease without core field mappings and replacement partials configured" do
    before(:each) do
      @core_field = Factory.create(:cmr_core_field,
        :key => 'morbidity_event[test_attribute]',
        :disease_specific => false)
      @fb = ExtendedFormBuilder.new('morbidity_event', nil, nil, {}, nil)
      helper.output_buffer = ""
      @event = Factory.create(:morbidity_event_with_disease)
      assigns[:event] = @event

      given_no_before_partials
      given_no_after_partials
      given_replacement_partials
    end

    describe "in edit mode" do
      before { @method_to_test = :core_element }
      it_should_behave_like "non-disease-specific core element replacer"
    end

    describe "in show mode" do
      before { @method_to_test = :core_element_show }
      it_should_behave_like "non-disease-specific core element replacer"
    end

    describe "in print mode" do
      before { @method_to_test = :core_element_print }
      it_should_behave_like "non-disease-specific core element replacer"
    end
  end

end
