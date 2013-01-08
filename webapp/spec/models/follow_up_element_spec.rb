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

describe FollowUpElement do
  
  before(:each) do
    @form =  Factory.build(:form, :event_type => "morbidity_event")
    @form.save_and_initialize_form_elements
    @question_element = QuestionElement.new({
        :parent_element_id => @form.investigator_view_elements_container.id,
        :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
      })
    @question_element.save_and_add_to_form.should_not be_nil
    @follow_up_element = FollowUpElement.new
    @follow_up_element.form_id = 1
    @follow_up_element.condition = "Yes"
    @follow_up_element.parent_element_id = @question_element.id
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
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @follow_up_element.parent_id.should_not be_nil
      question_element = FormElement.find(@question_element.id)
      question_element.children[0].id.should == @follow_up_element.id 
    end
    
    it "should receive a tree id" do
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @follow_up_element.tree_id.should_not be_nil
      @follow_up_element.tree_id.should eql(@question_element.tree_id)
    end
    
    it "should fail if form validation fails" do
      invalidate_form(@form)
      @follow_up_element.save_and_add_to_form.should be_nil
      @follow_up_element.errors.should_not be_empty
    end
    
  end
  
  describe "when updated" do
    it "should succeed if form validation passes" do
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @follow_up_element.update_and_validate(:name => "Updated Name").should_not be_nil
      @follow_up_element.name.should eql("Updated Name")
      @follow_up_element.errors.should be_empty
    end

    it "should fail if form validation fails" do
      @follow_up_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      @follow_up_element.update_and_validate(:name => "Updated Name").should be_nil
      @follow_up_element.errors.should_not be_empty
    end
  end
  
  describe "when updated with as a core follow up" do
    
    it "should succeed if form validation passes" do
      external_code = ExternalCode.create(:code_name => "gender", :code_description => "Not sure", :the_code => "EH")
      @follow_up_element.save_and_add_to_form.should_not be_nil
      
      update_hash = {
        "condition_id"=>external_code.id, 
        "condition"=>"Code: #{external_code.code_description}",
        "name" => "Updated Name"
      }
    
      @follow_up_element.update_core_follow_up(update_hash).should be_true
      @follow_up_element.name.should eql("Updated Name")
      @follow_up_element.errors.should be_empty
    end

    it "should fail if form validation fails" do
      external_code = ExternalCode.create(:code_name => "gender", :code_description => "Not sure", :the_code => "EH")
      @follow_up_element.save_and_add_to_form.should_not be_nil
      
      update_hash = {
        "condition_id"=>external_code.id, 
        "condition"=>"Code: #{external_code.code_description}",
        "name" => "Updated Name"
      }
      
      invalidate_form(@form)
      @follow_up_element.update_core_follow_up(update_hash).should be_nil
      @follow_up_element.errors.should_not be_empty
    end
  end
  
  describe "when deleted" do
    it "should succeed if form validation passes" do
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @follow_up_element.destroy_and_validate.should_not be_nil
      @follow_up_element.errors.should be_empty
    end

    it "should fail if form validation fails" do
      @follow_up_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      @follow_up_element.destroy_and_validate.should be_nil
      @follow_up_element.errors.should_not be_empty
    end
  end
  
  describe "when updating a core follow-up with type-ahead support in the UI" do
    
    before(:each) do
      @question_element = QuestionElement.new({
          :parent_element_id => @form.investigator_view_elements_container.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "type_ahead_update"}
        })
      @question_element.save_and_add_to_form.should_not be_nil
      @follow_up_element = FollowUpElement.new
      @follow_up_element.form_id = 1
      @follow_up_element.condition = "Yes"
      @follow_up_element.parent_element_id = @question_element.id
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @external_code = ExternalCode.create(:code_name => "gender", :code_description => "Not sure", :the_code => "EH")
    end
    
    it "should use a condition_id for it's condition if one is present and it is a number" do
      update_hash = {
        "condition_id"=>@external_code.id, 
        "condition"=>"Code: #{@external_code.code_description}"
      }
      @follow_up_element.update_core_follow_up(update_hash).should be_true
      @follow_up_element.condition.should == @external_code.id
      @follow_up_element.is_condition_code.should be_true
    end
    
    it "should find and use a external code id for it's condition if a condition_id is present, but is a string that corresponds to an external code" do
      update_hash = {
        "condition_id"=> "Code: #{@external_code.code_description} (#{@external_code.code_name})",
        "condition"=> ""
      }
      @follow_up_element.update_core_follow_up(update_hash).should be_true
      @follow_up_element.condition.should == @external_code.id
      @follow_up_element.is_condition_code.should be_true
    end
    
    it "should use the condition string for the condition if no matching code can be found" do
      update_hash = {
        "condition_id"=> "",
        "condition"=>"Code: #{@external_code.code_description} (some crazy code)"
      }
      @follow_up_element.update_core_follow_up(update_hash).should be_true
      @follow_up_element.condition.should eql("Code: #{@external_code.code_description} (some crazy code)")
      @follow_up_element.is_condition_code.should be_false
    end
    
    it "should use the condition string for the condition if there is content after the last paren" do
      update_hash = {
        "condition_id"=> "",
        "condition"=>"#{@external_code.code_description} (#{@external_code.code_name}) and more stuff"
      }
      @follow_up_element.update_core_follow_up(update_hash).should be_true
      @follow_up_element.condition.should eql("#{@external_code.code_description} (#{@external_code.code_name}) and more stuff")
      @follow_up_element.is_condition_code.should be_false
    end
    
    it "should use the condition_id string for the condition if the condition_id can't be parsed" do
      update_hash = {
        "condition_id"=> "Howdy!",
        "condition"=> ""
      }
      @follow_up_element.update_core_follow_up(update_hash).should be_true
      @follow_up_element.condition.should eql("Howdy!")
      @follow_up_element.is_condition_code.should be_false
    end
    
    it "should use the condition value for the saved condition, if no condition_id is supplied" do
      update_hash = {
        "condition_id"=> "",
        "condition"=> "Yes"
      }
      @follow_up_element.update_core_follow_up(update_hash).should be_true
      @follow_up_element.condition.should eql("Yes")
      @follow_up_element.is_condition_code.should be_false
    end
  end
  
  describe "when getting the magic code string for an external code's id" do
    it 'should return the magic string in the correct format' do
      @external_code = ExternalCode.create(:code_name => "gender", :code_description => "Not sure", :the_code => "EH")
      magic_string = FollowUpElement.condition_string_from_code(@external_code.id)
      magic_string.should eql("Code: #{@external_code.code_description} (#{@external_code.code_name})")
    end
  end
  
  describe "when created with 'save and add to form' with type-ahead support in the UI" do
    
    before(:each) do
      @question_element = QuestionElement.new({
          :parent_element_id => @form.investigator_view_elements_container.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "more_type_ahead"}
        })
      @question_element.save_and_add_to_form.should_not be_nil
      @external_code = ExternalCode.create(:code_name => "gender", :code_description => "Not sure", :the_code => "EH")
    end
  
    it "should use a condition_id for it's condition if one is present and it is a number" do
      @follow_up_element.parent_element_id = @question_element.id
      @follow_up_element.condition_id = @external_code.id.to_s
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @follow_up_element.condition.should eql(@external_code.id.to_s)
      @follow_up_element.is_condition_code.should be_true
    end
    
    it "should find and use a external code id for it's condition if a condition_id is present, but is a string that corresponds to an external code" do
      @follow_up_element.parent_element_id = @question_element.id
      @follow_up_element.condition_id = "Code: #{@external_code.code_description} (#{@external_code.code_name})"
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @follow_up_element.condition.should eql(@external_code.id.to_s)
      @follow_up_element.is_condition_code.should be_true
    end
    
    it "should use the condition_id string for the condition if no matching code can be found" do
      @follow_up_element.parent_element_id = @question_element.id
      @follow_up_element.condition_id = "Code: #{@external_code.code_description} (some crazy code)"
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @follow_up_element.condition.should eql("Code: #{@external_code.code_description} (some crazy code)")
      @follow_up_element.is_condition_code.should be_false
    end
    
    it "should use the condition_id string for the condition if there is content after the last paren" do
      @follow_up_element.parent_element_id = @question_element.id
      @follow_up_element.condition_id = "#{@external_code.code_description} (#{@external_code.code_name}) and more stuff"
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @follow_up_element.condition.should eql("#{@external_code.code_description} (#{@external_code.code_name}) and more stuff")
      @follow_up_element.is_condition_code.should be_false
    end
    
    it "should use the condition_id string for the condition if the condition_id can't be parsed" do
      @follow_up_element.parent_element_id = @question_element.id
      @follow_up_element.condition_id = "Howdy!"
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @follow_up_element.condition.should eql("Howdy!")
      @follow_up_element.is_condition_code.should be_false
    end
    
    it "should use the condition value for the saved condition, if no condition_id is supplied" do
      @follow_up_element.parent_element_id = @question_element.id
      @follow_up_element.save_and_add_to_form.should_not be_nil
      @follow_up_element.condition.should eql("Yes")
      @follow_up_element.is_condition_code.should be_false
    end
    
  end
  
  describe "when processing conditional logic for core follow ups'" do
    
    before(:each) do
      @core_follow_up_form =  Factory.build(:form, :event_type => "morbidity_event")
      @core_follow_up_form.save_and_initialize_form_elements
      @core_follow_up_form.form_base_element

      @core_fu_condition = "donner"
      @core_fu_core_path = "morbidity_event[some_path]"

      @core_follow_up_element = FollowUpElement.new({
          :parent_element_id => @core_follow_up_form.investigator_view_elements_container.id,
          :core_path => @core_fu_core_path,
          :condition => @core_fu_condition
        })
      @core_follow_up_element.save_and_add_to_form.should_not be_nil

      @question_element = QuestionElement.new({
          :parent_element_id => @core_follow_up_element.id,
          :question_attributes => {
            :question_text => "Did you eat the fish?",
            :data_type => "single_line_text",
            :short_name => Digest::MD5::hexdigest(DateTime.now.to_s)
          }
        })
      @question_element.save_and_add_to_form.should_not be_nil
      
      @published_form = @core_follow_up_form.publish
      @published_form.form_base_element

      # Create an event and add the form to it
      @event = Factory.create(:morbidity_event)
      @event.add_forms(@published_form.id)
      @event.save!
      
      @no_follow_up_answer = Answer.create({
          :event_id => @event.id,
          :question_id => @published_form.form_element_cache.all_follow_ups_by_core_path(@core_fu_core_path)[0].children[0].question.id,
          :text_answer => "YES!"
        }
      )
    end
    
    it "should return follow-up element with a 'show' attribute for matching core path with matching condition" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = @core_fu_core_path
      params[:response] = @core_fu_condition
      
      follow_ups = FollowUpElement.process_core_condition(params)
      
      # Debt: The magic container for core follow ups needs to go probably
      follow_ups[0][0].should eql("show")
      follow_ups[0][1].is_a?(FollowUpElement).should be_true
    end

    it "should return follow-up element with a 'show' attribute for matching core path with matching condition even if case differs" do
      params = {}

      params[:event_id] = @event.id
      params[:core_path] = @core_fu_core_path
      params[:response] = "DOnNer"

      follow_ups = FollowUpElement.process_core_condition(params)

      # Debt: The magic container for core follow ups needs to go probably
      follow_ups[0][0].should eql("show")
      follow_ups[0][1].is_a?(FollowUpElement).should be_true
    end

    it "should return follow-up element with a 'show' attribute for matching core path with matching condition even there are leading and trailing spaces" do
      params = {}

      params[:event_id] = @event.id
      params[:core_path] = @core_fu_core_path
      params[:response] = "     Donner    "

      follow_ups = FollowUpElement.process_core_condition(params)

      # Debt: The magic container for core follow ups needs to go probably
      follow_ups[0][0].should eql("show")
      follow_ups[0][1].is_a?(FollowUpElement).should be_true
    end
    
    it "should return follow-up element with a 'hide' attribute for matching core path without a matching condition" do
      params = {}
      
      params[:event_id] = @event.id
      params[:core_path] = @core_fu_core_path
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
    
    it "should delete answers to questions that no longer apply if the delete flag is passed in" do
      params = {}
      params[:event_id] = @event.id
      params[:core_path] = @core_fu_core_path
      params[:response] = "no match"
      follow_ups = FollowUpElement.process_core_condition(params, { :delete_irrelevant_answers => true })
      
      begin
        deleted_existing_answer = Answer.find(@no_follow_up_answer.id)
      rescue
        # No-op
      ensure
        deleted_existing_answer.should be_nil
      end
    end

    it "should not delete answers to questions that no longer apply if the delete flag is not passed in" do
      params = {}
      params[:event_id] = @event.id
      params[:core_path] = @core_fu_core_path
      params[:response] = "no match"
      follow_ups = FollowUpElement.process_core_condition(params)

      begin
        deleted_existing_answer = Answer.find(@no_follow_up_answer.id)
      rescue
        # No-op
      ensure
        deleted_existing_answer.should_not be_nil
      end
    end
    
    it "should not delete answers if conditions apply" do
      params = {}
      params[:event_id] = @event.id
      params[:core_path] = @core_fu_core_path
      params[:response] = @core_fu_condition
      follow_ups = FollowUpElement.process_core_condition(params, { :delete_irrelevant_answers => true })
      Answer.find(@no_follow_up_answer.id).should_not be_nil
    end

  end

  describe "when comparing conditions" do

    it "should handle leading and trailing whitespace" do
      follow_up = FollowUpElement.new(:condition => "Yes")
      condition = "   yes   "
      follow_up.condition_match?(condition).should be_true
    end

    it "should handle downcasing" do
      follow_up = FollowUpElement.new(:condition => "Yes")
      condition = "yEs"
      follow_up.condition_match?(condition).should be_true
    end

  end

end
