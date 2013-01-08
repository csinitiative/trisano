# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

describe CoreFieldElement do

  before(:each) do
    destroy_fixture_data
    @form = Form.new(:name => 'Test form', :event_type => 'morbidity_event', :short_name => 'cfespec')
    @form.save_and_initialize_form_elements
    @core_field_element = CoreFieldElement.new
    Factory.create(:cmr_core_field, :key => 'morbidity_event[places]',       :fb_accessible => true)
    Factory.create(:cmr_core_field, :key => 'morbidity_event[other_data_1]', :fb_accessible => true)
    Factory.create(:cmr_core_field, :key => 'morbidity_event[other_data_2]', :fb_accessible => true)
    Factory.create(:cmr_core_field, :key => 'morbidity_event[acuity]',       :fb_accessible => false)

    @core_field_element.core_path = 'morbidity_event[places]'
  end

  after(:all) do
    Fixtures.reset_cache
  end

  it "should be valid" do
    @core_field_element.name = "name"
    @core_field_element.should be_valid
  end

  it "should not save to form if core_path is blank" do
    @core_field_element.core_path = ""
    @core_field_element.save_and_add_to_form.should == nil
    @core_field_element.errors.on(:base).should == "Core path is required."
  end

  describe "when determining available core fields" do
    it "should return nil if no parent_element_id is set on the core field element" do
      @core_field_element.available_core_fields.should be_nil
    end

    it "should return all core field names when none are in use" do
      @core_field_element.parent_element_id = @form.form_base_element.id
      available_core_fields = @core_field_element.available_core_fields
      available_core_fields.size.should == 3
      available_core_fields.flatten.include?('morbidity_event[places]').should be_true
    end

    it "should return only available core view names when some are in use" do
      base_element_id = @form.form_base_element.id

      patient_last_name_field_config = CoreFieldElement.new(
        :parent_element_id => @form.core_field_elements_container.id,
        :core_path => 'morbidity_event[places]'
      )
      patient_last_name_field_config.save_and_add_to_form.should_not be_nil

      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      available_core_fields = @core_field_element.available_core_fields
      available_core_fields.size.should ==  2
      available_core_fields.flatten.include?('morbidity_event[places]').should be_false
    end

    it "should not return any fields that are not accessible to form builder" do
      @core_field_element.parent_element_id = @form.form_base_element.id
      available_core_fields = @core_field_element.available_core_fields
      available_core_fields.detect { |field| field[1] == 'key_4' }.should be_nil
    end

  end

  describe "when created with 'save and add to form'" do
    it "should be a child of the form's base" do
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.parent_id.should_not be_nil
      @form.core_field_elements_container.children[0].id.should == @core_field_element.id
    end

    it "should have a name" do
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.reload
      @core_field_element.name.should eql('Places')
    end

    it "should override any name provided with the one from the core field" do
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      @core_field_element.name = "name assigned"
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.reload
      @core_field_element.name.should eql('Places')
    end

    it "should receive a tree id" do
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.tree_id.should_not be_nil
      @core_field_element.tree_id.should eql(@form.form_base_element.tree_id)
    end

    it "should bootstrap the before and after core field elements" do
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.children.size.should eql(2)
      @core_field_element.children[0].is_a?(BeforeCoreFieldElement).should be_true
      @core_field_element.children[1].is_a?(AfterCoreFieldElement).should be_true
    end

    it "should fail if form validation fails" do
      @core_field_element.parent_element_id = @form.investigator_view_elements_container.id
      invalidate_form(@form)
      @core_field_element.save_and_add_to_form.should be_nil
      @core_field_element.errors.should_not be_empty
    end
  end

  describe "when deleted" do
    it "should succeed if form validation passes" do
      @core_field_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.destroy_and_validate.should_not be_nil
      @core_field_element.errors.should be_empty
    end

    it "should fail if form validation fails" do
      @core_field_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      @core_field_element.destroy_and_validate.should be_nil
      @core_field_element.errors.should_not be_empty
    end
  end

end
