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

  it 'should move date_answer errors to text_answer' do
    @answer.question.data_type = 'date'
    @answer.text_answer = '111123412341234'
    @answer.valid?
    @answer.errors.on('date_answer').should be_nil
    @answer.errors.on('text_answer').should_not be_nil
  end

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

    describe 'of numeric question' do
      before do
        @answer.question.update_attribute(:data_type, "numeric")  
      end

      it "allows blanks" do
        @answer.text_answer = ""
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end

      it "allows decimal points in the begining" do
        @answer.text_answer = ".12"
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end
      it "allows decimal points in the middle" do
        @answer.text_answer = "1.2"
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end
      it "allows decimal points at the end" do
        @answer.text_answer = "12."
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end
        
      it "does not allow commas" do
        @answer.text_answer = "1,200"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "accepts only positive or negative integers (0-9) and one optional decimal point"
      end
        

      it "does not allow alpha characters in the middle" do
        @answer.text_answer = "1d2"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "accepts only positive or negative integers (0-9) and one optional decimal point"
      end
      it "does not allow alpha characters at the begining" do
        @answer.text_answer = "d12"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "accepts only positive or negative integers (0-9) and one optional decimal point"
      end
      it "does not allow alpha characters at the end" do
        @answer.text_answer = "12d"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "accepts only positive or negative integers (0-9) and one optional decimal point"
      end




      it "does not allow special characters at the end" do
        @answer.text_answer = "12!"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "accepts only positive or negative integers (0-9) and one optional decimal point"
      end
      it "does not allow special characters at the middle" do
        @answer.text_answer = "1!2"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "accepts only positive or negative integers (0-9) and one optional decimal point"
      end
      it "does not allow special characters at the begining" do
        @answer.text_answer = "!12"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "accepts only positive or negative integers (0-9) and one optional decimal point"
      end


      it "allows negative numbers" do
        @answer.text_answer = "-4.1"
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end
      it "allows negative numbers" do
        @answer.text_answer = "-4"
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end
      it "doesn't allow negative signs anywhere but the begining" do
        @answer.text_answer = "4-"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "accepts only positive or negative integers (0-9) and one optional decimal point"
      end
      it "doesn't allow negative signs anywhere but the begining" do
        @answer.text_answer = "4-.0"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "accepts only positive or negative integers (0-9) and one optional decimal point"
      end
      it "doesn't allow negative signs anywhere but the begining" do
        @answer.text_answer = "4.0-"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "accepts only positive or negative integers (0-9) and one optional decimal point"
      end



      it "honors numeric_min when set with a integer" do
        @answer.question.update_attribute(:numeric_min, "3")
        @answer.text_answer = "2"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "is below minimum value of 3 for the question ''"
      end
      it "honors numeric_min when set with a integer" do
        @answer.question.update_attribute(:numeric_min, "3")
        @answer.text_answer = ".2"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "is below minimum value of 3 for the question ''"
      end
      it "honors numeric_min when set with a float" do
        @answer.question.update_attribute(:numeric_min, "3.1")
        @answer.text_answer = "2"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "is below minimum value of 3.1 for the question ''"
      end
      it "honors numeric_min when answer is set with a float" do
        @answer.question.update_attribute(:numeric_min, "3.1")
        @answer.text_answer = "2.1"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "is below minimum value of 3.1 for the question ''"
      end
      it "honors numeric_min when set with an equal value" do
        @answer.question.update_attribute(:numeric_min, "3.1")
        @answer.text_answer = "3.1"
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end
      it "honors numeric_min when set with an equal value" do
        @answer.question.update_attribute(:numeric_min, "3")
        @answer.text_answer = "3"
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end

      it "works with negative numbers" do
        @answer.question.update_attribute(:numeric_min, "-500")
        @answer.question.update_attribute(:numeric_max, "1000")
        @answer.text_answer = "-400"
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end


      it "honors numeric_max when set with a integer" do
        @answer.question.update_attribute(:numeric_max, "3")
        @answer.text_answer = "4."
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "is above maximum value of 3 for the question ''"
      end
      it "honors numeric_max when set with a integer" do
        @answer.question.update_attribute(:numeric_max, "3")
        @answer.text_answer = "4.1"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "is above maximum value of 3 for the question ''"
      end
      it "honors numeric_max when set with a float" do
        @answer.question.update_attribute(:numeric_max, "3.1")
        @answer.text_answer = "4"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "is above maximum value of 3.1 for the question ''"
      end
      it "honors numeric_max when answer is set with a float" do
        @answer.question.update_attribute(:numeric_max, "3.1")
        @answer.text_answer = "4.1"
        @answer.save.should be_false
        @answer.errors.count.should be_equal(1)
        @answer.errors[:text_answer].to_s.should == "is above maximum value of 3.1 for the question ''"
      end
      it "honors numeric_max when set with an equal value" do
        @answer.question.update_attribute(:numeric_max, "3.1")
        @answer.text_answer = "3.1"
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end
      it "honors numeric_max when set with an equal value" do
        @answer.question.update_attribute(:numeric_max, "3")
        @answer.text_answer = "3"
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end



      it "allows blanks when a maximum is set" do
        @answer.question.update_attribute(:numeric_max, "-3")
        @answer.text_answer = ""
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end
      it "allows blanks when a minimum is set" do
        @answer.question.update_attribute(:numeric_min, "3")
        @answer.text_answer = ""
        @answer.save.should be_true
        @answer.errors.count.should be_equal(0)
      end
    end


  end

end
