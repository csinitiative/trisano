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

=begin
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
=end

  describe "constraints" do

    it "should only allow one answer per question per event" do
      event = Factory.create(:morbidity_event)
      question = Factory.create(:question)
      original_answer = Factory.build(:answer, :question_id => question.id, :event_id => event.id)
      duplicate_answer = Factory.build(:answer, :question_id => question.id, :event_id => event.id)
      
      original_answer.save.should be_true
      duplicate_answer.save.should be_false
      duplicate_answer.errors.on(:question_id).should == "has already been taken"
    end

  end

end
