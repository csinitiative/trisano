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

describe ValueSetElement do
  before(:each) do
    @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'value_set_short_name')
    @form.save_and_initialize_form_elements
    @question_element = QuestionElement.new({
        :parent_element_id => @form.investigator_view_elements_container.id,
        :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
      })
    @question_element.save_and_add_to_form
    @value_set_element = ValueSetElement.new
    @value_set_element.name = "Test"
    @value_set_element.parent_element_id = @question_element.id
  end

  it "should be valid" do
    @value_set_element.should be_valid
  end

  describe "when created with 'save and add to form'" do
    it "should be a child of the question provided" do
      @value_set_element.save_and_add_to_form
      @value_set_element.parent_id.should_not be_nil
      question_element = FormElement.find(@question_element.id)
      question_element.children[0].id.should == @value_set_element.id
    end

    it "should be receive a tree id" do
      @value_set_element.save_and_add_to_form
      @value_set_element.tree_id.should_not be_nil
      @value_set_element.tree_id.should eql(@question_element.tree_id)
    end

    it "should fail if form validation fails" do
      invalidate_form(@form)
      @value_set_element.save_and_add_to_form.should be_nil
      @value_set_element.errors.should_not be_empty
    end

    it "should fail if the question it is being added to already has a value set" do
      @value_set_element.save_and_add_to_form.should_not be_nil
      @value_set_element.tree_id
      @question_element.children.size.should == 1

      another_value_set_element = ValueSetElement.new
      another_value_set_element.name = "Test"
      another_value_set_element.parent_element_id = @question_element.id
      another_value_set_element.save_and_add_to_form.should be_nil
      @question_element.children.size.should == 1

    end

    it "can be added (with it's children) to the library" do
      @value_set_element.save_and_add_to_form
      @value_set_element.stubs(:children).returns [Factory(:value_element)]
      @value_set_element.add_to_library.should be_true
    end
  end

  describe "when updated" do
    it "should succeed if form validation passes" do
      @value_set_element.save_and_add_to_form
      @value_set_element.update_and_validate(:name => "Updated Name").should_not be_nil
      @value_set_element.name.should eql("Updated Name")
      @value_set_element.errors.should be_empty
    end

    it "should fail if form validation fails" do
      @value_set_element.save_and_add_to_form
      invalidate_form(@form)
      @value_set_element.update_and_validate(:name => "Updated Name").should be_nil
      @value_set_element.errors.should_not be_empty
    end
  end

  describe "when deleted" do
    it "should succeed if form validation passes" do
      @value_set_element.save_and_add_to_form
      @value_set_element.destroy_and_validate.should_not be_nil
      @value_set_element.errors.should be_empty
    end

    it "should fail if form validation fails" do
      @value_set_element.save_and_add_to_form
      invalidate_form(@form)
      @value_set_element.destroy_and_validate.should be_nil
      @value_set_element.errors.should_not be_empty
    end
  end

  describe "custom errors" do
    it "should error as too many value sets" do
      mock_parent = Factory.build(:form_element)
      mock_parent.stubs(:can_receive_value_set?).returns(false)
      FormElement.stubs(:find).returns(mock_parent)
      @value_set_element.save_and_add_to_form
      @value_set_element.errors.on_base.should == 'A question can only have one value set'
    end

    it "should error if bad parent" do
      FormElement.stubs(:find).raises
      @value_set_element.save_and_add_to_form
      @value_set_element.errors.on_base.should == 'An error occurred checking the parent for existing value set children'
    end
  end

end
