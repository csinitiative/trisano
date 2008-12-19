# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

describe FormElement do
  before(:each) do
    @form_element = FormElement.new
  end

  it "should be valid" do
    @form_element.should be_valid
  end
  
  it "should count children by type" do
    @form_base_element = FormBaseElement.create(:tree_id => 1, :form_id => 1, :name => "base")
    @view_element = ViewElement.create(:tree_id => 1, :form_id => 1, :name => "view")
    @view_element2 = ViewElement.create(:tree_id => 1, :form_id => 1, :name => "view 2")
    @section_element = SectionElement.create(:tree_id => 1, :form_id => 1, :name => "section")
    
    @form_base_element.add_child(@view_element)
    @form_base_element.add_child(@view_element2)
    @form_base_element.add_child(@section_element)
    
    @form_base_element.children_count_by_type("ViewElement").should == 2
    @form_base_element.children_count_by_type("SectionElement").should == 1
  end
    
  it "should return children by type" do
    @form_base_element = FormBaseElement.create(:tree_id => 1, :form_id => 1, :name => "base")
    @view_element = ViewElement.create(:tree_id => 1, :form_id => 1, :name => "view")
    @view_element2 = ViewElement.create(:tree_id => 1, :form_id => 1, :name => "view 2")
    @section_element = SectionElement.create(:tree_id => 1, :form_id => 1, :name => "section")
    
    @form_base_element.add_child(@view_element)
    @form_base_element.add_child(@view_element2)
    @form_base_element.add_child(@section_element)
    
    view_children = @form_base_element.children_by_type("ViewElement")
    view_children.size.should == 2
    view_children[0].is_a?(ViewElement).should be_true
    
  end
  
end

describe "Quesiton FormElement" do
  before(:each) do
    @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event')
    @form.save_and_initialize_form_elements
    @question_element = QuestionElement.new({
        :parent_element_id => @form.investigator_view_elements_container.id,
        :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text"}
      })
    
    @question_element.save_and_add_to_form.should_not be_nil
    @question = @question_element.question
  end

  it "should destroy associated question" do
    question_element_id =@question_element.id
    question_id = @question.id
    
    FormElement.exists?(question_element_id).should be_true
    Question.exists?(question_id).should be_true
    
    @question_element.destroy_and_validate
    FormElement.exists?(question_element_id).should be_false
    Question.exists?(question_id).should be_false
  end
end

describe "Quesiton FormElement when added to library" do
  
  before(:each) do
    @question = Question.create({:question_text => "Que?", :data_type => "single_line_text", :short_name => "que_q" })
    @form_element = QuestionElement.create(:tree_id => 1, :form_id => 1, :question => @question)
  end
  
  it "the copy should have a correct ids and type" do
    @library_question = @form_element.add_to_library(nil)
    @library_question.id.should_not be_nil
    @library_question.form_id.should be_nil
    @library_question.template_id.should be_nil
    @library_question.parent_id.should be_nil
    @library_question.type.should eql("QuestionElement")
    @library_question.tree_id.should_not be_nil
    @library_question.tree_id.should_not eql(@form_element.tree_id)
  end
    
  it "the copy should be a template" do
    @library_question = @form_element.add_to_library(nil)
    @library_question.is_template.should be_true
  end
    
  it "the question copy should be a clone of the question it was created from" do
    @library_question = @form_element.add_to_library(nil)
    @library_question.question.should_not be_nil
    @library_question.question.question_text.should eql(@question.question_text)
    @library_question.question.data_type.should eql(@question.data_type)
    @library_question.question.short_name.should eql(@question.short_name)
  end
    
  it "the copy should have follow up questions" do
    follow_up_container = FollowUpElement.create({:tree_id => 1, :form_id => 1,:name => "Follow up", :condition => "Yes"})
    follow_up_question = Question.create({:question_text => "Did you do it?", :data_type => "single_line_text"})
    follow_up_question_element = QuestionElement.create(:tree_id => 1, :form_id => 1, :question => follow_up_question)
    follow_up_container.add_child(follow_up_question_element)
    @form_element.add_child(follow_up_container)
    
    @library_question = @form_element.add_to_library(nil)
    follow_up_copy = @library_question.children[0]
    follow_up_copy.name.should eql(follow_up_container.name)
    follow_up_copy.condition.should eql(follow_up_container.condition)
    
    follow_up_copy_quesiton_element = follow_up_copy.children[0]
    follow_up_copy_quesiton_element.should_not be_nil
    follow_up_copy_quesiton_element.question.should_not be_nil
    follow_up_copy_quesiton_element.question.question_text.should eql(follow_up_question.question_text)
    follow_up_copy_quesiton_element.question.data_type.should eql(follow_up_question.data_type)
  end
   
