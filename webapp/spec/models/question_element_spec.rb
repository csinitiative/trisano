# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

  def with_question_element
    form = Form.new(:name => "Test Form", :event_type => 'morbidity_event')
    form.short_name = "short_name_editable_#{rand(20000)}"
    form.save_and_initialize_form_elements
    section_element = SectionElement.new(:name => "Test")
    section_element.parent_element_id = form.investigator_view_elements_container.children[0]
    section_element.save_and_add_to_form.should_not be_nil
    question_element = QuestionElement.new({
        :parent_element_id => section_element.id,
        :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
      })
    yield question_element if block_given?
  end

  before(:each) do
    @question = Question.create({:question_text => "?", :data_type => "single_line_text", :short_name => "q"})
    @question_element = QuestionElement.new(:question => @question)
  end

  it "should be valid" do
    @question_element.should be_valid
  end

  describe 'as a new record with no parent_element_id or form_id' do
    it 'should be valid as a new question for the library' do
      @question_element.question_element_state.should == :copying_question_to_library
    end
  end

  describe 'as a new record with a parent_element_id' do
    it 'should be valid as a new question on a form' do
      @question_element.parent_element_id = 1
      @question_element.question_element_state.should == :new_question_on_form
    end
  end

  describe 'as a new record with a form_id and no parent_element_id' do
    it 'should be valid as a new question on a form, copied from the library' do
      @question_element.form_id = 1
      @question_element.question_element_state.should == :copying_question_from_library
    end
  end

  describe 'as an existing record with a parent_element_id' do
    it 'should be valid as an edit on an existing form' do
      @question_element.save!
      @question_element.form_id = 1
      @question_element.question_element_state.should == :edit_question_on_form
    end
  end
  
  it "should determine if it is multi-valued and empty" do
    
    question_element = QuestionElement.new({:tree_id => 1})
    question = Question.new({:data_type => "drop_down", :question_text => "Was it fishy", :short_name => "fishy"})
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

    before(:each) do
      @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'ques_element_short')
      @form.save_and_initialize_form_elements
      @section_element = SectionElement.new(:name => "Test")
      @section_element.parent_element_id = @form.investigator_view_elements_container.children[0]
      @section_element.save_and_add_to_form.should_not be_nil
    end
    
    it "should bootstrap the question" do
      question_element = QuestionElement.new({
          :parent_element_id => @section_element.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
        })
        
      question_element.save_and_add_to_form.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      retrieved_question_element.question.should_not be_nil
      retrieved_question_element.question.question_text.should eql("Did you eat the fish?")
    end
    
    it "should fail if the associated question is not valid" do
      question_element = QuestionElement.new({
          :parent_element_id => @section_element.id,
          :question_attributes => {:data_type => "single_line_text"}
        })
      
      question_element.save_and_add_to_form.should be_nil
      
      begin
        retrieved_question_element = FormElement.find(question_element.id)
      rescue
        # No-op
      ensure
        retrieved_question_element.should be_nil
      end
    end
    
    it "should be receive a tree id" do
      question_element = QuestionElement.new({
          :parent_element_id => @section_element.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
        })
      
      question_element.save_and_add_to_form.should_not be_nil
      question_element.tree_id.should eql(@form.form_base_element.tree_id)
    end
    
    it "should fail if form validation fails" do
      question_element = QuestionElement.new({
          :parent_element_id => @section_element.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
        }) 
      
      invalidate_form(@form)
      question_element.save_and_add_to_form.should be_nil
      question_element.errors.should_not be_empty
    end


    it 'should ensure that the short name is unique across the form' do
      question_element = QuestionElement.new({
          :parent_element_id => @section_element.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
        })

      question_element.save_and_add_to_form.should_not be_nil

      second_question_element = QuestionElement.new({
          :parent_element_id => @section_element.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
        })

      second_question_element.save_and_add_to_form.should be_nil
      second_question_element.errors.should_not be_empty
    end

  end
  
  describe "when updated or deleted" do
      
    before(:each) do
      @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'ques_element_short_2')
      @form.save_and_initialize_form_elements
      @section_element = SectionElement.new(:name => "Test")
      @section_element.parent_element_id = @form.investigator_view_elements_container.children[0]
      @section_element.save_and_add_to_form.should_not be_nil
      @question_element = QuestionElement.new({
          :parent_element_id => @section_element.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
        })

      @second_question_element = QuestionElement.new({
          :parent_element_id => @section_element.id,
          :question_attributes => {:question_text => "Are you sure?", :data_type => "single_line_text", :short_name => "sure"}
        })

      @question_element.save_and_add_to_form.should_not be_nil
      @second_question_element.save_and_add_to_form.should_not be_nil
    end
    
    it "should succeed if form validation passes on update" do
      @question_element.update_and_validate(:name => "Updated Name").should_not be_nil
      @question_element.name.should eql("Updated Name")
      @question_element.errors.should be_empty
    end

    it "should fail if form validation fails on update" do
      invalidate_form(@form)
      @question_element.update_and_validate(:name => "Updated Name").should be_nil
      @question_element.errors.should_not be_empty
    end
    
    it "should succeed if form validation passes on delete" do
      @question_element.destroy_and_validate.should_not be_nil
      @question_element.errors.should be_empty
    end

    it "should fail if form validation fails on delete" do
      invalidate_form(@form)
      @question_element.destroy_and_validate.should be_nil
      @question_element.errors.should_not be_empty
    end

    it 'should succeed if the short name is still unique after the edit' do
      @question_element.update_and_validate(:question_attributes => {
          :question_text => "Did you eat the fish?",
          :data_type => "single_line_text",
          :short_name => "fishy_still_unique"}
      ).should_not be_nil
      
      @question_element.question.short_name.should eql("fishy_still_unique")
      @question_element.errors.should be_empty
    end

    it 'should fail if the new short name is not unique to the form' do
      @question_element.update_and_validate(:question_attributes => {
          :question_text => "Did you eat the fish?",
          :data_type => "single_line_text",
          :short_name => "sure"}
      ).should be_nil

      @question_element.errors.should_not be_empty
      @question_element.errors[:base].include?("The short name entered is already in use on this form.").should be_true
    end
  end

  describe "deleted from library" do
    before do
      @question = Factory.create :question_single_line_text, :question_text => "Spec Question"
      @question_element = Factory.create :question_element, :question => @question, :tree_id => FormElement.next_tree_id
    end

    it 'should delete associated question' do
      @question_element.destroy_and_validate.should be_true
      Question.find(:all, :conditions => {:id => @question.id}).should == []
    end
  end

  describe "when a CDC question element and created with 'save and add to form'" do

    fixtures :export_names, :export_columns, :export_conversion_values

    it "should bootstrap the question with the CDC data type" do
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'ques_ele_3')
      form.save_and_initialize_form_elements

      question_element = QuestionElement.new({
          :parent_element_id => form.investigator_view_elements_container.id,
          :export_column_id => export_columns(:hep_jaundiced).id,
          :question_attributes => {
            :question_text => "Jaundiced?",
            :short_name => "j"
          }
        })

      question_element.save_and_add_to_form.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      retrieved_question_element.question.should_not be_nil
      retrieved_question_element.export_column_id.should eql(export_columns(:hep_jaundiced).id)
      retrieved_question_element.question.question_text.should eql("Jaundiced?")
      retrieved_question_element.question.data_type.should eql(export_columns(:hep_jaundiced).data_type.to_sym)
      
    end
    
    it "should bootstrap the value set for a radio button data type" do
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'ques_ele_4')
      form.save_and_initialize_form_elements
      
      question_element = QuestionElement.new({
          :parent_element_id => form.investigator_view_elements_container.id,
          :export_column_id => "2",
          :question_attributes => {
            :question_text => "Jaundiced?",
            :short_name => "j"
          }
        })
        
      question_element.save_and_add_to_form.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      cdc_value_set = retrieved_question_element.children[0]
      cdc_value_set.should_not be_nil
      cdc_value_set.name.should eql("CDC JAUNDICED")
      cdc_value_set.export_column_id.should eql(export_columns(:hep_jaundiced).id)
      
      cdc_value_elements = cdc_value_set.children
      cdc_value_elements.size.should eql(3)
      
      cdc_value_elements[0].name.should eql(export_conversion_values(:jaundiced_yes).value_from)
      cdc_value_elements[1].name.should eql(export_conversion_values(:jaundiced_no).value_from)
      cdc_value_elements[2].name.should eql(export_conversion_values(:jaundiced_unknown).value_from)
    end

    it "should bootstrap the value set with a blank lead-in value for a drop_down data type" do
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'ques_ele_5')
      form.save_and_initialize_form_elements
      
      question_element = QuestionElement.new({
          :parent_element_id => form.investigator_view_elements_container.id,
          :export_column_id => "5",
          :question_attributes => {
            :question_text => "Drop down?",
            :short_name => "dd"
          }
        })
        
      question_element.save_and_add_to_form.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      cdc_value_set = retrieved_question_element.children[0]
      cdc_value_set.should_not be_nil
      cdc_value_set.name.should eql("CDC DROPDOWN")
      cdc_value_set.export_column_id.should eql(export_columns(:hep_drop_down).id)
      
      cdc_value_elements = cdc_value_set.children
      cdc_value_elements.size.should eql(4)
      
      cdc_value_elements[0].name.should eql("")
      cdc_value_elements[1].name.should eql(export_conversion_values(:drop_down_yes).value_from)
      cdc_value_elements[2].name.should eql(export_conversion_values(:drop_down_no).value_from)
      cdc_value_elements[3].name.should eql(export_conversion_values(:drop_down_unknown).value_from)
    end
    
    it "should bootstrap the value set for a check_box data type" do
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'ques_ele_6')
      form.save_and_initialize_form_elements
      
      question_element = QuestionElement.new({
          :parent_element_id => form.investigator_view_elements_container.id,
          :export_column_id => "6",
          :question_attributes => {
            :question_text => "Check box?",
            :short_name => "cb"
          }
        })
        
      question_element.save_and_add_to_form.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      cdc_value_set = retrieved_question_element.children[0]
      cdc_value_set.should_not be_nil
      cdc_value_set.name.should eql("CDC CHECKBOX")
      cdc_value_set.export_column_id.should eql(export_columns(:hep_check_box).id)
      
      cdc_value_elements = cdc_value_set.children
      cdc_value_elements.size.should eql(3)
      
      cdc_value_elements[0].name.should eql(export_conversion_values(:check_box_yes).value_from)
      cdc_value_elements[1].name.should eql(export_conversion_values(:check_box_no).value_from)
      cdc_value_elements[2].name.should eql(export_conversion_values(:check_box_unknown).value_from)
    end

    it "should not bootstrap a value set for date data types" do
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'ques_ele_7')
      form.save_and_initialize_form_elements
      
      question_element = QuestionElement.new({
          :parent_element_id => form.investigator_view_elements_container.id,
          :export_column_id => "3",
          :question_attributes => {
            :question_text => "Date diagnosed",
            :short_name => "dd"
          }
        })
        
      question_element.save_and_add_to_form.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      retrieved_question_element.question.question_text.should eql("Date diagnosed")
      retrieved_question_element.children.size.should eql(0)
      retrieved_question_element.question.data_type.should eql(export_columns(:hep_datedx).data_type.to_sym)
      
    end

    it "should not bootstrap a value set for single_line_text types" do
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'ques_ele_8')
      form.save_and_initialize_form_elements
      
      question_element = QuestionElement.new({
          :parent_element_id => form.investigator_view_elements_container.id,
          :export_column_id => "4",
          :question_attributes => {
            :question_text => "Vaccine year",
            :short_name => "vc"
          }
        })
        
      question_element.save_and_add_to_form.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      retrieved_question_element.question.question_text.should eql("Vaccine year")
      retrieved_question_element.children.size.should eql(0)
      retrieved_question_element.question.data_type.should eql(export_columns(:hep_vaccineyea).data_type.to_sym)
    end

    it "should set the size on questions for single_line_text types" do
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'que_ele_9')
      form.save_and_initialize_form_elements

      question_element = QuestionElement.new({
          :parent_element_id => form.investigator_view_elements_container.id,
          :export_column_id => "4",
          :question_attributes => {
            :question_text => "Vaccine year",
            :short_name => "vc"
          }
        })

      question_element.save_and_add_to_form.should_not be_nil
      retrieved_question_element = FormElement.find(question_element.id)
      retrieved_question_element.question.size.should eql(export_columns(:hep_vaccineyea).length_to_output)
    end
    
    it "should not bootstrap a value set for multi_line_text types" do
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'ques_ele_10')
      form.save_and_initialize_form_elements
      
      question_element = QuestionElement.new({
          :parent_element_id => form.investigator_view_elements_container.id,
          :export_column_id => "8",
          :question_attributes => {
            :question_text => "Multi-line?",
            :short_name => "ml"
          }
        })
        
      question_element.save_and_add_to_form.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      retrieved_question_element.question.question_text.should eql("Multi-line?")
      retrieved_question_element.children.size.should eql(0)
      retrieved_question_element.question.data_type.should eql(export_columns(:hep_multi_line).data_type.to_sym)
    end
    
    it "should not bootstrap a value set for phone types" do
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'que_ele_11')
      form.save_and_initialize_form_elements
      
      question_element = QuestionElement.new({
          :parent_element_id => form.investigator_view_elements_container.id,
          :export_column_id => "7",
          :question_attributes => {
            :question_text => "Phone?",
            :short_name => "ph"
          }
        })
        
      question_element.save_and_add_to_form.should_not be_nil
      
      retrieved_question_element = FormElement.find(question_element.id)
      retrieved_question_element.question.question_text.should eql("Phone?")
      retrieved_question_element.children.size.should eql(0)
      retrieved_question_element.question.data_type.should eql(export_columns(:hep_phone).data_type.to_sym)
    end
    
  end
  
  describe "when processing conditional logic for follow ups'" do
    
    before(:each) do
      @event_id = 1
      
      @question_element = QuestionElement.new({:tree_id => 1})
      @question = Question.new({:data_type => "drop_down", :question_text => "Was it fishy", :short_name => "fishy"})
      @question_element.question = @question
      @question_element.save
      
      @yes_follow_up_element = FollowUpElement.new({:tree_id => 1, :condition => "Yes"})
      @yes_follow_up_element.save
      @question_element.add_child(@yes_follow_up_element)
      
      @no_follow_up_element = FollowUpElement.new({:tree_id => 1, :condition => "No"})
      @no_follow_up_element.save
      @question_element.add_child(@no_follow_up_element)
      
      @no_follow_up_question_element = QuestionElement.new({:tree_id => 1})
      @no_follow_up_question = Question.new({:data_type => "drop_down", :question_text => "Are you sure?", :short_name => "sure"})
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

    it "should return follow-up element for matching condition even if the case is not identical" do
      answer = Answer.create(:text_answer => "yEs", :question_id => @question.id)
      follow_up_from_processing = @question_element.process_condition(answer, @event_id)
      follow_up_from_processing.should_not be_nil
      follow_up_from_processing.id.should eql(@yes_follow_up_element.id)
    end

    it "should return follow-up element for matching condition even if there is leading and trailing space on the answer" do
      answer = Answer.create(:text_answer => "    Yes     ", :question_id => @question.id)
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

  describe "when checking question short-name state on a question element not on a form" do

    before(:each) do
      @question_element = QuestionElement.create({
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
        })
    end
    
    it 'should indicate editable' do
      @question_element.short_name_editable?.should be_true
    end
    
  end

  describe "when checking question short-name state on a question element on a form" do
    
    it 'should indicate editable if the form with the question has not been published' do
      with_question_element do |question_element|
        question_element.save_and_add_to_form.should_not be_nil
        question_element.short_name_editable?.should be_true
      end
    end

    it 'should indicate not editable if the form with the question has been published' do
      with_question_element do |question_element|
        question_element.save_and_add_to_form.should_not be_nil
        sleep 1 # Sleep to get the publish time far enough from the question creation time to allow for time comparison precision to work
        question_element.form.publish
        question_element.form.reload
        question_element.short_name_editable?.should be_false
      end
    end

    it 'should indicate editable for a question added to a form after the form was published' do
      with_question_element do |question_element|
        question_element.save_and_add_to_form.should_not be_nil
        question_element.form.publish
        sleep 1 # Sleep to get the publish time far enough from the question creation time to allow for time comparison precision to work
        second_question_element = QuestionElement.new({
            :parent_element_id => question_element.parent.id,
            :question_attributes => {:question_text => "You sure about that?", :data_type => "single_line_text", :short_name => "sure"}
          })
        second_question_element.save_and_add_to_form
        question_element.form.reload
        second_question_element.short_name_editable?.should be_true
      end
    end

  end
    
  
end
