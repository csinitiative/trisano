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

describe FormElementCache do
  
  before(:each) do
    
    tree_id = FormElement.next_tree_id
    
    @form_base_element = FormBaseElement.create(:tree_id => tree_id, :form_id => 1, :name => "base")
    @view_element = ViewElement.create(:tree_id => tree_id, :form_id => 1, :name => "view")
    @view_element_2 = ViewElement.create(:tree_id => tree_id, :form_id => 1, :name => "view 2")
    @section_element = SectionElement.create(:tree_id => tree_id, :form_id => 1, :name => "section")
    @core_field_config = CoreFieldElement.create(:tree_id => tree_id, :form_id => 1, :name => "Something", :core_path => "event[something]")
    
    @form_base_element.add_child(@view_element)
    @form_base_element.add_child(@view_element_2)
    @form_base_element.add_child(@section_element)
    @form_base_element.add_child(@core_field_config)
    
    @question = Question.create(:question_text => "Eh?", :data_type => "single_line_text", :short_name => "eh")
    @question_element_1 = QuestionElement.create(:tree_id => tree_id, :form_id => 1, :question => @question)
    @section_element.add_child(@question_element_1)
    
    @follow_up = FollowUpElement.create(:tree_id => tree_id, :form_id => 1, :condition => "Yes", :core_path => "event[something]")
    @question_element_1.add_child(@follow_up)
    
    @fu_question = Question.create(:question_text => "fu Eh?", :data_type => "single_line_text", :short_name => "fu_eh")
    @follow_up_q1 = QuestionElement.create(:tree_id => tree_id, :form_id => 1, :question => @fu_question)
    @follow_up.add_child(@follow_up_q1)
    
    @question_2 = Question.create(:question_text => "Really?", :data_type => "single_line_text", :short_name => "really")
    @question_element_2 = QuestionElement.create(:tree_id => tree_id, :form_id => 1, :question => @question_2)
    @section_element.add_child(@question_element_2)
    
    @question_3 = Question.create(:question_text => "?", :data_type => "single_line_text", :short_name => "q")
    @question_element_3 = QuestionElement.create(:tree_id => tree_id, :form_id => 1, :question => @question_3)
    @section_element.add_child(@question_element_3)

    @question_4 = Question.create(:question_text => "Multi-Value", :data_type => "radio_button", :short_name => "multi")
    @question_element_4 = QuestionElement.create(:tree_id => tree_id, :form_id => 1, :question => @question_4)
    @value_set_4 = ValueSetElement.create(:name => "Val Set", :tree_id => tree_id)
    @question_element_4.add_child(@value_set_4)
    @value_4 = ValueElement.create(:tree_id => tree_id)
    @value_set_4.add_child(@value_4)
    @section_element.add_child(@question_element_4)
    
    @event = Event.new(:id => 1)
    @event.answers << @answer_1 = Answer.new(:event_id => 1, :question_id => @question.id, :text_answer => "What?")
    @event.answers << @answer_2 = Answer.new(:event_id => 1, :question_id => @question_2.id, :text_answer => "Yes")
    
    @form_element_cache = FormElementCache.new(@form_base_element)
    
  end
  
  it "should handle bogus constructor args" do
    lambda {FormElementCache.new(String.new)}.should raise_error(ArgumentError, "FormElementCache initialize only handles FormElements. Recieved \"\"")
  end

  it "should return children of an element" do
    children = @form_element_cache.children(@form_base_element)
    children.is_a?(Array).should be_true
    children.size.should == 4
    children[0].is_a?(ViewElement).should be_true
  end
  
  it "should return children by type" do
    view_children = @form_element_cache.children_by_type("ViewElement", @form_base_element)
    view_children.size.should == 2
    view_children[0].is_a?(ViewElement).should be_true
  end
  
  it "should reload" do
    @form_element_cache.children_count(@form_base_element).should == 4
    @form_element_cache.children(@form_base_element)[0].destroy
    @form_element_cache.children_count(@form_base_element).should == 4
    @form_element_cache.reload
    @form_element_cache.children_count(@form_base_element).should == 3
  end
  
  it "should count children of an element" do
    @form_element_cache.children_count(@form_base_element).should == 4
  end
  
  it "should count children by type" do
    @form_element_cache.children_count_by_type("ViewElement", @form_base_element).should == 2
    @form_element_cache.children_count_by_type("SectionElement", @form_base_element).should == 1
  end
  
  it "should return all children of an element" do
    @form_element_cache = FormElementCache.new(@form_base_element)
    children = @form_element_cache.all_children(@form_base_element)
    children.is_a?(Array).should be_true
    children.size.should == 12
  end
  
  it "should return all follow ups by core path" do
    children = @form_element_cache.all_follow_ups_by_core_path("event[something]", @form_base_element)
    children.is_a?(Array).should be_true
    children.size.should == 1
    children[0].is_a?(FollowUpElement).should be_true
  end
  
  it "should return all field configs by core path" do
    children = @form_element_cache.all_cached_field_configs_by_core_path("event[something]", @form_base_element)
    children.is_a?(Array).should be_true
    children.size.should == 1
    children[0].is_a?(CoreFieldElement).should be_true
  end
  
  it "should return a question from the cache" do
    question = @form_element_cache.question(@question_element_1)
    question.should_not be_nil
    question.question_text.should eql(@question_element_1.question.question_text)
    question.is_a?(Question).should be_true
  end
  
  it "should return an answer to a question in the cache" do
    answer = @form_element_cache.answer(@question_element_1, @event)
    answer.should_not be_nil
    answer.text_answer.should eql(@answer_1.text_answer)
    answer.is_a?(Answer).should be_true
    
    answer = @form_element_cache.answer(@question_element_2, @event)
    answer.should_not be_nil
    answer.text_answer.should eql(@answer_2.text_answer)
    answer.is_a?(Answer).should be_true
  end

  it "should return questions with shortnames as exportable" do
    @form_element_cache = FormElementCache.new(@form_base_element)
    @form_element_cache.exportable_questions.size.should eql(5)
  end
 
  describe "#has_children_for?" do
    it "returns true when children are found" do
      @form_element_cache.has_children_for?(@form_base_element).should be_true
    end
  end
  
  describe "#has_value_set_for?" do
    it "returns true when values are found" do
      @form_element_cache.has_value_set_for?(@question_element_4).should be_true
    end
  end
  
end
