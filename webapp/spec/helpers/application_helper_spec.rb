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

describe ApplicationHelper do
  include Trisano::HTML::Matchers

  describe "ApplicationHelper#localize_or_default" do
    it "should handle strings that can't be parsed gracefully" do
      helper.localize_or_default("432fsdfsdf").should  == "&nbsp;"
    end

  end

  it "should determine replacement elements for a library admin action" do
    question = Question.create({:question_text => "?", :data_type => "single_line_text", :short_name => "q"})
    question_element = QuestionElement.create(:tree_id => "1", :question => question)

    replace_element, replace_partial = helper.replacement_elements(question_element)

    replace_element.should eql("library-admin")
    replace_partial.should eql("forms/library_admin")
  end

  it "should determine replacement elements for a investigator view child" do
    form_base_element = FormBaseElement.create(:tree_id => "1")
    investigator_view_element_container = InvestigatorViewElementContainer.create(:tree_id => "1")
    question = Question.create({:question_text => "?", :data_type => "single_line_text", :short_name => "q"})
    question_element = QuestionElement.create(:tree_id => "1", :form_id => 1, :question => question)

    form_base_element.add_child(investigator_view_element_container)
    investigator_view_element_container.add_child(question_element)

    replace_element, replace_partial = helper.replacement_elements(question_element)

    replace_element.should eql("root-element-list")
    replace_partial.should eql("forms/elements")
  end

  it "should determine replacement elements for a core view child" do
    form_base_element = FormBaseElement.create(:tree_id => "1")
    core_view_element_container = CoreViewElementContainer.create(:tree_id => "1")
    question = Question.create({:question_text => "?", :data_type => "single_line_text", :short_name => "q"})
    question_element = QuestionElement.create(:tree_id => "1", :form_id => 1, :question => question)

    form_base_element.add_child(core_view_element_container)
    core_view_element_container.add_child(question_element)

    replace_element, replace_partial = helper.replacement_elements(question_element)

    replace_element.should eql("core-element-list")
    replace_partial.should eql("forms/core_elements")
  end

  it "should determine replacement elements for a core field child" do
    form_base_element = FormBaseElement.create(:tree_id => "1")
    core_field_element_container = CoreFieldElementContainer.create(:tree_id => "1")
    question = Question.create({:question_text => "?", :data_type => "single_line_text", :short_name => "q"})
    question_element = QuestionElement.create(:tree_id => "1", :form_id => 1, :question => question)

    form_base_element.add_child(core_field_element_container)
    core_field_element_container.add_child(question_element)

    replace_element, replace_partial = helper.replacement_elements(question_element)

    replace_element.should eql("core-field-element-list")
    replace_partial.should eql("forms/core_field_elements")
  end

  it "should format date correctly" do
    helper.format_date(Time.parse('8/21/2002')).should eql('August 21, 2002')
  end

  it "should raise an Argument error when ld is passed too many args" do
    lambda do
      helper.ld(1, 2, 3, 'bzzzz')
    end.should raise_error(ArgumentError, 'wrong number of arguments: (4 for 3)')
  end

  describe "code_description_select_tag" do

    before do
      @code = Factory.create(:code)
      @codes = [@code]
    end

    it "renders a select tag w/ a name and options" do
      result = helper.code_description_select_tag(:test_select, @codes, @code.id,
                                                  :include_blank => true)
      result.should have_tag("select#test_select[name='test_select']") do |select|
        select.should have_blank_option
        select.should have_option(:text => @code.code_description,
                                  :value => @code.id,
                                  :selected => true)
      end
    end

    it "takes string option keys" do
      result = helper.code_description_select_tag(:test_select, @codes,
                                                  'include_blank' => true)
      result.should have_tag("select#test_select[name='test_select']") do |select|
        select.should have_blank_option
      end
    end

    it "supports select multiple" do
      result = helper.code_description_select_tag(:test_select, @codes,
                                                  :multiple => true)
      result.should have_tag("select#test_select[multiple=?]", 'multiple') do |select|
        select.should_not have_blank_option
      end
    end

    it "supports html options" do
      result = helper.code_description_select_tag(:test_select, @codes,
                                                  :class => 'search')
      result.should have_tag("select.search")
    end

  end

  describe "underscore_form_object_name" do
    it "should replace open brackets with underscores and remove closing brackets" do
      form_object_name = "morbidity_event[diagnostic_facilities_attributes][0][place_entity_attributes][canonical_address_attributes][street_number]"
      helper.underscore_form_object_name(form_object_name).should == "morbidity_event_diagnostic_facilities_attributes_0_place_entity_attributes_canonical_address_attributes_street_number"
    end
  end

end
