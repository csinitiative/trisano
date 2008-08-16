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
    @form_element = QuestionElement.create(:tree_id => 1, :form_id => 1)
    @question = Question.create({:question_text => "Que?", :data_type => "single_line_text"})
    @form_element.question = @question
  end

  it "should destroy associated question on destroying with dependencies" do
    
    form_element_id = @form_element.id
    question_id = @question.id
    
    FormElement.exists?(form_element_id).should be_true
    Question.exists?(question_id).should be_true
    
    @form_element.destroy_with_dependencies
    
    FormElement.exists?(form_element_id).should be_false
    Question.exists?(question_id).should be_false
    
  end
end

describe "Quesiton FormElement when filtering the library" do
  
  before(:each) do
    @question_element_1 = QuestionElement.create(:tree_id => 1)
    @question_1 = Question.create({:question_text => "Que?", :data_type => "single_line_text", :short_name => "que_q" })
    @question_element_1.question = @question_1
    
    @question_element_2 = QuestionElement.create(:tree_id => 2)
    @question_2 = Question.create({:question_text => "Que pasa?", :data_type => "single_line_text", :short_name => "que_pasa_q" })
    @question_element_2.question = @question_2
    
    @question_element_3 = QuestionElement.create(:tree_id => 3)
    @question_3 = Question.create({:question_text => "Cual?", :data_type => "single_line_text", :short_name => "cual_q" })
    @question_element_3.question = @question_3
    
    @group_element_1 = GroupElement.create(:tree_id => 4, :name => "Group")
    @group_element_2 = GroupElement.create(:tree_id => 5, :name => "Not the one you're looking for")
    
  end
  
  it "should return all root library elements if no filter paramater is provided" do
    @filtered_elements = FormElement.filter_library(:to_library, "")
    @filtered_elements.size.should eql(5)
    
    @filtered_elements = FormElement.filter_library(:from_library)
    @filtered_elements.size.should eql(5)
  end
  
  it "should return all group elements starting with the filter if a mathching filter and a to_library direction are provided" do
    @filtered_elements = FormElement.filter_library(:to_library, "Group")
    @filtered_elements.size.should eql(1)
    @filtered_elements[0].is_a?(GroupElement).should be_true
    @filtered_elements[0].name.should eql("Group")
  end
  
  it "should return no group elements if a non-mathching filter and a to_library direction are provided" do
    @filtered_elements = FormElement.filter_library(:to_library, "ZZZ")
    @filtered_elements.size.should eql(0)
  end
  
  it "should return all question elements starting with the filter if a matching filter and a from_library direction are provided" do
    @filtered_elements = FormElement.filter_library(:from_library, "Qu")
    @filtered_elements.size.should eql(2)
    @filtered_elements[0].is_a?(QuestionElement).should be_true
  end
  
    it "should return no question elements if a non-matching filter and a from_library direction are provided" do
    @filtered_elements = FormElement.filter_library(:from_library, "ZZZ")
    @filtered_elements.size.should eql(0)
  end
   
end
