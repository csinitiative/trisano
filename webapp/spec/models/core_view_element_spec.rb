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

describe CoreViewElement do
  before(:each) do
    @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'cvespec')
    @form.save_and_initialize_form_elements
    @core_view_element = CoreViewElement.new
    @core_view_element.name = "demographics"
  end

  it "should be valid" do
    @core_view_element.should be_valid
  end
  
  describe "when determining available core views" do
    
    it "should return nil if no parent_element_id is set on the core view element" do
      @core_view_element.available_core_views.should be_nil
    end
    
    it "should return all core view names when none are in use" do
      @core_view_element.parent_element_id = @form.form_base_element.id
      available_core_views = @core_view_element.available_core_views
      available_core_views.size.should == 7
      available_core_views.flatten.uniq.include?("Demographics").should be_true
      available_core_views.flatten.uniq.include?("Clinical").should be_true
      available_core_views.flatten.uniq.include?("Laboratory").should be_true
      available_core_views.flatten.uniq.include?("Contacts").should be_true
      available_core_views.flatten.uniq.include?("Epidemiological").should be_true
      available_core_views.flatten.uniq.include?("Reporting").should be_true
      available_core_views.flatten.uniq.include?("Administrative").should be_true
    end
    
    it "should return only available core view names when some are in use" do
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'cvespec_2')
      form.save_and_initialize_form_elements
      demographic_core_config = CoreViewElement.new(:parent_element_id => form.core_view_elements_container.id, :name => "Demographics")
      clinical_core_config = CoreViewElement.new(:parent_element_id => form.core_view_elements_container.id, :name => "Clinical")
      demographic_core_config.save_and_add_to_form.should_not be_nil
      clinical_core_config.save_and_add_to_form.should_not be_nil
       
      @core_view_element.parent_element_id = form.core_view_elements_container.id
      available_core_views = @core_view_element.available_core_views
      available_core_views.size.should == 5
      available_core_views.flatten.uniq.include?("Demographics").should be_false
      available_core_views.flatten.uniq.include?("Clinical").should be_false
      available_core_views.flatten.uniq.include?("Laboratory").should be_true
      available_core_views.flatten.uniq.include?("Contacts").should be_true
      available_core_views.flatten.uniq.include?("Epidemiological").should be_true
      available_core_views.flatten.uniq.include?("Reporting").should be_true
      available_core_views.flatten.uniq.include?("Administrative").should be_true
    end
    
  end
  
  describe "when created with 'save and add to form'" do
    it "should be a child of the form's base" do
      @core_view_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_view_element.save_and_add_to_form.should_not be_nil
      @core_view_element.parent_id.should_not be_nil
      @form.investigator_view_elements_container.children[1].id.should == @core_view_element.id
    end
    
    it "should receive a tree id" do
      @core_view_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_view_element.save_and_add_to_form.should_not be_nil
      @core_view_element.tree_id.should_not be_nil
      @core_view_element.tree_id.should eql(@form.form_base_element.tree_id)
    end
    
    it "should fail if form validation fails" do
      @core_view_element.parent_element_id = @form.investigator_view_elements_container.id
      invalidate_form(@form)
      @core_view_element.save_and_add_to_form.should be_nil
      @core_view_element.errors.should_not be_empty
    end
  end
  
  describe "when updated" do
    it "should succeed if form validation passes" do
      @core_view_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_view_element.save_and_add_to_form.should_not be_nil
      @core_view_element.update_and_validate(:name => "Updated Name").should_not be_nil
      @core_view_element.name.should eql("Updated Name")
      @core_view_element.errors.should be_empty
    end

    it "should fail if form validation fails" do
      @core_view_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_view_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      @core_view_element.update_and_validate(:name => "Updated Name").should be_nil
      @core_view_element.errors.should_not be_empty
    end
  end
  
  describe "when deleted" do
    it "should succeed if form validation passes" do
      @core_view_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_view_element.save_and_add_to_form.should_not be_nil
      @core_view_element.destroy_and_validate.should_not be_nil
      @core_view_element.errors.should be_empty
    end

    it "should fail if form validation fails" do
      @core_view_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_view_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      @core_view_element.destroy_and_validate.should be_nil
      @core_view_element.errors.should_not be_empty
    end
  end


end
