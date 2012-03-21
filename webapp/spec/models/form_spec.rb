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
require 'ostruct'
include ActionController::TestProcess

describe Form do

  def with_form(form_hash=@form_hash)
    form = Form.new(form_hash)
    form.save_and_initialize_form_elements.should_not be_nil
    question_element = QuestionElement.new(
      {
        :parent_element_id => form.form_base_element.children[0].id,
        :question_attributes => { :question_text => "What gives?",:data_type => "single_line_text", :short_name => "gives" }
      }
    )
    question_element.save_and_add_to_form.should_not be_nil
    yield form if block_given?
  end


  before(:each) do
    @form = Form.new
    @form.name = "Test Form"
    @form.event_type = 'morbidity_event'
    @form.short_name = 'test_form'
  end

  it "should be valid" do
    @form.should be_valid
  end


  describe 'short_name' do
    it 'should exist' do
      @form.short_name = nil
      @form.save_and_initialize_form_elements.should_not be_true
      @form.errors.on(:short_name).should == "can't be blank"
    end

    it 'should be unique across active templates' do
      @form.save_and_initialize_form_elements

      form2 = Form.new
      form2.name = "Test Form"
      form2.short_name = "test_form"
      form2.event_type = 'morbidity_event'
      form2.save_and_initialize_form_elements.should be_nil
      form2.errors.on(:short_name).should == "is already being used by another active form."
    end

    it 'should replace spaces w/ underscores' do
      Form.transaction do
        @form.short_name = 'some name'
        @form.save_and_initialize_form_elements.should_not be_nil
        @form.short_name.should eql('some_name')
      end
    end

    it 'should be editable' do
      @form.should be_short_name_editable
      @form.save_and_initialize_form_elements.should_not be_nil
      @form.should be_short_name_editable
    end

    it 'should not be editable once a form is published' do
      @form.save_and_initialize_form_elements.should_not be_nil
      @form.publish.should_not be_nil
      @form.should_not be_short_name_editable
      @form.short_name = 'changed'
      @form.save_and_initialize_form_elements
      @form.errors.on(:short_name).should == "can't be changed once the form has been published"
    end

    it 'should be copied to the published versions of the form' do
      @form.save_and_initialize_form_elements.should_not be_nil
      published_form = @form.publish
      published_form.short_name.should == @form.short_name
    end

  end

  describe "when created with save_and_initialize_form_elements" do

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

    it 'should not be published' do
      @form.save_and_initialize_form_elements
    end

    describe "and associating a form with one or more diseases" do

      fixtures :diseases

      it "should allow a form to be associated with one disease" do
        form = Form.new( :disease_ids => [ diseases(:chicken_pox).id ], :name => "Test Form", :event_type => 'morbidity_event', :short_name => Digest::MD5::hexdigest(DateTime.now.to_s))
        lambda { form.save_and_initialize_form_elements }.should_not raise_error()
        form = Form.find(form.id)
        form.diseases.length.should == 1
        form.diseases[0].id.should == diseases(:chicken_pox).id
      end

      it "should allow a form to be associated with multiple diseases" do
        form = Form.new( :disease_ids => [ diseases(:chicken_pox).id, diseases(:tuberculosis).id ], :name => "Test Form", :event_type => 'morbidity_event', :short_name => Digest::MD5::hexdigest(DateTime.now.to_s))
        lambda { form.save_and_initialize_form_elements }.should_not raise_error()
        form = Form.find(form.id)
        form.diseases.length.should == 2
        form.diseases[0].id.should == diseases(:chicken_pox).id
        form.diseases[1].id.should == diseases(:tuberculosis).id
      end

    end

    it 'should fail when the form is not valid' do
      @form.name = ""
      @form.save_and_initialize_form_elements.should be_nil
    end

    it 'should fail when the form elements cannot be initialized' do
      form = Form.new
      form.name = "Test Form"
      form.event_type = 'morbidity_event'
      def form.initialize_form_elements
        errors.add_to_base("An error occurred initializing form elements").
          raise
      end
      form.save_and_initialize_form_elements.should be_nil
      form.errors.size.should == 1
    end

    it 'should fail when the form element structure is invalid' do
      form = Form.new
      form.name = "Test Form"
      form.event_type = 'morbidity_event'
      form.short_name = Digest::MD5::hexdigest(DateTime.now.to_s)
      def form.structural_errors
        return ["Bad error"]
      end
      form.save_and_initialize_form_elements.should be_nil
      form.errors.size.should == 1
      form.errors["base"].should == "Bad error"
    end
  end

  describe "when retrieving published forms" do

    before(:all) do
      @disease = Factory.create(:disease)
      @jurisdiction = Factory.create(:jurisdiction)

      @non_matching_disease = Factory.create(:disease)
      @non_matching_jurisdiction = Factory.create(:place_entity)

      @second_disease_for_form = Factory.create(:disease)

      @morb_form_matching_jurisdiction = Factory.build(:form, :event_type => "morbidity_event")
      @morb_form_matching_jurisdiction.diseases << @disease
      @morb_form_matching_jurisdiction.diseases << @second_disease_for_form
      @morb_form_matching_jurisdiction.jurisdiction = @jurisdiction.place_entity
      @morb_form_matching_jurisdiction.save_and_initialize_form_elements
      @published_morb_form_matching_jurisdiction = @morb_form_matching_jurisdiction.publish

      @morb_form_non_matching_disease = Factory.build(:form, :event_type => "morbidity_event")
      @morb_form_non_matching_disease.diseases << @non_matching_disease
      @morb_form_non_matching_disease.jurisdiction = @jurisdiction.place_entity
      @morb_form_non_matching_disease.save_and_initialize_form_elements
      @published_morb_form_non_matching_disease = @morb_form_non_matching_disease.publish

      @morb_form_non_matching_jurisdiction = Factory.build(:form, :event_type => "morbidity_event")
      @morb_form_non_matching_jurisdiction.diseases << @disease
      @morb_form_non_matching_jurisdiction.jurisdiction = @non_matching_jurisdiction
      @morb_form_non_matching_jurisdiction.save_and_initialize_form_elements
      @published_morb_form_non_matching_jurisdiction = @morb_form_non_matching_jurisdiction.publish

      @morb_form_all_jurisdictions = Factory.build(:form, :event_type => "morbidity_event")
      @morb_form_all_jurisdictions.diseases << @disease
      @morb_form_all_jurisdictions.save_and_initialize_form_elements
      @published_morb_form_all_jurisdictions = @morb_form_all_jurisdictions.publish
    end

    it "should return only forms for the specified disease and jurisdiction" do
      forms = Form.get_published_investigation_forms(@disease.id, @jurisdiction.id, :morbidity_event)
      forms.length.should == 1
      forms.each do |form|
        form.disease_ids.should == [@disease.id]
        form.jurisdiction_id.should == @jurisdiction.id unless form.jurisdiction_id.nil?
      end
    end

    it "should return forms applicable to all jurisdictions even if given jurisdiction is not found" do
      form = Form.get_published_investigation_forms(@disease.id, 99999, :morbidity_event)
      form.length.should == 1
      form.each { |d| d.jurisdiction_id.should == nil }
    end

    it "should return no form if the disease is not found" do
      Form.get_published_investigation_forms(99999, @jurisdiction.id, :morbidity_event).length.should == 0
    end

    it "should return no form if the event type has no forms" do
      form = Form.get_published_investigation_forms(@disease.id, @jurisdiction.id, :contact_event).length.should == 0
    end

    describe "and a form is associated with multiple disease" do
      it "should return only forms for the specified disease and jurisdiction" do
        form = Form.get_published_investigation_forms(@second_disease_for_form.id, @jurisdiction.id, :morbidity_event)
        form.length.should == 1
        form.each do |d|
          d.disease_ids.should == [@second_disease_for_form.id]
          d.jurisdiction_id.should == @jurisdiction.id unless d.jurisdiction_id.nil?
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

  describe "when using form-structure convenience methods" do

    fixtures :forms, :form_elements, :questions

    it "should return the exportable questions" do
      form = Form.find(1)
      form.exportable_questions.size.should eql(13)
    end

  end

  describe "when checking for renderable investigation view elements" do

    def prepare_form
      form = Form.new(:name => "Test Form", :event_type => 'morbidity_event')
      section = Factory.build(:section_element)
      section.stubs(:name).returns('Something Else')
      section.stubs(:read_attribute).with(:type).returns('SectionElement')
      default_tab = Factory.build(:view_element)
      default_tab.stubs(:name).returns('Default View')
      default_tab.stubs(:read_attribute).with(:type).returns('ViewElement')
      result = yield(default_tab, section) if block_given?
      container = OpenStruct.new(:all_children => result)
      form.expects(:investigator_view_elements_container).returns(container)
      return form
    end

    it "should not assume 'Default View' alone is a valid investigator view element" do
      form = prepare_form {|default_tab, section| [default_tab]}
      form.has_investigator_view_elements?.should_not be_true
    end

    it "should not consider an empty container interesting" do
      form = prepare_form {[]}
      form.has_investigator_view_elements?.should_not be_true
    end

    it "should be interested in container if it contains more then a 'Default View'" do
      form = prepare_form {|default_tab, section| [default_tab, section]}
      form.has_investigator_view_elements?.should be_true

      form = prepare_form {|default_tab, section| [section, default_tab]}
      form.has_investigator_view_elements?.should be_true
    end

    it "should be interested in container if it contains more then one view" do
      form = prepare_form {|default_tab, section| [default_tab, default_tab]}
      form.has_investigator_view_elements?.should be_true
    end

  end

  describe "when trying to call publish on a published instance" do

    fixtures :forms, :form_elements, :questions

    it "should fail" do
      form_to_publish = Form.find(1)
      error_message = ""

      begin
        published_form = form_to_publish.publish
        published_form.publish
      rescue RuntimeError => error
        error_message = error.message
      end
      error_message.should eql("Cannot publish an already published version")
    end
  end

  describe "when validation on the published instance fails" do

    fixtures :forms, :form_elements, :questions

    it "should build a list of errors on the instance getting published" do
      form_to_publish = Form.find(1)
      form_to_publish.form_base_element.children[0].destroy
      form_to_publish.publish.should be_nil
      form_to_publish.errors.size.should eql(1)
    end
  end

  describe "when first published" do

    fixtures :forms, :form_elements, :questions, :diseases_forms, :diseases, :export_columns

    before(:each) do
      @form_to_publish = Form.find(1)
      @published_form = @form_to_publish.publish
    end

    it "should give itself published status" do
      @form_to_publish.status.should eql("Published")
    end

    it 'should not be short name editable' do
      @form_to_publish.should_not be_short_name_editable
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
      demo_section.description.should eql(form_elements(:demographic_section).description)
      demo_section.help_text.should eql(form_elements(:demographic_section).help_text)

      demo_group = demo_section.children[0]
      demo_group.class.name.should eql("GroupElement")
      demo_group.form_id.should eql(@published_form.id)
      demo_group.name.should eql(form_elements(:demographic_group).name)

      demo_q1 = demo_group.children[0]
      demo_q1.class.name.should eql("QuestionElement")
      demo_q1.form_id.should eql(@published_form.id)
      demo_q1.name.should be_nil
      demo_q1.export_column_id.should eql(form_elements(:demo_group_q1).export_column_id)

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
      second_tab.children_count.should eql(3)

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

      @form_to_publish.form_element_cache.reload
      published_form = @form_to_publish.publish

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
      published_form = form_to_publish.publish
      published_form.disease_ids.length.should == form_to_publish.disease_ids.length
      published_form.disease_ids.sort.should == form_to_publish.disease_ids.sort
    end

  end

  describe "when published a second time" do

    fixtures :forms, :form_elements, :questions

    it "should give the second version live status and first version archived status" do
      form_to_publish = Form.find(1)
      first_version = form_to_publish.publish
      first_version.status.should eql("Live")
      second_version = form_to_publish.publish
      second_version.status.should eql("Live")
      first_version.reload
      first_version.status.should eql("Archived")
    end

  end

  describe "when publishing a form that contains values with codes" do

    fixtures :forms, :form_elements, :questions, :export_disease_groups, :export_columns, :export_conversion_values

    before(:each) do
      @form_to_publish = Form.find(forms(:hep_b_form).id)
      @published_form = @form_to_publish.publish
    end

    it "should copy the codes" do
      default_view = @published_form.investigator_view_elements_container.children[0]
      question_of_interest = default_view.children[1]
      value_set_of_interest = question_of_interest.children[0]
      value_set_of_interest.children[0].code.should == form_elements(:coded_yes_value_for_hep_b_form).code
      value_set_of_interest.children[1].code.should == form_elements(:coded_no_value_for_hep_b_form).code
      value_set_of_interest.children[2].code.should == form_elements(:coded_unk_value_for_hep_b_form).code
    end

  end

  describe 'when validating a form structure' do

    it 'should validate the bootstrapped form elements' do
      @form.save_and_initialize_form_elements
      @form.structural_errors.size.should == 0
      @form.structure_valid?.should be_true
      @form.errors.empty?.should be_true

    end

    it 'should fail validation if investigator view container does not exist' do
      @form.save_and_initialize_form_elements
      @form.investigator_view_elements_container.destroy
      @form.reload
      @form.structural_errors.size.should == 1
      @form.structure_valid?.should be_false
      @form.errors.size.should == 1
    end

    it 'should fail validation if core view container does not exist' do
      @form.save_and_initialize_form_elements
      @form.core_view_elements_container.destroy
      @form.reload
      @form.structural_errors.size.should == 1
      @form.structure_valid?.should be_false
      @form.errors.size.should == 1
    end

    it 'should fail validation if core field container does not exist' do
      @form.save_and_initialize_form_elements
      @form.core_field_elements_container.destroy
      @form.reload
      @form.structural_errors.size.should == 1
      @form.structure_valid?.should be_false
      @form.errors.size.should == 1
    end

  end

  describe 'when validating a form structure' do

    fixtures :forms, :form_elements, :questions

    it 'should validate the left/right nested set elements' do
      @form = Form.find(1)
      default_view = @form.investigator_view_elements_container.children[0]
      ActiveRecord::Base.connection.execute("update form_elements set lft = 32, rgt = 3 where id = #{default_view.id};")
      @form.structural_errors.size.should == 1
      @form.structure_valid?.should be_false
      @form.errors.size.should == 1
    end

  end

  describe 'when rolling back' do

    fixtures :forms, :form_elements, :questions

    it 'should return the rolled back form on success' do
      @original_form = Form.find(1)
      @published_form = @original_form.publish

      # Add something to the original form post-publish
      tab = ViewElement.new(:name => "New Tab")
      tab.parent_element_id = @original_form.investigator_view_elements_container.id
      tab.save_and_add_to_form
      @original_form.investigator_view_elements_container.add_child(tab)
      @original_form.investigator_view_elements_container.children_count.should == 3

      @rolled_back_form = @original_form.rollback

      @rolled_back_form.status.should == "Published"
      @rolled_back_form.rolled_back_from_id.should == @original_form.id
      @original_form.status.should == "Invalid"
      @original_form.is_template.should == false

      # Look for the thing added on the rolled back form, it shouldn't be there
      @rolled_back_form.investigator_view_elements_container.children_count.should == 2

    end

    it 'should set any previously published version to archived when a rolled back form is published' do
      @original_form = Form.find(1)
      @published_form = @original_form.publish
      @published_form.status.should == "Live"

      @rolled_back_form = @original_form.rollback
      @published_form_after_rollback = @rolled_back_form.publish

      @published_form_after_rollback.status.should == "Live"
      @published_form.reload
      @published_form.status.should == "Archived"
    end

    it 'should return nil with an error on the form when there is no published version to roll back to' do
      @original_form = Form.find(1)
      @rolled_back_form = @original_form.rollback
      @rolled_back_form.should be_nil
      @original_form.errors.size.should == 1
    end

    it 'should return nil with an error on the form when the rolled back form is invalid' do
      @original_form = Form.find(1)
      @published_form = @original_form.publish
      @published_form.investigator_view_elements_container.destroy
      @rolled_back_form = @original_form.rollback
      @rolled_back_form.should be_nil
      @original_form.errors.size.should == 1
    end

  end

  describe 'a copied form' do
    fixtures :forms, :form_elements, :questions, :diseases, :diseases_forms, :export_columns

    before :each do
      @original_form = Form.find(1)
      @copied_form = @original_form.copy
    end

    it 'should not impact the original form' do
      @original_form.diseases.size.should == 2
      @original_form.form_base_element.should_not be_nil
    end

    it "should append ' (Copy)' to the new form name" do
      @copied_form.name.should eql(@original_form.name + " (Copy)")
    end

    it "should append '_copy' to the short name" do
      @copied_form.short_name.should eql(@original_form.short_name + '_Copy')
    end

    it "should try to generate a unique short name" do
      second_copy = @original_form.copy
      second_copy.short_name.should eql(@copied_form.short_name + '1')
    end

    it 'should match the original description' do
      @copied_form.description.should eql(@original_form.description)
    end

    it 'should have same diseases and the original form' do
      @copied_form.diseases.size.should == @original_form.diseases.size
    end

    it 'should not have the same created_at date as the oringal form' do
      @copied_form.created_at.should_not eql(@original_form.created_at)
    end

    it 'should not have the same updated_at date as the original form' do
      @copied_form.updated_at.should_not eql(@original_form.created_at)
    end

    it 'should not be published' do
      @copied_form.status.should eql("Not Published")
    end

    it 'should not be rolled back' do
      @copied_form.rolled_back_from_id.should be_nil
    end

    it 'should have the same event type as the original' do
      @copied_form.event_type.should eql(@original_form.event_type)
    end

    it 'should have the same jurusdiction as the original' do
      @copied_form.jurisdiction.should eql(@original_form.jurisdiction)
    end

    it 'should copy the form elements' do
      @copied_form.form_base_element.should_not be_nil
      @copied_form.form_base_element.children.size.should == 3
      @copied_form.form_base_element.all_children.size.should == @original_form.form_base_element.all_children.size
    end

    it 'should copy the export column data' do
      default_view = @copied_form.investigator_view_elements_container.children[0]
      demo_section = default_view.children[0]
      demo_group = demo_section.children[0]
      demo_q1 = demo_group.children[0]
      demo_q1.export_column_id.should eql(form_elements(:demo_group_q1).export_column_id)
    end

  end

  describe 'a copied form' do

    before(:each) do
      @form =  Factory.build(:form, :event_type => "morbidity_event")
      @form.save_and_initialize_form_elements
      @copied_form = @form.copy
    end

    it 'should be a template' do
      @copied_form.is_template.should be_true
      @copied_form.template_id.should be_nil
      @copied_form.version.should be_nil
    end

  end

  describe "when copying a form that contains values with codes" do

    fixtures :forms, :form_elements, :questions, :export_disease_groups, :export_columns, :export_conversion_values

    before(:each) do
      @original_form = Form.find(forms(:hep_b_form).id)
      @copied_form = @original_form.copy
    end

    it "should copy the codes" do
      default_view = @copied_form.investigator_view_elements_container.children[0]
      question_of_interest = default_view.children[1]
      value_set_of_interest = question_of_interest.children[0]
      value_set_of_interest.children[0].code.should == form_elements(:coded_yes_value_for_hep_b_form).code
      value_set_of_interest.children[1].code.should == form_elements(:coded_no_value_for_hep_b_form).code
      value_set_of_interest.children[2].code.should == form_elements(:coded_unk_value_for_hep_b_form).code
    end

  end

  describe 'when affecting export/import lookup info' do

    fixtures :forms, :form_elements, :questions, :export_disease_groups, :export_columns, :export_conversion_values, :external_codes

    it 'should build the correct external code lookup values for an element after an external code has changed' do
      @core_follow_up = FormElement.find(form_elements(:core_follow_up_for_hep_a_form).id)
      @core_follow_up.code_condition_lookup.should eql("yesno#{FormElement.export_lookup_separator}M")
      @code_to_change = ExternalCode.find(external_codes(:yesno_maybe).id)
      @code_to_change.code_name = "YessirNossir"
      @code_to_change.the_code = "YS"
      @code_to_change.save!
      @core_follow_up.code_condition_lookup.should eql("YessirNossir#{FormElement.export_lookup_separator}YS")
    end

    it 'should build the correct export column lookup values for an element after an export column has changed' do
      @cdc_question = FormElement.find(form_elements(:cdc_question_for_hep_a_form).id)
      @cdc_question.cdc_export_column_lookup.should eql("Hepatitis#{FormElement.export_lookup_separator}JAUNDICED")

      @export_column_to_change = ExportColumn.find(export_columns(:hep_jaundiced).id)
      @export_column_to_change.export_column_name = "acupunctured?"
      @export_column_to_change.save!

      @export_disease_group_to_change = @export_column_to_change.export_disease_group
      @export_disease_group_to_change.name = "Hep"
      @export_disease_group_to_change.save!

      @cdc_question.cdc_export_column_lookup.should eql("Hep#{FormElement.export_lookup_separator}acupunctured?")
    end

    it 'should build the correct export conversion value lookup values for an element after an export conversion value has changed' do
      @cdc_yes_value = FormElement.find(form_elements(:cdc_yes_value_for_hep_a_form).id)
      @cdc_yes_value.cdc_export_conversion_value_lookup.should eql("Hepatitis#{FormElement.export_lookup_separator}JAUNDICED#{FormElement.export_lookup_separator}Yes#{FormElement.export_lookup_separator}1")

      @conversion_value_to_change = ExportConversionValue.find(export_conversion_values(:jaundiced_yes).id)
      @conversion_value_to_change.value_from = "Yessir"
      @conversion_value_to_change.value_to = "11"
      @conversion_value_to_change.save!

      @export_column_to_change = ExportColumn.find(export_columns(:hep_jaundiced).id)
      @export_column_to_change.export_column_name = "acupunctured?"
      @export_column_to_change.save!

      @export_disease_group_to_change = @export_column_to_change.export_disease_group
      @export_disease_group_to_change.name = "Hep"
      @export_disease_group_to_change.save!

      @cdc_yes_value.cdc_export_conversion_value_lookup.should eql("Hep#{FormElement.export_lookup_separator}acupunctured?#{FormElement.export_lookup_separator}Yessir#{FormElement.export_lookup_separator}11")
    end

  end

  describe 'when exporting' do

    fixtures :forms, :form_elements, :questions, :export_disease_groups, :export_columns, :export_conversion_values, :external_codes

    it 'should create a zip file with the exported form' do
      @form = Form.find(forms(:hep_a_form).id)
      export_file_path = @form.export
      export_file_path.should_not be_nil
      form_name_for_file =  forms(:hep_a_form).name.downcase.sub(" ", "_")

      export_file_path[export_file_path.rindex("/")+1...export_file_path.size].should eql(form_name_for_file + ".zip")

      Zip::ZipFile.foreach(export_file_path) do |file|
        ["elements", "form"].include?(file.name).should be_true
      end
    end

    it "should substitute a dash for a backslash" do
      @form = Form.find(forms(:hep_a_form).id)
      @form.name = 'i \ form'
      @form.save!
      @form.export.should == "/tmp/i_-_form.zip"
    end

    it "should substitute a dash for a forward slash" do
      @form = Form.find(forms(:hep_a_form).id)
      @form.name = 'i / form'
      @form.save!
      @form.export.should == "/tmp/i_-_form.zip"
    end

    it 'should substitute underscores for spaces' do
      @form = Form.find(forms(:hep_a_form).id)
      @form.name = "i am a form"
      @form.save!
      export_file_path = @form.export
      export_file_path.should == "/tmp/i_am_a_form.zip"
    end

    it 'should strip extra spaces from the form name' do
      @form = Form.find(forms(:hep_a_form).id)
      @form.name = "  i am a form   "
      @form.save!
      export_file_path = @form.export
      export_file_path.should == "/tmp/i_am_a_form.zip"
    end

    it 'should fail if a code behind a condition cannot be found' do
      @form = Form.find(forms(:hep_a_form).id)
      ExternalCode.destroy(external_codes(:yesno_maybe).id)
      @form.export.should be_nil
      @form.errors.empty?.should be_false
    end

    it 'should fail if an export column cannot be found' do
      @form = Form.find(forms(:hep_a_form).id)
      ExportColumn.destroy(export_columns(:hep_jaundiced).id)
      @form.export.should be_nil
      @form.errors.empty?.should be_false
    end

    it "should fail if an export column's group cannot be found" do
      @form = Form.find(forms(:hep_a_form).id)
      ExportDiseaseGroup.destroy(export_disease_groups(:hep_group).id)
      @form.export.should be_nil
      @form.errors.empty?.should be_false
    end

    it "should fail if an export conversion value cannot be found" do
      @form = Form.find(forms(:hep_a_form).id)
      ExportConversionValue.destroy(export_conversion_values(:jaundiced_yes).id)
      @form.export.should be_nil
      @form.errors.empty?.should be_false
    end

  end

  describe 'when importing' do

    fixtures :forms, :form_elements, :questions, :export_disease_groups, :export_columns, :export_conversion_values

    before(:each) do
      @original_form = Form.find(forms(:hep_a_form).id)
      @imported_form = Form.import(self.fixture_file_upload('files/hep_a.zip', 'application/zip'))
    end

    it 'should match the original name' do
      @imported_form.name.should eql(@original_form.name)
    end

    it 'should match the original description' do
      @imported_form.description.should eql(@original_form.description)
    end

    it 'should have no diseases' do
      @imported_form.diseases.size.should == 0
    end

    it 'should not have the same created_at date as the oringal form' do
      @imported_form.created_at.should_not eql(@original_form.created_at)
    end

    it 'should not have the same updated_at date as the original form' do
      @imported_form.updated_at.should_not eql(@original_form.created_at)
    end

    it 'should be a template' do
      @imported_form.is_template.should be_true
      @imported_form.template_id.should be_nil
      @imported_form.version.should be_nil
    end

    it 'should not be published' do
      @imported_form.status.should eql("Not Published")
    end

    it 'should not be rolled back' do
      @imported_form.rolled_back_from_id.should be_nil
    end

    it 'should have the same event type as the original' do
      @imported_form.event_type.should eql(@original_form.event_type)
    end

    it 'should have no jurisdiction' do
      @imported_form.jurisdiction.should be_nil
    end

    it 'should import the form elements' do
      @imported_form.form_base_element.should_not be_nil
      @imported_form.form_base_element.children.size.should == 3
      @imported_form.form_base_element.all_children.size.should == @original_form.form_base_element.all_children.size
    end

    it 'should import the export column data' do
      default_view = @imported_form.investigator_view_elements_container.children[0]
      cdc_q = default_view.children[1]
      cdc_q.export_column_id.should eql(form_elements(:cdc_question_for_hep_a_form).export_column_id)
    end

  end

  describe 'when exporting the library' do

    fixtures :forms, :form_elements, :questions, :export_disease_groups, :export_columns, :export_conversion_values

    before(:each) do
      FormElement.find(form_elements(:second_tab_q)).add_to_library.should_not be_nil
      FormElement.find(form_elements(:core_follow_up_for_hep_a_form)).add_to_library.should_not be_nil
      FormElement.find(form_elements(:cdc_question_for_hep_a_form)).add_to_library.should_not be_nil
      FormElement.find(form_elements(:coded_value_set_for_hep_b_form)).add_to_library.should_not be_nil
    end

    it 'should export all elements in the library to a file' do
      export_file_path = Form.export_library
      export_file_path.should_not be_nil
      export_file_path[export_file_path.rindex("/")+1...export_file_path.size].should eql("library-export.zip")

      Zip::ZipFile.foreach(export_file_path) do |file|
        ["library-elements"].include?(file.name).should be_true
      end
    end

    it 'should fail if a code behind a condition cannot be found' do
      ExternalCode.destroy(external_codes(:yesno_maybe).id)
      lambda {  Form.export_library }.should raise_error
    end

    it 'should fail if an export column cannot be found' do
      ExportColumn.destroy(export_columns(:hep_jaundiced).id)
      lambda {  Form.export_library }.should raise_error
    end

    it "should fail if an export column's group cannot be found" do
      ExportDiseaseGroup.destroy(export_disease_groups(:hep_group).id)
      lambda {  Form.export_library }.should raise_error
    end

    it "should fail if an export conversion value cannot be found" do
      ExportConversionValue.destroy(export_conversion_values(:jaundiced_yes).id)
      lambda {  Form.export_library }.should raise_error
    end

  end

  describe 'when importing the library' do

    fixtures :forms, :form_elements, :questions, :export_disease_groups, :export_columns, :export_conversion_values

    it 'should add all of the elements in the file to the library' do
      lambda { Form.import_library(self.fixture_file_upload('files/library-export.zip', 'application/zip')) }.should change { FormElement.library_roots.size }.by(4)
    end

    it 'should give each tree in the library a different tree id' do
      Form.import_library(self.fixture_file_upload('files/library-export.zip', 'application/zip'))
      tree_ids = []
      FormElement.library_roots.each do |root|
        tree_ids.include?(root.tree_id).should be_false
        tree_ids << root.tree_id
      end
    end

    it 'should have maintained the code on coded values' do
      Form.import_library(self.fixture_file_upload('files/library-export.zip', 'application/zip'))
      coded_value_set = FormElement.library_roots.detect { |root| root.name == form_elements(:coded_value_set_for_hep_b_form).name}
      coded_value_set.children[0].code.should eql(form_elements(:coded_yes_value_for_hep_b_form).code)
      coded_value_set.children[1].code.should eql(form_elements(:coded_no_value_for_hep_b_form).code)
      coded_value_set.children[2].code.should eql(form_elements(:coded_unk_value_for_hep_b_form).code)
    end

    it 'should fail if a code behind a condition cannot be found' do
      ExternalCode.destroy(external_codes(:yesno_maybe).id)
      lambda {  Form.import_library(self.fixture_file_upload('files/library-export.zip', 'application/zip')) }.should raise_error
    end

    it 'should fail if an export column cannot be found' do
      ExportColumn.destroy(export_columns(:hep_jaundiced).id)
      lambda {  Form.import_library(self.fixture_file_upload('files/library-export.zip', 'application/zip')) }.should raise_error
    end

    it "should fail if an export column's group cannot be found" do
      ExportDiseaseGroup.destroy(export_disease_groups(:hep_group).id)
      lambda {  Form.import_library(self.fixture_file_upload('files/library-export.zip', 'application/zip')) }.should raise_error
    end

    it "should fail if an export conversion value cannot be found" do
      ExportConversionValue.destroy(export_conversion_values(:jaundiced_yes).id)
      lambda {  Form.import_library(self.fixture_file_upload('files/library-export.zip', 'application/zip')) }.should raise_error
    end

  end

  describe 'when importing into a changed or different environment' do

    fixtures :forms, :form_elements, :questions, :export_disease_groups, :export_columns, :export_conversion_values

    it 'should fail if a code behind a condition cannot be found' do
      ExternalCode.destroy(external_codes(:yesno_maybe).id)
      lambda { Form.import(fixture_file_upload('files/hep_a.zip', 'application/zip')) }.should raise_error(RuntimeError)
    end

    it 'should fail if an export column cannot be found' do
      ExportColumn.destroy(export_columns(:hep_jaundiced).id)
      lambda { Form.import(fixture_file_upload('files/hep_a.zip', 'application/zip')) }.should raise_error(RuntimeError)
    end

    it "should fail if an export column's group cannot be found" do
      ExportDiseaseGroup.destroy(export_disease_groups(:hep_group).id)
      lambda { Form.import(fixture_file_upload('files/hep_a.zip', 'application/zip')) }.should raise_error(RuntimeError)
    end

    it "should fail if an export conversion value cannot be found" do
      ExportConversionValue.destroy(export_conversion_values(:jaundiced_yes).id)
      lambda { Form.import(fixture_file_upload('files/hep_a.zip', 'application/zip')) }.should raise_error(RuntimeError)
    end

  end

  describe 'when pushing to events' do

    fixtures :diseases, :entities, :places, :places_types, :users

    before(:each) do
      @user = users(:default_user)
      User.stubs(:current_user).returns(@user)

      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Green"
            }
          }
        },
        "jurisdiction_attributes" => {
          "secondary_entity_id" => entities(:Unassigned_Jurisdiction).id
        },
        "disease_event_attributes" => { "disease_id" => diseases(:form_push_disease).id }
      }

      @form_hash = {
        "name"=>"Form Push Form",
        "short_name"=> Digest::MD5::hexdigest(DateTime.now.to_s),
        "event_type"=>"morbidity_event",
        "disease_ids"=>[diseases(:form_push_disease).id],
        "jurisdiction_id"=>""
      }
    end

    it "should not push if the form has not been published" do
      event = MorbidityEvent.new(@event_hash)
      event.save!
      event.reload
      event.form_references.size.should == 0

      with_form(@form_hash) do |form|
        result = form.push
        result.should be_nil
        event.reload
        event.form_references.size.should == 0
      end
    end

    it "should not push and have errors if the form has no diseases associated with it" do
      event = MorbidityEvent.new(@event_hash)
      event.save!
      event.reload
      event.form_references.size.should == 0

      with_form(@form_hash) do |form|
        form.diseases.clear
        form.publish
        result = form.push
        result.should be_nil
        form.errors.should_not be_empty
        event.reload
        event.form_references.size.should == 0
      end
    end

    it "it should push to all events with the form's disease and jurisdiction" do
      event = MorbidityEvent.new(@event_hash)
      event.save!
      event.reload
      event.form_references.size.should == 0

      with_form(@form_hash) do |form|
        published_form = form.publish
        result = form.push
        result.should eql(1)
        form.errors.should be_empty
        event.reload
        event.form_references.size.should == 1
        event.form_references[0].form.id.should eql(published_form.id)
      end
    end

    it "should not push to events with the same disease but a different event type" do
      contact_hash = {
        "contact_child_events_attributes" => [ {
            "interested_party_attributes" => {
              "person_entity_attributes" => {
                "person_attributes" => { "last_name" => "White" },
                "telephones_attributes" => {
                  "99" => { "phone_number" => "" }
                }
              }
            },
            "participations_contact_attributes" => {},
            "disease_event_attributes" => { "disease_id" =>diseases(:form_push_disease).id} } ] }

      event = MorbidityEvent.new(@event_hash.merge(contact_hash))
      contact_event = event.contact_child_events[0]
      contact_event.save!
      contact_event.reload
      contact_event.form_references.size.should == 0

      with_form(@form_hash) do |form|
        published_form = form.publish
        result = form.push
        result.should eql(0)
        form.errors.should be_empty
        contact_event.reload
        contact_event.form_references.size.should == 0
      end
    end

    it "should not push to events with the same disease and type, but a different jurisdiction" do
      @event_hash[:jurisdiction_attributes] = {
        :secondary_entity_id => entities(:Summit_County).id
      }
      event = MorbidityEvent.new(@event_hash)
      event.save!
      event.reload
      event.form_references.size.should == 0

      @form_hash = @form_hash.merge("jurisdiction_id"=> entities(:Unassigned_Jurisdiction).id)

      with_form(@form_hash) do |form|
        published_form = form.publish
        result = form.push
        result.should eql(0)
        form.errors.should be_empty
        event.reload
        event.form_references.size.should == 0
      end
    end


    it "should not push to events that already have a version of this form associated to it" do
      with_form(@form_hash) do |form|
        published_form = form.publish
        event = MorbidityEvent.new(@event_hash)
        event.save!
        event.reload
        event.form_references.size.should == 1

        result = form.push
        result.should == 0
        form.publish
        result = form.push
        result.should == 0

        event.reload
        event.form_references.size.should == 1
        event.form_references[0].form.id.should  == published_form.id
      end
    end

  end

  describe "when deactivating a form" do

    before(:each) do
      @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => Digest::MD5::hexdigest(DateTime.now.to_s))
      @form.save_and_initialize_form_elements.should be_true
    end

    it "should not deactivate a form that is not published" do
      @form.deactivate.should be_nil
      @form.errors.empty?.should be_false
    end


    it "should not deactivate a form that is already inactive" do
      @published_form = @form.publish
      @published_form.should_not be_nil
      @form.deactivate.should be_true
      @form.errors.empty?.should be_true
      @form.deactivate.should be_nil
      @form.errors.empty?.should be_false
    end

    it "should make the published master copy inactive" do
      @published_form = @form.publish
      @published_form.should_not be_nil
      @form.deactivate.should be_true
      @form.errors.empty?.should be_true
      @form.status.should eql("Inactive")
    end

    it "should archive the live version" do
      @published_form = @form.publish
      @published_form.should_not be_nil
      @form.deactivate.should be_true
      @form.errors.empty?.should be_true
      @form.most_recent_version.status.should eql("Archived")
    end

    it 'should not be short name editable' do
      @form.publish.should_not be_nil
      @form.deactivate.should be_true
      @form.should_not be_short_name_editable
    end

  end

  describe 'when using form metadata helpers' do

    fixtures :forms, :form_elements, :questions, :export_disease_groups, :export_columns, :export_conversion_values

    describe 'on test form' do
      before(:each) do
        @form = Form.find(forms(:test_form).id)
      end

      it 'question_count should return the number of questions' do
        @form.question_count.should == 13
      end

      it 'element_count should return the number of elements' do
        @form.element_count.should == 27
      end

      it 'cdc_question_count should return the number of CDC questions' do
        @form.cdc_question_count.should == 1
      end

      it 'core_element_count should return the number of core element ties' do
        @form.core_element_count.should == 2
      end
    end
  end

  describe 'publishing a deactivated' do
    it 'should fail if short name already in use' do
      Form.transaction do
        # publish a form and deactivate it
        f1 = Form.new :name => 'First form', :short_name => 'first_form', :event_type => 'morbidity_event'
        f1.save_and_initialize_form_elements.should_not be_nil
        f1.publish.should_not be_nil
        f1.deactivate.should_not be_nil

        # publish another form w/ the same short name
        f2 = Form.new :name => 'Second form', :short_name => 'first_form', :event_type => 'morbidity_event'
        f2.save_and_initialize_form_elements.should_not be_nil
        f2.publish.should_not be_nil

        # publishing the forst form should fail
        f1.publish.should be_nil
        f1.errors.on(:short_name).should_not be_nil
      end
    end
  end


end
