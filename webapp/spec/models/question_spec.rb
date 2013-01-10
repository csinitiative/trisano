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

describe Question do
  before(:each) do
    @question = Question.new
    @question.question_text = "Did you eat the fish?"
    @question.short_name = "fishy"
    @question.data_type = "single_line_text"
    @question.help_text = 's' * 1000
  end

  it "should be valid" do
    @question.should be_valid
  end

  it 'should produce an error if the help text is too long' do
    @question.help_text = 's' * 1001
    @question.should_not be_valid
    @question.errors.size.should == 1
    @question.errors.on(:help_text).should_not be_nil
  end

  it 'should produce an error if the question text is too long' do
    @question.question_text = 's' * 1001
    @question.should_not be_valid
    @question.errors.size.should == 1
    @question.errors.on(:question_text).should_not be_nil
  end

  it 'should produce an error if the data type is not valid' do
    @question.data_type = "not_good_pie"
    @question.should_not be_valid
    @question.errors.size.should == 1
    @question.errors.on(:data_type).should == "is invalid"
  end

  it 'should produce an error if the shortname is not present' do
    @question.short_name = ""
    @question.should_not be_valid
    @question.errors.size.should == 1
    @question.errors.on(:short_name).should == "can't be blank"
  end

  it 'should be valid with any of the valid data types' do
    Question.valid_data_types.each do |data_type|
      @question.data_type = data_type
      @question.should be_valid
    end
  end

  it "should determine if it is numeric" do
    @question.data_type = "single_line_text"
    @question.numeric?.should be_false

    @question.data_type = "multi_line_text"
    @question.numeric?.should be_false

    @question.data_type = "drop_down"
    @question.numeric?.should be_false

    @question.data_type = "radio_button"
    @question.numeric?.should be_false

    @question.data_type = "check_box"
    @question.numeric?.should be_false

    @question.data_type = "date"
    @question.numeric?.should be_false

    @question.data_type = "phone"
    @question.numeric?.should be_false

    @question.data_type = "numeric"
    @question.numeric?.should be_true
  end

  it "should determine if it is multi-valued" do
    @question.data_type = "single_line_text"
    @question.is_multi_valued?.should be_false

    @question.data_type = "multi_line_text"
    @question.is_multi_valued?.should be_false

    @question.data_type = "drop_down"
    @question.is_multi_valued?.should be_true

    @question.data_type = "radio_button"
    @question.is_multi_valued?.should be_true

    @question.data_type = "check_box"
    @question.is_multi_valued?.should be_true

    @question.data_type = "date"
    @question.is_multi_valued?.should be_false

    @question.data_type = "phone"
    @question.is_multi_valued?.should be_false

    @question.data_type = "numeric"
    @question.is_multi_valued?.should be_false
  end

  it 'numeric min cannot be greater than numeric max' do
    @question.data_type = "numeric"
    @question.numeric_min = "50"
    @question.numeric_max = "5"
    @question.save.should be_false
    @question.errors.count.should be_equal(1)
    @question.errors[:numeric_min].should == "must be less than numeric max"
  end
  it 'numeric min cannot be equal to numeric max' do
    @question.data_type = "numeric"
    @question.numeric_min = "50"
    @question.numeric_max = "50"
    @question.save.should be_false
    @question.errors.count.should be_equal(1)
    @question.errors[:numeric_min].should == "must be less than numeric max"
  end
  it "allows only minimum of the range to be set" do
    @question.data_type = "numeric"
    @question.numeric_min = "50"
    @question.save.should be_true
    @question.errors.count.should be_equal(0)
  end
  it "allows only maximum of the range to be set" do
    @question.data_type = "numeric"
    @question.numeric_max = "50"
    @question.save.should be_true
    @question.errors.count.should be_equal(0)
  end


  it 'should strip extra whitespace from short names' do
    @question.short_name = "   shorty    "
    @question.save!
    @question.short_name.should == "shorty"
  end

  it 'should convert spaces in short names to underscores' do
    @question.short_name = "i am a short name"
    @question.save!
    @question.short_name.should == "i_am_a_short_name"
  end

  describe 'when on a published form' do
    
    it 'should not allow edits to the short name' do
      @form = Form.new(:name => "Test Form", :event_type => 'morbidity_event', :short_name => 'question_spec_short')
      @form.save_and_initialize_form_elements
      @question_element = QuestionElement.new({
          :parent_element_id => @form.investigator_view_elements_container.id,
          :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
        })
      @question_element.save_and_add_to_form.should_not be_nil

      @question_to_edit = @question_element.question
      @question_to_edit.short_name = "first_short_name"
      @question_to_edit.save!
      @question_to_edit.short_name.should eql("first_short_name")
      sleep 1 # Sleep to get the publish time far enough from the question creation time to allow for time comparison precision to work
      @form.publish
      @question_to_edit.reload
      @question_to_edit.short_name = "second_short_name"
      @question_to_edit.save!
      @question_to_edit.short_name.should eql("first_short_name")
    end
  end
  
end
