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

describe ValueElement do
  before(:each) do
    @value_element = ValueElement.new
  end

  it "should be valid" do
    @value_element.should be_valid
  end

  describe "with a blank value" do
    before do
      @value_element = Factory.build(:value_element)
      @question = Factory.build(:question)
      @value_element.question = @question
    end

    it "is invalid if question type is radio button" do
      @question.data_type = :radio_button
      @value_element.should_not be_valid
      @value_element.errors.on(:name).should == "can't be blank when question is a radio button"
    end

    it "is invalid if question type is checkboxes" do
      @question.data_type = :check_box
      @value_element.should_not be_valid
      @value_element.errors.on(:name).should == "can't be blank when question is a check box"
    end

    it "is valid if question type is drop down" do
      @question.data_type = :drop_down
      @value_element.should be_valid
    end
  end

  describe "getting a question from the database" do
    # this is a lot of crap to set up a test :)
    before do
      @form = Factory.build(:form)
      @form.save_and_initialize_form_elements
      @question_element = Factory.build(:question_element)
      @question_element.question.data_type = 'drop_down'
      @question_element.question.save!
      @question_element.parent_element_id = @form.form_base_element.id
      @question_element.save_and_add_to_form
      @value_set_element = Factory.build(:value_set_element)
      @value_set_element.parent_element_id = @question_element.id
      @value_set_element.save_and_add_to_form
      @value_element = Factory.build(:value_element)
      @value_element.parent_element_id = @value_set_element.id
    end

    it "finds the question by walking up the parents (sorta)" do
      @value_element.question.should == @question_element.question
    end

  end
end
