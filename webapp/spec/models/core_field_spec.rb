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

describe CoreField do
  before :all do
    destroy_fixture_data
  end

  after :all do
    Fixtures.reset_cache
  end

  before :each do
    @core_field = Factory.create(:cmr_core_field)
  end

  after { I18n.locale = :en }

  it { should have_many(:core_fields_diseases) }
  it { should have_many(:diseases) }
  it { should validate_presence_of(:field_type) }
  it { should validate_presence_of(:event_type) }

  it "should update help text" do
    @core_field.help_text = 'Here is some help text'
    @core_field.save.should be_true
    CoreField.find_by_key(@core_field.key).help_text.should == 'Here is some help text'
  end

  it 'should provide hashes based on event type' do
    CoreField.event_fields('morbidity_event').size.should == 1
    CoreField.event_fields('contact_event').size.should == 0
    CoreField.event_fields('place_event').size.should == 0
  end

  it 'should provide hashes based on event' do
    CoreField.event_fields(MorbidityEvent.new).size.should == 1
  end

  it 'should return fields based on key' do
    hash = CoreField.event_fields('morbidity_event')
    hash[@core_field.key].should_not be_nil
  end

  it "should memoize fields for rendering" do
    hash = CoreField.event_fields('morbidity_event')
    old_field = hash[@core_field.key]
    CoreField.all(:conditions => ["key=?", @core_field.key]).each do |cf|
      cf.help_text = 'some help text'
      cf.save
    end
    hash = CoreField.event_fields('morbidity_event')
    old_field.object_id.should_not == hash[@core_field.key].object_id
  end

  it "event_fields should return hash of core fields" do
    hash = CoreField.event_fields('morbidity_event')
    hash[@core_field.key].class.should == CoreField
  end

  it "should pull english translations for name" do
    I18n.locale = :en
    cf = Factory.create(:cmr_core_field, :key => 'morbidity_event[places]')
    cf.name.should == 'Places'
  end

  it "should return scope for I18n retrieval" do
    cf = Factory.create(:cmr_core_field, :key => 'morbidity_event[places]')
    cf.i18n_scope.should == ['event_fields', 'morbidity_event']
  end

  it "should return the name key for i18n retrieval" do
    cf = Factory.create(:cmr_core_field, :key => 'morbidity_event[places]')
    cf.name_key.should == 'places'
  end

  shared_examples_for "disease is associated" do

    it "should be rendered if disease association is for showing the field" do
      @cf.update_attributes :rendered_attributes => { :rendered => true, :disease_id => @disease.id }
      @cf.should be_rendered_on_event(@event)
    end

    it "should not be rendered if association is for hiding field" do
      @cf.update_attributes :rendered_attributes => { :rendered => false, :disease_id => @disease.id }
      @cf.should_not be_rendered_on_event(@event)
    end

    it "should persist updates to the disease association" do
      @cf.update_attributes :rendered_attributes => { :rendered => true, :disease_id => @disease.id }
      @cf.should be_rendered_on_event(@event)
      @cf.update_attributes :rendered_attributes => { :rendered => false, :disease_id => @disease.id }
      @cf.should_not be_rendered_on_event(@event)
    end
  end

  describe "rendering disease specific core fields" do
    before do
      @event = Factory.create(:morbidity_event)
      @disease = Factory.create(:disease)
      @event.build_disease_event(:disease => @disease).save!
      @cf = Factory.create(:cmr_core_field, :disease_specific => true)
    end

    it "should be disease specific" do
      @cf.should be_disease_specific
    end

    it "should not render if no disease is associated" do
      @cf.should_not be_rendered_on_event(@event)
    end

    it "should not be rendered if event is nil" do
      Factory.create(:core_fields_disease, :disease => @disease, :core_field => @cf)
      @cf.should_not be_rendered_on_event(nil)
    end

    it "should not render if event's disease is not associated" do
      @event.disease_event.update_attributes!(:disease => Factory.create(:disease))
      Factory.create(:core_fields_disease, :disease => @disease, :core_field => @cf)
      @cf.should_not be_rendered_on_event(@event)
    end

    it_should_behave_like "disease is associated"

  end

  describe "regular ol' core fields" do
    before do
      @event = Factory.create(:morbidity_event)
      @disease = Factory.create(:disease)
      @event.build_disease_event(:disease => @disease).save!
      @cf = Factory.create(:cmr_core_field)
    end

    it "should not be disease specific" do
      @cf.should_not be_disease_specific
    end

    it "should be rendered if event's disease is associated" do
      @cf.should be_rendered_on_event(@event)
    end

    it "should be rendered if event is nil" do
      Factory.create(:core_fields_disease, :disease => @disease, :core_field => @cf)
      @cf.should be_rendered_on_event(nil)
    end

    it "should be rendered if event's disease is not associated" do
      Factory.create(:core_fields_disease,
        :disease => Factory.create(:disease),
        :core_field => @cf)
      @cf.should be_rendered_on_event(@event)
    end

    it_should_behave_like "disease is associated"
  end

  describe "replacing disease-specific core fields" do
    before do
      @event = Factory.create(:morbidity_event)
      @disease = Factory.create(:disease)
      @event.build_disease_event(:disease => @disease).save!
      @cf = Factory.create(:cmr_core_field, :disease_specific => true)
    end

    it "should not replace if no disease is associated" do
      @cf.should_not be_replaced(@event)
    end

    it "should not be replaced if event is nil" do
      Factory.create(:core_fields_disease, :disease => @disease, :core_field => @cf, :rendered => true, :replaced => true)
      @cf.should_not be_replaced(nil)
    end

    it "should not replace if event's disease is not associated" do
      @event.disease_event.update_attributes!(:disease => Factory.create(:disease))
      Factory.create(:core_fields_disease, :disease => @disease, :core_field => @cf, :rendered => true, :replaced => true)
      @cf.should_not be_replaced(@event)
    end

    it "should replace if disease association is for replacing the field" do
      Factory.create(:core_fields_disease, :disease => @disease, :core_field => @cf, :rendered => true, :replaced => true)
      @cf.should be_replaced(@event)
    end

    it "should not replace if disease association is not for replacing the field" do
      Factory.create(:core_fields_disease, :disease => @disease, :core_field => @cf, :rendered => true, :replaced => false)
      @cf.should_not be_replaced(@event)
    end
  end

  describe "replacing non-disease-specific core fields" do
    before do
      @event = Factory.create(:morbidity_event)
      @disease = Factory.create(:disease)
      @event.build_disease_event(:disease => @disease).save!
      @cf = Factory.create(:cmr_core_field, :disease_specific => false)
    end

    it "should replace if no disease is associated" do
      @cf.should be_replaced(@event)
    end

    it "should be replaced if event is nil" do
      @cf.should be_replaced(nil)
    end
  end

  describe "sections" do
    before do
      @section = Factory.create(:cmr_section_core_field)
      @core_field = Factory.create(:cmr_core_field, :tree_id => @section.tree_id)
    end

    it { @section.should be_a_section }

    it "should act as a nested set" do
      lambda do
        @section.add_child @core_field
      end.should change(@section, :children_count).by(1)
    end
  end

  describe "required for an event" do
    before do
      @core_field = Factory.build :cmr_core_field, {
        :required_for_event => true,
        :rendered_attributes => { :rendered => false }
      }
      @core_field.save
    end

    it "is invalid if hidden" do
      @core_field.should_not be_valid
      @core_field.errors.full_messages.map(&:strip).should == ["#{@core_field.name} is required for Morbidity Events"]
    end

    it "is required" do
      @core_field.should be_required
    end
  end

  describe "with a hidden disease association" do
    before do
      @disease = Factory.create :disease
      @core_field = Factory.create :cmr_core_field, :required_for_event => true
      @core_field.update_attributes  :rendered_attributes => {
        :rendered => false,
        :disease_id => @disease.id
      }
    end

    it "is invalid, if requird for event" do
      @core_field.should_not be_valid
      @core_field.errors.full_messages.map(&:strip).should == ["#{@core_field.name} is required for Morbidity Events"]
    end

  end

  describe "with at least one descendant that is required for an event" do
    before do
      @tab = Factory.create :cmr_tab_core_field
      @section = Factory.create :cmr_section_core_field, {
        :tree_id => @tab.tree_id
      }
      @core_field = Factory.create :cmr_core_field, {
        :tree_id => @section.tree_id,
        :required_for_event => true
      }
      @tab.add_child @section
      @section.add_child @core_field
    end

    it "is invalid if hidden (section)" do
      @section.update_attributes :rendered_attributes => { :rendered => false }
      @section.should_not be_valid
      @section.errors.full_messages.map(&:strip).should == ["The #{@section.name} section contains required fields"]
    end

    it "is invalid if hidden (tab)" do
      @tab.update_attributes :rendered_attributes => { :rendered => false }
      @tab.should_not be_valid
      @tab.errors.full_messages.map(&:strip).should == ["The #{@tab.name} tab contains required fields"]
    end

    it "is required" do
      @section.should be_required
      @tab.should be_required
    end
  end

  describe "required for a section" do
    before do
      @disease = Factory.create :disease
      @section = Factory.create :cmr_section_core_field
      @core_field = Factory.create :cmr_core_field, {
        :required_for_section => true,
        :tree_id => @section.tree_id,
      }
      @section.add_child @core_field
    end

    it "is invalid if hidden" do
      @core_field.update_attributes :rendered_attributes => { :rendered => false }
      @core_field.should_not be_valid
      @core_field.errors.full_messages.map(&:strip).should == ["#{@core_field.name} is required for #{@core_field.parent.try(:name)} section"]
    end

    it "can be hidden with its section" do
      @section.update_attributes :rendered_attributes => { :rendered => false }
      @core_field.should be_valid
      @section.should be_valid
    end

    it "is invalid if hidden by a disease association" do
      @core_field.update_attributes :rendered_attributes => {
        :rendered => false,
        :disease_id => @disease.id
      }
      @core_field.should_not be_valid
      @core_field.should have(1).error_on(:rendered_attributes)
    end

    it "can be hidden with its section by a disease association" do
      @section.update_attributes :rendered_attributes => {
        :rendered => false,
        :disease_id => @disease.id
      }
      @core_field.should be_valid
      @section.should be_valid
    end

    it "makes the field required" do
      @core_field.should be_required
    end

    it "does not make the section required" do
      @section.should_not be_required
    end
  end

  describe "#hidden_by_ancestry?" do
    before do
      @tab = Factory.create :cmr_tab_core_field
      @section = Factory.create :cmr_section_core_field, {
        :tree_id => @tab.tree_id
      }
      @core_field = Factory.create :cmr_core_field, {
        :tree_id => @section.tree_id,
      }
      @tab.add_child @section
      @section.add_child @core_field
    end

    it "is not true if this field is hidden" do
      @core_field.update_attributes :rendered_attributes => { :rendered => false }
      @core_field.should_not be_hidden_by_ancestry(nil)
    end

    it "is true when an immediate parent is hidden" do
      @section.update_attributes :rendered_attributes => { :rendered => false }
      @core_field.should be_hidden_by_ancestry(nil)
    end

    it "is hidden when any ancestor is hidden" do
      @tab.update_attributes :rendered_attributes => { :rendered => false }
      @core_field.should be_hidden_by_ancestry(nil)
    end
  end

  describe "#hidden?" do
    before do
      @tab = Factory.create :cmr_tab_core_field
      @section = Factory.create :cmr_section_core_field, {
        :tree_id => @tab.tree_id
      }
      @core_field = Factory.create :cmr_core_field, {
        :tree_id => @section.tree_id,
      }
      @tab.add_child @section
      @section.add_child @core_field
    end

    it "is true if this field is hidden" do
      @core_field.update_attributes :rendered_attributes => { :rendered => false }
      @core_field.should be_hidden(nil)
    end

    it "is true when an immediate parent is hidden" do
      @section.update_attributes :rendered_attributes => { :rendered => false }
      @core_field.should be_hidden(nil)
    end

    it "is hidden when any ancestor is hidden" do
      @tab.update_attributes :rendered_attributes => { :rendered => false }
      @core_field.should be_hidden(nil)
    end
  end

end
