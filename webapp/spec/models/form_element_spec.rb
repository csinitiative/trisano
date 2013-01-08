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

describe FormElement do

  before(:each) do
    @form_element = FormElement.new
  end

  it "should be valid" do
    @form_element.should be_valid
  end

  it "cannot receive value sets" do
    @form_element.can_receive_value_set?.should_not be_true
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
    @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'form_element_short')
    @form.save_and_initialize_form_elements
    @question_element = QuestionElement.new({
        :parent_element_id => @form.investigator_view_elements_container.id,
        :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
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

  it "should copy the question's follow up questions" do
    follow_up_container = FollowUpElement.create({:tree_id => 1, :form_id => 1,:name => "Follow up", :condition => "Yes"})
    follow_up_question = Question.create({:question_text => "Did you do it?", :data_type => "single_line_text", :short_name => "did"})
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

  it "should not copy to the library if the tree it is copying to is invalid" do
    group_element = GroupElement.create(:name => "Test Group", :tree_id => 989898)
    invalidate_tree(group_element)
    group_element.reload
    @form_element.add_to_library(group_element).should be_nil
    @form_element.errors.should_not be_empty
  end

end

describe "FormElement working with the library" do

  before(:each) do
    @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'form_element_short_2')
    @form.save_and_initialize_form_elements

    @group_tree_id = 9999
    @group_element = GroupElement.create(:name => "Test Group", :tree_id => @group_tree_id)

    @independent_value_set = ValueSetElement.create(:name => "Indie Value Set", :tree_id => @group_tree_id)
    @group_element.add_child(@independent_value_set)

    @indie_value_1 = ValueElement.create(:name => "Yes", :tree_id => @group_tree_id)
    @indie_value_2 = ValueElement.create(:name => "No", :tree_id => @group_tree_id)
    @independent_value_set.add_child(@indie_value_1)
    @independent_value_set.add_child(@indie_value_2)

    @question_with_value_set = Question.create(:question_text => 'How\'s it going?',
                                               :data_type => "drop_down",
                                               :short_name => "how")
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
      :data_type => "single_line_text",
      :short_name => "splain")
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
      copied_group.children[0].question.question_text.should eql('How\'s it going?')
      copied_group.children[1].question.should_not be_nil
      copied_group.children[1].question.question_text.should eql("Explain.")
    end

    it "shouldn't copy anything if the form is invalid" do
      to_element = SectionElement.new(:name => "Section", :parent_element_id => @form.investigator_view_elements_container.id)
      to_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      lambda do
        to_element.copy_from_library(@group_element)
      end.should raise_error(FormElement::InvalidFormStructure)
      to_element.errors.should_not be_empty
    end

  end

  describe "when copying an individual question to a section" do

    it "should copy the question element, its value set, and the question" do
      to_element = SectionElement.new(:name => "Section", :parent_element_id => @form.investigator_view_elements_container.id)
      to_element.save_and_add_to_form.should_not be_nil

      to_element.children.size.should eql(0)

      to_element.copy_from_library(@question_element_with_value_set).should be_true

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
      copied_question.question_text.should eql('How\'s it going?')
    end

    it 'should not copy a question to a form if the question short name is already in use' do
      to_element = SectionElement.new(:name => "Section", :parent_element_id => @form.investigator_view_elements_container.id)
      to_element.save_and_add_to_form.should_not be_nil
      existing_question = QuestionElement.new( :parent_element_id => to_element.id, :question_attributes => {
          :question_text => 'How\'s it going?',
          :data_type => "drop_down",
          :short_name => "how" })
      existing_question.save_and_add_to_form.should_not be_nil
      to_element.children.size.should eql(1)
      lambda do
        to_element.copy_from_library(@question_element_with_value_set)
      end.should raise_error(ActiveRecord::RecordInvalid)
      to_element.children.size.should eql(1)
    end

    it "shouldn't copy anything if the form is invalid" do
      to_element = SectionElement.new(:name => "Section", :parent_element_id => @form.investigator_view_elements_container.id)
      to_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      lambda do
        to_element.copy_from_library(@question_element_with_value_set)
      end.should raise_error(FormElement::InvalidFormStructure)
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

      lambda do
        to_element.copy_from_library(@independent_value_set)
      end.should raise_error(FormElement::InvalidFormStructure)
      to_element.errors.should_not be_empty
    end

    it "shouldn't copy anything if the to-element is a question element that already has a value set" do
      question= Question.create(:question_text => "Que?",
                                :data_type => "drop_down",
                                :short_name => "que_q" )
      container = @form.investigator_view_elements_container
      to_element = QuestionElement.new(:parent_element_id => container.id,
                                       :question => question)
      to_element.save_and_add_to_form.should_not be_nil

      to_element.copy_from_library(@independent_value_set).should_not be_nil
      to_element.errors.should be_empty

      lambda do
        to_element.copy_from_library(@independent_value_set)
      end.should raise_error(FormElement::IllegalCopyOperation)
      to_element.errors.should_not be_empty
    end

  end

  describe "when deleting from the library" do

    it "should delete from a group if the group is valid" do
      @question_element_with_value_set.destroy_and_validate.should be_true
    end

    it "should delete a standalone element" do
      copy = @question_element_with_value_set.add_to_library
      copy.should_not be_nil
      @question_element_with_value_set.destroy_and_validate.should_not be_nil
    end

    it "should not delete from a group if the group is invalid" do
      invalidate_tree(@group_element)
      @question_element_with_value_set.destroy_and_validate.should be_nil
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
    @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'form_element_short_3')
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
    @element.save_and_add_to_form
    #.should be_true
    invalidate_form(@form)
    @element.destroy_and_validate.should be_nil
  end

  it "should return false on reorder if the form element structure is invalid" do
    default_view = @form.investigator_view_elements_container.children[0]

    # Force a validation failure
    def default_view.validate_form_structure
      errors.add_to_base("Bad error")
      raise
    end

    default_view.reorder_element_children([3, 8, 12]).should be_nil
  end

  describe 'library roots named scope' do
    fixtures :forms, :form_elements, :questions, :export_disease_groups, :export_columns, :export_conversion_values

    it 'should return only library roots' do
      library_copy = nil
      form_element = FormElement.find(form_elements(:second_tab_q))
      lambda { library_copy = form_element.add_to_library }.should change {FormElement.library_roots.size}.by(1)
      FormElement.library_roots.detect { |root| root.id == library_copy.id }.should_not be_nil
      FormElement.library_roots.detect { |root| root.id == form_element.id }.should be_nil
    end

  end

  describe '#next_tree_id' do
    it 'should return tree_ids in sequence, even when called multiple times in a transaction' do
      FormElement.transaction do
        first_tree_id = FormElement.next_tree_id
        second_tree_id = FormElement.next_tree_id
        second_tree_id.should eql(first_tree_id +1)
      end
    end
  end

  describe "copying" do

    before do
      @form = Factory.build(:form)
      @form.save_and_initialize_form_elements
      @container = @form.investigator_view_elements_container
      @question_element = Factory.build(:question_element)
      @question_element.parent_element_id = @container.id
      @question_element.save_and_add_to_form.should be_true
      @group_element = Factory.build(:group_element)
      @group_element.save_and_add_to_form.should be_true
      @next_id = FormElement.next_tree_id
    end

    it "creates a shallow copy, ready to be added to a form or tree" do
      result = @container.copy(:tree_id => @next_id, :is_template => true)
      assert_element_shallow_copy(@container, result)
      assert_element_in_tree(result, @next_id)
    end

    it "copies question on question elements" do
      result = @question_element.copy_with_children(:tree_id => @next_id,
                                                    :is_template => true)
      assert_element_in_tree(result, @next_id)
      assert_element_shallow_copy(@question_element, result)
      assert_question_is_a_copy(@question_element.question, result.question)
    end

    describe "children" do
      it "returns a copy of the subtree rooted at self" do
        result = @container.copy_with_children(:tree_id => @next_id,
                                               :is_template => true)
        assert_element_in_tree(result, @next_id)
        assert_element_shallow_copy(@container, result)
        assert_element_deep_copy(@container, result)
      end

      describe "and passing a parent" do
        it "assigns the copy to the parent" do
          result = @question_element.copy_with_children(:parent => @group_element,
                                                        :tree_id => @group_element.tree_id,
                                                        :is_template => true)
          result.parent.should == @group_element
        end

        it "raises an error if tree_id doesn't match parent's tree_id" do
          lambda do
            @question_element.copy_with_children(:parent => @group_element,
                                                 :tree_id => @tree_id,
                                                 :is_template => true)
          end.should raise_error("tree_id must match the parent element's tree_id, if parent element is not nil")
        end
      end

      it "copies deep nested value sets (when they are valid)" do
        radio_question = Factory.build(:question_element)
        radio_question.question.data_type = 'radio_button'
        radio_question.parent_element_id = @form.investigator_view_elements_container.id
        radio_question.save_and_add_to_form.should be_true
        follow_up = Factory.build(:follow_up_element)
        follow_up.parent_element_id = radio_question.id
        follow_up.save_and_add_to_form.should be_true
        drop_down_question = Factory.build(:question_element)
        drop_down_question.question.data_type = 'drop_down'
        drop_down_question.parent_element_id = follow_up.id
        drop_down_question.save_and_add_to_form.should be_true
        vs = Factory.build(:value_set_element)
        vs.parent_element_id = drop_down_question.id
        vs.save_and_add_to_form.should be_true
        blank = Factory.build(:value_element, :name => nil)
        blank.parent_element_id = vs.id
        blank.save_and_add_to_form.should be_true
        radio_question.copy_with_children(:tree_id =>@next_id,
                                          :is_template => true).should be_true
      end
    end

    describe "an entire group" do
      it "copies questions" do
        lq = Factory.build(:question_element)
        lq.parent_element_id = @group_element.id
        lq.save_and_add_to_form
        container = @form.investigator_view_elements_container
        result = @group_element.copy_with_children(:form_id => @form.id,
                                                   :is_template => false)
        result.children.any? do |e|
          e.question.try(:question_text) == lq.question.question_text
        end.should be_true
      end

      it "doesn't copy value sets" do
        vs = Factory.build(:value_set_element)
        vs.parent_element_id = @group_element.id
        vs.save_and_add_to_form
        container = @form.investigator_view_elements_container
        result = @group_element.copy_with_children(:form_id => @form.id,
                                                   :is_template => false)
        result.children.should == []
      end
    end

  end

end
