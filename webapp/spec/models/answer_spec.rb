# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

describe Answer do
  
  before(:each) do 
    question = Question.new :short_name => 'short_name_01'
    @answer = Answer.new :question => question
    @answer.text_answer = 's' * 2000    
  end
  
  it "should return the short name from the question" do
    @answer.short_name.should == 'short_name_01'
  end
  
  it 'should strip out the extra blank values from a radio button submission' do
    @answer.radio_button_answer=(["Yes", ""])
    @answer.text_answer.should eql("Yes")
  end
  
  it 'should produce an error if the answer text is too long' do
    @answer.text_answer = 's' * 2001
    @answer.should_not be_valid
    @answer.errors.size.should == 1
    @answer.errors.on(:text_answer).should_not be_nil
  end

  it 'should format a date-picker style date (i.e. January 12, 1987) as a YYYY-MM-DD date' do
    @answer.question.data_type = 'date'
    @answer.text_answer = 'January 12, 1987'
    @answer.save!
    @answer.text_answer.should == '1987-01-12'
  end

  it 'should format a MM/DD/YYYY date as a YYYY-MM-DD date' do
    @answer.question.data_type = 'date'
    @answer.text_answer = '1/12/1987'
    @answer.save!
    @answer.text_answer.should == '1987-01-12'
  end

  it 'should format a MM/DD/YY date as a YYYY-MM-DD date' do
    @answer.question.data_type = 'date'
    @answer.text_answer = '01/21/09'
    @answer.save!
    @answer.text_answer.should == '2009-01-21'
  end

  it 'should format a MM-DD-YY date as a YYYY-MM-DD date' do
    @answer.question.data_type = 'date'
    @answer.text_answer = '01-21-09'
    @answer.save!
    @answer.text_answer.should == '2009-01-21'
  end

  it 'should format a MM-DD-YYYY date as a YYYY-MM-DD date' do
    @answer.question.data_type = 'date'
    @answer.text_answer = '01-21-2009'
    @answer.save!
    @answer.text_answer.should == '2009-01-21'
  end

  describe 'when saving an answer to a multi-valued question' do

    before(:each) do
      @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'answer_1')
      @form.save_and_initialize_form_elements
      @question_element = QuestionElement.new({
          :parent_element_id => @form.investigator_view_elements_container.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
        })

      @question_element.save_and_add_to_form.should_not be_nil
      @question = @question_element.question
      @value_set_element = ValueSetElement.create({ :tree_id => @question_element.tree_id, :form_id => @question_element.form_id, :name => "Coded Yes/No" })
      @yes_value_element = ValueSetElement.create({  :tree_id => @question_element.tree_id, :form_id => @question_element.form_id,:name => "Yes", :code => "1" })
      @no_value_element = ValueSetElement.create({  :tree_id => @question_element.tree_id, :form_id => @question_element.form_id, :name => "No", :code => "2" })

      @question_element.add_child(@value_set_element)
      @value_set_element.add_child(@yes_value_element)
      @value_set_element.add_child(@no_value_element)

      @answer = Answer.new :question => @question
    end

    it 'should set the code on the answer for a radio button' do
      @question.data_type = "radio_button"
      @question.save!
      @answer.text_answer = "Yes"
      @answer.save!
      @answer.code.should eql("1")

      @answer.text_answer = "No"
      @answer.save!
      @answer.code.should eql("2")
    end

    it 'should set the code on the answer for a drop down select' do
      @question.data_type = "drop_down"
      @question.save!
      @answer.text_answer = "Yes"
      @answer.save!
      @answer.code.should eql("1")

      @answer.text_answer = "No"
      @answer.save!
      @answer.code.should eql("2")
    end

    it 'should set the code on the answer for a check box' do
      @question.data_type = "check_box"
      @question.save!
      @answer.text_answer = "Yes"
      @answer.save!
      @answer.code.should eql("1")

      @answer.text_answer = "No"
      @answer.save!
      @answer.code.should eql("2")
    end

    it 'should set multiple codes on the answer for a check box with multiple selections' do
      @question.data_type = "check_box"
      @question.save!
      @answer.text_answer = "Yes\nNo\n"
      @answer.save!
      @answer.code.should eql("1\n2")
    end

    it 'should not set the code on the answer for a single line text input' do
      @question.data_type = "single_line_text"
      @question.save!
      @answer.text_answer = "Yes"
      @answer.save!
      @answer.code.should be_nil
    end

    it 'should not set the code on the answer for a multi line text input' do
      @question.data_type = "multi_line_text"
      @question.save!
      @answer.text_answer = "Yes"
      @answer.save!
      @answer.code.should be_nil
    end

    it 'should not set the code on the answer for a date' do
      @question.data_type = "date"
      @question.save!
      @answer.text_answer = "01/21/09"
      @answer.save!
      @answer.code.should be_nil
    end

    it 'should not set the code on the answer for a phone input' do
      @question.data_type = "phone"
      @question.save!
      @answer.text_answer = "503-555-5555"
      @answer.save!
      @answer.code.should be_nil
    end

    it 'should not set the code on the answer if the question is a CDC question' do
      @question_element.export_column_id = 1
      @question_element.save!
      @answer.text_answer = "Yes"
      @answer.save!
      @answer.code.should be_nil
    end

  end

end
