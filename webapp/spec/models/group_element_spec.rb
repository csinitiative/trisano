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

describe GroupElement do

  before(:each) do
    @group_element = GroupElement.new
    @group_element.name = "ImAGroup"
  end

  it "should be valid" do
    @group_element.should be_valid
  end

  describe "deleting a group element" do
    before do
      @group_element = GroupElement.new :name => "Spec Group"
      @group_element.save_and_add_to_form.should be_true
      @question = Question.create! :question_text => 'Example?', :short_name => 'example', :data_type => 'single_line_text'
      @question_element =  QuestionElement.create! :tree_id => @group_element.tree_id, :question => @question
      @group_element.add_child @question_element
    end

    it "should delete all children" do
      @group_element.destroy_and_validate.should be_true
      QuestionElement.all(:conditions => {:id => @question_element.id}).should == []
      Question.all(:conditions => {:id => @question.id}).should == []
    end
  end

  describe "copy a group element from the library to a form" do
    before do
      # build form
      @form = Factory.build(:form)
      @form.save_and_initialize_form_elements
      @form_question = Factory.build(:question_element)
      @form_question.parent_element_id = @form.investigator_view_elements_container.children[0]
      @form_question.save_and_add_to_form
    end

    it "finds collisions in deep nested questions" do
      @group_element = library_group
      @copied_question = @form_question.add_to_library(@group_element)
      questions = @group_element.compare_short_names(@form_question)
      questions.size.should == 1
      questions[0].collision.should be_true
    end
  end
end
