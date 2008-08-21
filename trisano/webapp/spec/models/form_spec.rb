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
require 'ostruct'

describe Form do
  before(:each) do
    @form = Form.new
  end

  it "should be valid" do
    @form.should be_valid
  end
  
  describe "when created with save_and_initialize_form_elements" do
    
    # fixtures :forms, :form_elements, :questions
    
    it "should bootstrap the form element hierarchy" do
      @form.save_and_initialize_form_elements
      form_base_element = @form.form_base_element
      form_base_element.should_not be_nil
      
      investigator_view_element_container = form_base_element.children[0]
      investigator_view_element_container.should_not be_nil
      investigator_view_element_container.type.should == "InvestigatorViewElementContainer"
      
      core_view_element_container = form_base_element.children[1]
      core_view_element_container.should_not be_nil
      core_view_element_container.type.should == "CoreViewElementContainer"
      
      core_field_element_container = form_base_element.children[2]
      core_field_element_container.should_not be_nil
      core_field_element_container.type.should == "CoreFieldElementContainer"
      
      default_view_element = investigator_view_element_container.children[0]
      default_view_element.should_not be_nil
      default_view_element.name.should == "Default View"
    end

    it "should have a template's properties" do
      @form.save_and_initialize_form_elements
      @form.is_template.should be_true
      @form.template_id.should be_nil
      @form.version.should be_nil
      @form.status.should eql("Not Published")
    end

    describe "and associating a form with one or more diseases" do

      fixtures :diseases

      it "should allow a form to be associated with one disease" do
        form = Form.new( :disease_ids => [ diseases(:chicken_pox).id ] )
        lambda { form.save_and_initialize_form_elements }.should_not raise_error()
        form = Form.find(form.id)
        form.diseases.length.should == 1
        form.diseases[0].id.should == diseases(:chicken_pox).id
      end

      it "should allow a form to be associated with multiple diseases" do
        form = Form.new( :disease_ids => [ diseases(:chicken_pox).id, diseases(:tuberculosis).id ] )
        lambda { form.save_and_initialize_form_elements }.should_not raise_error()
        form = Form.find(form.id)
        form.diseases.length.should == 2
        form.diseases[0].id.should == diseases(:chicken_pox).id
        form.diseases[1].id.should == diseases(:tuberculosis).id
      end

    end
  end

  describe "when retrieving published forms" do

    fixtures :forms, :diseases_forms

    it "should return only forms for the specified disease and jurisdiction" do
      form = Form.get_published_investigation_forms(3, 1)
      form.length.should == 4
      form.each do |d| 
        d.disease_ids.should == [3]
        d.jurisdiction_id.should == 1 unless d.jurisdiction_id.nil?
      end

      form = Form.get_published_investigation_forms(4, 2)
      form.length.should == 1
      form.each do |d|  
        d.disease_ids.should == [4]
        d.jurisdiction_id.should == 2 unless d.jurisdiction_id.nil?
      end
    end

    it "should return forms applicable to all jurisdictions even if given jurisdiction is not found" do
      form = Form.get_published_investigation_forms(3, 99)
      form.length.should == 3
      form.each { |d| d.jurisdiction_id.should == nil }
    end

    it "should return no form if the disease is not found" do
      Form.get_published_investigation_forms(99, 1).length.should == 0
    end

    describe "and a form is associated with multiple disease" do
      it "should return only forms for the specified disease and jurisdiction" do
        form = Form.get_published_investigation_forms(1, 2)
        form.length.should == 2
        form.each do |d| 
          d.disease_ids.should == [1]
          d.jurisdiction_id.should == 2 unless d.jurisdiction_id.nil?
        end

        form = Form.get_published_investigation_forms(2, 2)
        form.length.should == 1
        form.each do |d| 
          d.disease_ids.should == [2]
          d.jurisdiction_id.should == 2 unless d.jurisdiction_id.nil?
        end
      end
    end
  end

  describe "when using container convenience methods" do
    
    fixtures :forms, :form_elements, :questions

    it "should return the investigator view element container" do
      @form.save_and_initialize_form_elements
      @form.investigator_view_elements_container.id.should eql(@form.form_base_element.children[0].id)
    end
    
    it "should return the core view element container" do
      @form.save_and_initialize_form_elements
      @form.core_view_elements_container.id.should eql(@form.form_base_element.children[1].id)
    end

    it "should return the core fields element container" do
      @form.save_and_initialize_form_elements
      @form.core_field_elements_container.id.should eql(@form.form_base_element.children[2].id)
    end
    
  end

  describe "when checking for renderable investigation view elements" do
    
    def prepare_form
      form = Form.new
      section = mock(SectionElement)
      section.stub!(:name).and_return('Something Else')
      defaultTab = mock(ViewElement)
      defaultTab.stub!(:name).and_return('Default View')                  
      result = yield defaultTab, section if block_given?
      container = OpenStruct.new(:all_children => result)
      form.should_receive(:investigator_view_elements_container).and_return(container)      
      return form
    end

    it "should not assume 'Default View' alone is a valid investigator view element" do
      form = prepare_form {|defaultTab, section| [defaultTab]}
      form.has_investigator_view_elements?.should_not be_true
    end

    it "should not consider an empty container interesting" do
      form = prepare_form {[]}
      form.has_investigator_view_elements?.should_not be_true
    end

    it "should be interested in container if it contains more then a 'Default View'" do
      form = prepare_form {|defaultTab, section| [defaultTab, section]}
      form.has_investigator_view_elements?.should be_true

      form = prepare_form {|defaultTab, section| [section, defaultTab]}
      form.has_investigator_view_elements?.should be_true
    end    

    it "should be interested in container if it contains more then one view" do
      form = prepare_form {|defaultTab, section| [defaultTab, defaultTab]}
      form.has_investigator_view_elements?.should be_true
    end
                                
  end
  
  describe "when trying to call publish on a published instance" do
    
    fixtures :forms, :form_elements, :questions
    
    it "should fail" do
      form_to_publish = Form.find(1)
      error_message = ""
      
      begin
        published_form = form_to_publish.publish!
        published_form.publish!
      rescue RuntimeError => error
        error_message = error.message
      end
      error_message.should eql("Cannot publish an already published version")
    end
  end
  
  describe "when first published" do
    
    fixtures :forms, :form_elements, :questions, :diseases_forms, :diseases
    
    before(:each) do
      @form_to_publish = Form.find(1)
      @published_form = @form_to_publish.publish!
    end

    it "should give itself published status" do
      @form_to_publish.status.should eql("Published")
    end
    
    it "should give the base form element a tree id" do
      @published_form.form_base_element.tree_id.should_not be_nil
    end
    
    it "should make a copy of itself and give the copy published version properties" do
      @published_form.should_not be_nil
      @published_form.version.should eql(1)
      @published_form.is_template.should be_false
      @published_form.template_id.should eql(@form_to_publish.id)
      @published_form.status.should eql("Live")
    end
    
    it "should make a copy of the entire form element tree" do
      @published_form.form_base_element.should_not be_nil
      published_form_base = @published_form.form_base_element
      published_form_base.children_count.should eql(3)
      
      investigator_view_element_container = published_form_base.children[0]
      investigator_view_element_container.form_id.should eql(@published_form.id)
      investigator_view_element_container.class.name.should eql("InvestigatorViewElementContainer")
      investigator_view_element_container.children_count.should eql(2)
      
      core_view_element_container = published_form_base.children[1]
      core_view_element_container.form_id.should eql(@published_form.id)
      core_view_element_container.class.name.should eql("CoreViewElementContainer")
      core_view_element_container.children_count.should eql(0)
      
      default_view = investigator_view_element_container.children[0]
      default_view.form_id.should eql(@published_form.id)
      default_view.children_count.should eql(3)
      
      demo_section = default_view.children[0]
      demo_section.class.name.should eql("SectionElement")
      demo_section.form_id.should eql(@published_form.id)
      demo_section.name.should eql(form_elements(:demographic_section).name)
      
      demo_group = demo_section.children[0]
      demo_group.class.name.should eql("GroupElement")
      demo_group.form_id.should eql(@published_form.id)
      demo_group.name.should eql(form_elements(:demographic_group).name)
      
      demo_q1 = demo_group.children[0]
      demo_q1.class.name.should eql("QuestionElement")
      demo_q1.form_id.should eql(@published_form.id)
      demo_q1.name.should be_nil
      
      demo_q2 = demo_group.children[1]
      demo_q2.class.name.should eql("QuestionElement")
      demo_q2.form_id.should eql(@published_form.id)
      demo_q2.name.should be_nil
      
      demo_q3 = demo_group.children[2]
      demo_q3.class.name.should eql("QuestionElement")
      demo_q3.form_id.should eql(@published_form.id)
      demo_q3.name.should be_nil
      
      lab_section = default_view.children[1]
      lab_section.class.name.should eql("SectionElement")
      lab_section.form_id.should eql(@published_form.id)
      lab_section.name.should eql(form_elements(:lab_section).name)
      
      lab_q1 = lab_section.children[0]
      lab_q1.class.name.should eql("QuestionElement")
      lab_q1.form_id.should eql(@published_form.id)
      lab_q1.name.should be_nil
      
      lab_q2 = lab_section.children[1]
      lab_q2.class.name.should eql("QuestionElement")
      lab_q2.form_id.should eql(@published_form.id)
      lab_q2.name.should be_nil
      
      lab_q3 = lab_section.children[2]
      lab_q3.class.name.should eql("QuestionElement")
      lab_q3.form_id.should eql(@published_form.id)
      lab_q3.name.should be_nil
      
      food_section = default_view.children[2]
      food_section.class.name.should eql("SectionElement")
      food_section.form_id.should eql(@published_form.id)
      food_section.name.should eql(form_elements(:food_section).name)
      
      food_group = food_section.children[0]
      food_group.class.name.should eql("GroupElement")
      food_group.form_id.should eql(@published_form.id)
      food_group.name.should eql(form_elements(:standard_food_group).name)
      
      food_q1 = food_group.children[0]
      food_q1.class.name.should eql("QuestionElement")
      food_q1.form_id.should eql(@published_form.id)
      food_q1.name.should be_nil
      
      food_q2 = food_group.children[1]
      food_q2.class.name.should eql("QuestionElement")
      food_q2.form_id.should eql(@published_form.id)
      food_q2.name.should be_nil
      
      food_q3 = food_section.children[1]
      food_q3.class.name.should eql("QuestionElement")
      food_q3.form_id.should eql(@published_form.id)
      food_q3.name.should be_nil
      
      second_tab = investigator_view_element_container.children[1]
      second_tab.form_id.should eql(@published_form.id)
      second_tab.children_count.should eql(2)
      
      second_tab_q = second_tab.children[0]
      second_tab_q.class.name.should eql("QuestionElement")
      second_tab_q.form_id.should eql(@published_form.id)
      second_tab_q.name.should be_nil
      second_tab_q.question.should_not be_nil
      
      second_tab_follow_up = second_tab_q.children[0]
      second_tab_follow_up.class.name.should eql("FollowUpElement")
      second_tab_follow_up.form_id.should eql(@published_form.id)
      second_tab_follow_up.condition.should eql(form_elements(:second_tab_follow_up_container).condition)
      
      second_tab_follow_up_q = second_tab_follow_up.children[0]
      second_tab_follow_up_q.class.name.should eql("QuestionElement")
      second_tab_follow_up_q.form_id.should eql(@published_form.id)
      second_tab_follow_up_q.name.should be_nil
      second_tab_follow_up_q.question.should_not be_nil
      
      second_tab_core_follow_up = second_tab.children[1]
      second_tab_core_follow_up.class.name.should eql("FollowUpElement")
      second_tab_core_follow_up.form_id.should eql(@published_form.id)
      second_tab_core_follow_up.condition.should eql(form_elements(:second_tab_core_follow_up).condition)
      second_tab_core_follow_up.core_path.should eql(form_elements(:second_tab_core_follow_up).core_path)
      
      second_tab_core_follow_up_q = second_tab_core_follow_up.children[0]
      second_tab_core_follow_up_q.class.name.should eql("QuestionElement")
      second_tab_core_follow_up_q.form_id.should eql(@published_form.id)
      second_tab_core_follow_up_q.name.should be_nil
      second_tab_core_follow_up_q.question.should_not be_nil
      
    end
    
    it "should make a copy of the question instances" do
      default_view = @published_form.investigator_view_elements_container.children[0]
      demo_section = default_view.children[0]
      demo_group = demo_section.children[0]
      
      demo_q1 = demo_group.children[0]
      
      demo_q1.question.should_not be_nil
      demo_q1.question.question_text.should eql(questions(:demo_q1).question_text)
      demo_q1.question.short_name.should eql(questions(:demo_q1).short_name)
    end
    
    it "should not make a copy of the inactive questions" do
      default_view = @form_to_publish.investigator_view_elements_container.children[0]
      demo_section = default_view.children[0]
      demo_group = demo_section.children[0]
      demo_q1 = demo_group.children[0]
      
      demo_q1.question.question_text.should eql(questions(:demo_q1).question_text)
      demo_q1.is_active = false
      demo_q1.save
      
      published_form = @form_to_publish.publish!
      
      default_view = published_form.investigator_view_elements_container.children[0]
      demo_section = default_view.children[0]
      demo_group = demo_section.children[0]
      demo_q1 = demo_group.children[0]
      
      demo_q1.question.should_not be_nil
      demo_q1.question.question_text.should_not eql(questions(:demo_q1).question_text)
      demo_q1.question.question_text.should eql(questions(:demo_q2).question_text)
    end
    
    it "should associate the published form with the same diseases as the original form." do
      # One disease
      @published_form.disease_ids.length.should == @form_to_publish.disease_ids.length
      @published_form.disease_ids.sort.should == @form_to_publish.disease_ids.sort

      # Two diseases
      form_to_publish = forms(:checken_pox_TB_form_for_LHD_2)
      published_form = form_to_publish.publish!
      published_form.disease_ids.length.should == form_to_publish.disease_ids.length
      published_form.disease_ids.sort.should == form_to_publish.disease_ids.sort
    end
  end
  
  describe "when published a second time" do
    
    fixtures :forms, :form_elements, :questions
    
    it "should give the second version live status and first version archived status" do
      form_to_publish = Form.find(1)
      first_version = form_to_publish.publish!
      first_version.status.should eql("Live")
      second_version = form_to_publish.publish!
      second_version.status.should eql("Live")
      first_version.reload
      first_version.status.should eql("Archived")
    end
    
  end
  
end