end

describe "FormElement copying from library" do
  
  before(:each) do
    @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event')
    @form.save_and_initialize_form_elements

    @group_tree_id = 9999
    @group_element = GroupElement.create(:name => "Test Group", :tree_id => @group_tree_id)
      
    @independent_value_set = ValueSetElement.create(:name => "Indie Value Set", :tree_id => @group_tree_id)
    @group_element.add_child(@independent_value_set)
      
    @indie_value_1 = ValueElement.create(:name => "Yes", :tree_id => @group_tree_id)
    @indie_value_2 = ValueElement.create(:name => "No", :tree_id => @group_tree_id)
    @independent_value_set.add_child(@indie_value_1)
    @independent_value_set.add_child(@indie_value_2)
      
    @question_with_value_set = Question.create(
      :question_text => "How's it going?", 
      :data_type => "drop_down")
    @question_element_with_value_set = QuestionElement.create(:tree_id => @group_tree_id, :question => @question_with_value_set)
    @group_element.add_child(@question_element_with_value_set)
    
    @dependent_value_set = ValueSetElement.create(:name => "Dependent Value Set", :tree_id => @group_tree_id)
    @question_element_with_value_set.add_child(@dependent_value_set)
      
    @dependent_value_1 = ValueElement.create(:name => "Maybe", :tree_id => @group_tree_id)
    @dependent_value_2 = ValueElement.create(:name => "Sometimes", :tree_id => @group_tree_id)
    @dependent_value_set.add_child(@dependent_value_1)
    @dependent_value_set.add_child(@dependent_value_2)
      
    @question_without_value_set = Question.create(
      :question_text => "Explain.", 
      :data_type => "single_line_text")
    @question_element_without_value_set = QuestionElement.create(:tree_id => @group_tree_id, :question => @question_without_value_set)
    @group_element.add_child(@question_element_without_value_set)

  end
    
  describe "when copying a group to a section" do
    
    it "should copy all children of the group that are not value sets and bring questions with question elements" do
      to_element = SectionElement.new(:name => "Section", :parent_element_id => @form.investigator_view_elements_container.id)
      to_element.save_and_add_to_form.should_not be_nil
      
      to_element.children.size.should eql(0)
      @group_element.children.size.should eql(3)
      
      to_element.copy_from_library(@group_element)
      
      to_element.children.size.should eql(1)
      copied_group = to_element.children[0]
      copied_group.should_not be_nil
      copied_group.is_a?(GroupElement).should be_true
      
      copied_group.children.size.should eql(2)
      copied_group.children[0].is_a?(QuestionElement).should be_true
      copied_group.children[1].is_a?(QuestionElement).should be_true
      
      copied_group.children[0].question.should_not be_nil
      copied_group.children[0].question.question_text.should eql("How's it going?")
      copied_group.children[1].question.should_not be_nil
      copied_group.children[1].question.question_text.should eql("Explain.")
    end
    
    it "shouldn't copy anything if the form is invalid" do
      to_element = SectionElement.new(:name => "Section", :parent_element_id => @form.investigator_view_elements_container.id)
      to_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      to_element.copy_from_library(@group_element).should be_nil
      to_element.errors.should_not be_empty
    end
    
  end

  describe "when copying an individual question to a section" do
    
    it "should copy the question element, its value set, and the question" do
      to_element = SectionElement.new(:name => "Section", :parent_element_id => @form.investigator_view_elements_container.id)
      to_element.save_and_add_to_form.should_not be_nil
      
      to_element.children.size.should eql(0)
      
      to_element.copy_from_library(@question_element_with_value_set)
      
      to_element.children.size.should eql(1)
      copied_question_element = to_element.children[0]
      copied_question_element.should_not be_nil
      
      copied_question_element.is_a?(QuestionElement).should be_true
      copied_question_element.children.size.should eql(1)
      
      copied_value_set = copied_question_element.children[0]
      copied_value_set.children.size.should eql(2)
      copied_value_set.children[0].is_a?(ValueElement).should be_true
      copied_value_set.children[0].name.should eql("Maybe")
      copied_value_set.children[1].is_a?(ValueElement).should be_true
      copied_value_set.children[1].name.should eql("Sometimes")
      
      copied_question = copied_question_element.question
      copied_question.should_not be_nil
      copied_question.question_text.should eql("How's it going?")
    end
    
    it "shouldn't copy anything if the form is invalid" do
      to_element = SectionElement.new(:name => "Section", :parent_element_id => @form.investigator_view_elements_container.id)
      to_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      to_element.copy_from_library(@question_element_with_value_set).should be_nil
      to_element.errors.should_not be_empty
    end
    
  end
  
  describe "when copying an individual value set to a question" do
    it "should copy the value set and the values" do
      question= Question.create({:question_text => "Que?", :data_type => "drop_down", :short_name => "que_q" })
      to_element = QuestionElement.new(:parent_element_id => @form.investigator_view_elements_container.id, :question => question)
      to_element.save_and_add_to_form.should_not be_nil
      to_element.children.size.should eql(0)
      
      to_element.copy_from_library(@independent_value_set)
      to_element.children.size.should eql(1)
      copied_value_set = to_element.children[0]
      copied_value_set.should_not be_nil
      
      copied_value_set.is_a?(ValueSetElement).should be_true
      copied_value_set.children.size.should eql(2)
      copied_value_set.children[0].is_a?(ValueElement).should be_true
      copied_value_set.children[0].name.should eql("Yes")
      copied_value_set.children[1].is_a?(ValueElement).should be_true
      copied_value_set.children[1].name.should eql("No")
    end
    
    it "shouldn't copy anything if the form is invalid" do
      question= Question.create({:question_text => "Que?", :data_type => "drop_down", :short_name => "que_q" })
      to_element = QuestionElement.new({:parent_element_id => @form.investigator_view_elements_container.id, :question => question})
      
      to_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)

      to_element.copy_from_library(@independent_value_set).should be_nil
      to_element.errors.should_not be_empty
    end
    
    it "shouldn't copy anything if the to-element is a question element that already has a value set" do
      question= Question.create({:question_text => "Que?", :data_type => "drop_down", :short_name => "que_q" })
      to_element = QuestionElement.new({:parent_element_id => @form.investigator_view_elements_container.id, :question => question})
      to_element.save_and_add_to_form.should_not be_nil

      to_element.copy_from_library(@independent_value_set).should_not be_nil
      to_element.errors.should be_empty

      to_element.copy_from_library(@independent_value_set)
      to_element.errors.should_not be_empty
    end
    
  end
