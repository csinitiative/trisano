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

describe FollowUpElement do
  before(:each) do
    @follow_up_element = FollowUpElement.new
    @follow_up_element.form_id = 1
    @follow_up_element.condition = "Yes"
  end

  it "should be valid" do
    @follow_up_element.should be_valid
  end
  
  it "should be valid for core follow ups" do
    @follow_up_element.core_data = "true"
    @follow_up_element.core_path = "some.path"
    @follow_up_element.should be_valid
  end
  
  describe "when created with 'save and add to form'" do
    
    it "should be a child of the question provided" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.save_and_add_to_form
      @follow_up_element.parent_id.should_not be_nil
      question_element = FormElement.find(question_element.id)
      question_element.children[0].id.should == @follow_up_element.id 
    end
    
    it "should receive a tree id" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.save_and_add_to_form
      @follow_up_element.tree_id.should_not be_nil
      @follow_up_element.tree_id.should eql(question_element.tree_id)
    end
    
  end
  
  describe "when created with 'save and add to form' with type-ahead support in the UI" do
    
    before(:each) do
      @external_code = ExternalCode.create(:code_name => "gender", :code_description => "Not sure", :the_code => "EH")
    end
  
    it "should use a condition_id for it's condition if one is present and it is a number" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.condition_id = @external_code.id.to_s
      @follow_up_element.save_and_add_to_form
      @follow_up_element.condition.should eql(@external_code.id.to_s)
      @follow_up_element.is_condition_code.should be_true
    end
    
    it "should find and use a external code id for it's condition if a condition_id is present, but is a string that corresponds to an external code" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.condition_id = "#{@external_code.code_description} (#{@external_code.code_name})"
      @follow_up_element.save_and_add_to_form
      @follow_up_element.condition.should eql(@external_code.id.to_s)
      @follow_up_element.is_condition_code.should be_true
    end
    
    it "should use the condition_id string for the condition if no matching code can be found" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.condition_id = "#{@external_code.code_description} (some crazy code)"
      @follow_up_element.save_and_add_to_form
      @follow_up_element.condition.should eql("#{@external_code.code_description} (some crazy code)")
      @follow_up_element.is_condition_code.should be_false
    end
    
    it "should use the condition_id string for the condition if there is content after the last paren" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.condition_id = "#{@external_code.code_description} (#{@external_code.code_name}) and more stuff"
      @follow_up_element.save_and_add_to_form
      @follow_up_element.condition.should eql("#{@external_code.code_description} (#{@external_code.code_name}) and more stuff")
      @follow_up_element.is_condition_code.should be_false
    end
    
    it "should use the condition_id string for the condition if the condition_id can't be parsed" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.condition_id = "Howdy!"
      @follow_up_element.save_and_add_to_form
      @follow_up_element.condition.should eql("Howdy!")
      @follow_up_element.is_condition_code.should be_false
    end
    
    it "should use the condition value for the saved condition, if no condition_id is supplied" do
      question_element = QuestionElement.create({:form_id => 1, :tree_id => 1})
      @follow_up_element.parent_element_id = question_element.id
      @follow_up_element.save_and_add_to_form
      @follow_up_element.condition.should eql("Yes")
      @follow_up_element.is_condition_code.should be_false
    end
    
  end
  
  describe "when processing conditional logic for core follow ups'" do
    
    fixtures :external_codes, :codes, :participations, :places, :diseases, :disease_events, :forms, :diseases_forms, :form_elements, :questions
    
    before(:each) do
      
      # Debt: Building and saving an event because the fixture-driven event is not currently valid (rake fails loading event fixtures)
      @event = MorbidityEvent.new
      @event.disease_events << disease_events(:marks_chicken_pox)
      @event.jurisdiction = participations(:marks_jurisdiction)
      @event.save(false)
      
      @no_follow_up_answer = Answer.create(:event_id => @event.id, :question_id => questions(:second_tab_core_follow_up_q).id, :text_answer => "YES!")
      
    end
    
    it "should return follow-up element with a 'show' attribute for matching core path with matching condition" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = form_elements(:second_tab_core_follow_up).core_path
      params[:response] = form_elements(:second_tab_core_follow_up).condition
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      # Debt: The magic container for core follow ups needs to go probably
      follow_ups[0][0].should eql("show")
      follow_ups[0][1].is_a?(FollowUpElement).should be_true
      
    end
    
    it "should return follow-up element with a 'hide' attribute for matching core path without a matching condition" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = form_elements(:second_tab_core_follow_up).core_path
      params[:response] = "no match"
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      # Debt: The magic container for core follow ups needs to go probably
      follow_ups[0][0].should eql("hide")
      follow_ups[0][1].is_a?(FollowUpElement).should be_true
    end
    
    it "should return no follow-up elements without a matching core path or matching condition" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = "no match"
      params[:response] = "no match"
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      follow_ups.empty?.should be_true
    end
    
    it "should delete answers to questions that no longer apply" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = form_elements(:second_tab_core_follow_up).core_path
      params[:response] = "no match"
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      begin
        deleted_existing_answer = Answer.find(@no_follow_up_answer.id)
      rescue
        # No-op
      ensure
        deleted_existing_answer.should be_nil
      end
      
    end
    
    it "should not delete answers if conditions apply" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = form_elements(:second_tab_core_follow_up).core_path
      params[:response] = form_elements(:second_tab_core_follow_up).condition
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      Answer.find(@no_follow_up_answer.id).should_not be_nil
    end
    
  end
  
end
