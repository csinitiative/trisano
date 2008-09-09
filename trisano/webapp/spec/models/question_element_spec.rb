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

describe QuestionElement do
  before(:each) do
    @question_element = QuestionElement.new
  end

  it "should be valid" do
    @question_element.should be_valid
  end
  
  it "should determine if it is multi-valued" do
    
    question_element = QuestionElement.new({:question_attributes => {:data_type => "single_line_text"}})
    question_element.is_multi_valued?.should be_false
    
    question_element.update_attributes({:question_attributes => {:data_type => "multi_line_text"}})
    question_element.is_multi_valued?.should be_false
    
    question_element.update_attributes({:question_attributes => {:data_type => "drop_down"}})
    question_element.is_multi_valued?.should be_true
    
    question_element.update_attributes({:question_attributes => {:data_type => "radio_button"}})
    question_element.is_multi_valued?.should be_true
    
    question_element.update_attributes({:question_attributes => {:data_type => "check_box"}})
    question_element.is_multi_valued?.should be_true
    
    question_element.update_attributes({:question_attributes => {:data_type => "date"}})
    question_element.is_multi_valued?.should be_false
    
    question_element.update_attributes({:question_attributes => {:data_type => "phone"}})
    question_element.is_multi_valued?.should be_false
    
  end
  
  it "should determine if it is multi-valued and empty" do
    
    question_element = QuestionElement.new({:tree_id => 1})
    question = Question.new({:data_type => "drop_down", :question_text => "Was it fishy"})
    question_element.question = question
    question_element.save

    question_element.is_multi_valued?.should be_true
    question_element.is_multi_valued_and_empty?.should be_true
    
    follow_up_element = FollowUpElement.new({:tree_id => 1, :name => "Follow it", :condition => "Yes"})
    follow_up_element.save
    question_element.add_child(follow_up_element)
    
    question_element.is_multi_valued_and_empty?.should be_true
    
    value_set_element = ValueSetElement.new({:tree_id => 1, :name => "Y/N"})
    value_set_element.save
    question_element.add_child(value_set_element)

    question_element.is_multi_valued_and_empty?.should be_false
    
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should bootstrap the question" do
      form = Form.new(:name => "Test Form")
      form.save_and_initialize_form_elements
      section_element = SectionElement.new(:name => "Test")
      section_element.parent_element_id = form.investigator_view_elements_container.children[0]
      section_element.save_and_add_to_form
      
      question_element = QuestionElement.new({
          :parent_element_id => section_element.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text"}
        })
        
      saved = question_element.save_and_add_to_form
      saved.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      retrieved_question_element.question.should_not be_nil
      retrieved_question_element.question.question_text.should eql("Did you eat the fish?")
    end
    
    it "should fail if the associated question is not valid" do
      form = Form.new(:name => "Test Form")
      form.save_and_initialize_form_elements
      section_element = SectionElement.new(:name => "Test")
      section_element.parent_element_id = form.investigator_view_elements_container.children[0]
      section_element.save_and_add_to_form
      
      question_element = QuestionElement.new({
          :parent_element_id => section_element.id,
          :question_attributes => {:data_type => "single_line_text"}
        })
      
      saved = question_element.save_and_add_to_form
      saved.should be_nil
      
      begin
        retrieved_question_element = FormElement.find(question_element.id)
      rescue
        # No-op
      ensure
        retrieved_question_element.should be_nil
      end
    end
    
    it "should be receive a tree id" do
      section_element = SectionElement.create({:form_id => 1, :name => "Section 1", :tree_id => 1})
      
      question_element = QuestionElement.new({
          :parent_element_id => section_element.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text"}
        })
        
      saved = question_element.save_and_add_to_form
      question_element.tree_id.should eql(1)
    end
    
  end
  
  describe "when processing conditional logic for follow ups'" do
    
    before(:each) do
      @event_id = 1
      
      @question_element = QuestionElement.new({:tree_id => 1})
      @question = Question.new({:data_type => "drop_down", :question_text => "Was it fishy"})
      @question_element.question = @question
      @question_element.save
      
      @yes_follow_up_element = FollowUpElement.new({:tree_id => 1, :condition => "Yes"})
      @yes_follow_up_element.save
      @question_element.add_child(@yes_follow_up_element)
      
      @no_follow_up_element = FollowUpElement.new({:tree_id => 1, :condition => "No"})
      @no_follow_up_element.save
      @question_element.add_child(@no_follow_up_element)
      
      @no_follow_up_question_element = QuestionElement.new({:tree_id => 1})
      @no_follow_up_question = Question.new({:data_type => "drop_down", :question_text => "Are you sure?"})
      @no_follow_up_question_element.question = @no_follow_up_question
      @no_follow_up_question_element.save
      @no_follow_up_element.add_child(@no_follow_up_question_element)
      
      @no_follow_up_answer = Answer.create(:event_id => @event_id, :question_id => @no_follow_up_question.id, :text_answer => "YES!")
      
    end
    
    it "should return follow-up element for matching condition" do
      
      answer = Answer.create(:text_answer => "Yes", :question_id => @question.id)
      follow_up_from_processing = @question_element.process_condition(answer, @event_id)
      follow_up_from_processing.should_not be_nil
      follow_up_from_processing.id.should eql(@yes_follow_up_element.id)
    end
    
    it "should return nil for no matching condition" do
      answer = Answer.create(:text_answer => "No match", :question_id => @question.id)
      follow_up_from_processing = @question_element.process_condition(answer, @event_id)
      follow_up_from_processing.should be_nil
    end
    
    it "should delete answers to questions that no longer apply" do
      existing_answer = answer = Answer.find(@no_follow_up_answer.id)
      existing_answer.should_not be_nil
      answer = Answer.create(:text_answer => "Yes", :question_id => @question.id)
      follow_up_from_processing = @question_element.process_condition(answer, @event_id)
      
      begin
        deleted_existing_answer = Answer.find(@no_follow_up_answer.id)
      rescue
        # No-op
      ensure
        deleted_existing_answer.should be_nil
      end
      
    end
    
    it "should not delete answers if conditions apply" do
      existing_answer = answer = Answer.find(@no_follow_up_answer.id)
      existing_answer.should_not be_nil
      answer = Answer.create(:text_answer => "No", :question_id => @question.id)
      follow_up_from_processing = @question_element.process_condition(answer, @event_id)
      Answer.find(@no_follow_up_answer.id).should_not be_nil
    end
    
  end
  
end