end

describe "when filtering the library" do
  
  before(:each) do
    tree_id = 0
    @question_1 = Question.create({:question_text => "Que?", :data_type => "single_line_text", :short_name => "que_q" })
    @question_element_1 = QuestionElement.create(:tree_id => tree_id+=1, :question => @question_1)
    
    @question_2 = Question.create({:question_text => "Que pasa?", :data_type => "single_line_text", :short_name => "que_pasa_q" })
    @question_element_2 = QuestionElement.create(:tree_id => tree_id+=1, :question => @question_2)

    @question_3 = Question.create({:question_text => "Cual?", :data_type => "single_line_text", :short_name => "cual_q" })
    @question_element_3 = QuestionElement.create(:tree_id => tree_id+=1, :question => @question_3)

    
    @group_element_1 = GroupElement.create(:tree_id => tree_id+=1, :name => "Group")
    @group_element_2 = GroupElement.create(:tree_id => tree_id+=1, :name => "Not the one you're looking for")
    
    @value_set_1 = ValueSetElement.create(:tree_id => tree_id+=1, :name => "VS A")
    @value_set_2 = ValueSetElement.create(:tree_id => tree_id+=1, :name => "VS AA")
    @value_set_3 = ValueSetElement.create(:tree_id => tree_id+=1, :name => "VS B")
    
  end
  
  it "should return all root library elements if no filter paramater is provided" do
    @filtered_elements = FormElement.filter_library(:direction => :to_library, :filter_by => "")
    @filtered_elements.size.should eql(8)
    
    @filtered_elements = FormElement.filter_library(:direction => :from_library)
    @filtered_elements.size.should eql(8)
  end
  
  it "should return all group elements starting with the filter if a mathching filter and a to_library direction are provided" do
    @filtered_elements = FormElement.filter_library(:direction => :to_library, :filter_by => "Group")
    @filtered_elements.size.should eql(1)
    @filtered_elements[0].is_a?(GroupElement).should be_true
    @filtered_elements[0].name.should eql("Group")
  end
  
  it "should return no group elements if a non-mathching filter and a to_library direction are provided" do
    @filtered_elements = FormElement.filter_library(:direction => :to_library, :filter_by => "ZZZ")
    @filtered_elements.size.should eql(0)
  end
  
  it "should return all question elements starting with the filter if a matching filter and a from_library direction are provided" do
    @filtered_elements = FormElement.filter_library(:type => :question_element, :direction => :from_library, :filter_by => "Qu")
    @filtered_elements.size.should eql(2)
    @filtered_elements[0].is_a?(QuestionElement).should be_true
  end
  
  it "should return no question elements if a non-matching filter and a from_library direction are provided" do
    @filtered_elements = FormElement.filter_library(:type => :question_element, :direction => :from_library, :filter_by => "ZZZ")
    @filtered_elements.size.should eql(0)
  end
  
  it "should return all value set elements starting with the filter if a matching filter and a from_library direction are provided" do
    @filtered_elements = FormElement.filter_library(:type => :value_set_element, :direction => :from_library, :filter_by => "VS A")
    @filtered_elements.size.should eql(2)
    @filtered_elements[0].is_a?(ValueSetElement).should be_true
  end
  
  it "should return no value set elements if a non-matching filter and a from_library direction are provided" do
    @filtered_elements = FormElement.filter_library(:type => :value_set_element, :direction => :from_library, :filter_by => "ZZZ")
    @filtered_elements.size.should eql(0)
  end
  
  it "should raise a runtime exception if the direction is from_library and no type is provided" do
    begin
      @filtered_elements = FormElement.filter_library(:direction => :from_library, :filter_by => "ZZZ")
    rescue Exception => ex
      # No-op
    end
    ex.should_not be_nil
    ex.message.should eql("No type specified for a from library filter")
  end
   
end

describe "when executing an operation that requires form element structure validation" do
  before(:each) do
    @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event')
    @form.save_and_initialize_form_elements
    @element = SectionElement.new(:name => "Test")
    @element.parent_element_id = @form.investigator_view_elements_container.children[0]
  end
    
  it "should return true on save if the form element structure is valid" do
    @element.save_and_add_to_form.should_not be_nil
  end

  it "should return false on save if the form element structure is invalid" do
    invalidate_form(@form)
    @element.save_and_add_to_form.should be_nil
  end
    
  it "should return false on delete if the form element structure is invalid" do
    @element.save_and_add_to_form.should be_true
    invalidate_form(@form)
    @element.destroy_and_validate.should be_nil
  end
end
  
describe "when executing an operation that requires form element structure validation" do
    
  fixtures :forms, :form_elements, :questions
    
  it "should return false on reorder if the form element structure is invalid" do
    @form = Form.find(1)
    default_view = @form.investigator_view_elements_container.children[0]
    
    # Force a validation failure
    def default_view.validate_form_structure
      errors.add_to_base("Bad error")
      raise
    end
    
    default_view.reorder_element_children([3, 8, 12]).should be_nil
  end
    
end
