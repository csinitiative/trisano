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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../../features/support/hl7_messages.rb')

include HL7

describe Message do
  before :each do
    @hl7 = HL7::Message.parse(hl7_messages[:arup_1])
  end

  it 'should respond to :orders' do
    @hl7.respond_to?(:orders).should be_true
  end

  it 'should return a list of orders' do
    @hl7.orders.respond_to?(:each).should be_true    
  end

  it 'should return orders from the message' do
    @hl7.orders[0].should_not be_nil
  end

  describe 'orders' do
    it 'should respond_to :lab' do
      @hl7.orders[0].respond_to?(:lab).should be_true
    end

    it 'should return the lab' do
      @hl7.orders[0].lab.should == '13954-3 Hepatitis Be Antigen LN'
    end

    it 'should respond_to :lab_test_date' do
      @hl7.orders[0].respond_to?(:lab_test_date).should be_true
    end

    it 'should return the lab_test_date' do
      @hl7.orders[0].lab_test_date.should == '200903191011'
    end

    it 'should respond_to :specimen_source' do
      @hl7.orders[0].respond_to?(:specimen_source).should be_true
    end

    it 'should return the specimen source' do
      @hl7.orders[0].specimen_source.should == 'X'
    end

    it 'should respond to :collection_date' do
      @hl7.orders[0].respond_to?(:collection_date).should == true
    end

    it 'should return the collection date' do
      @hl7.orders[0].collection_date.should == '200903191011'
    end

    it 'should respond_to :tests' do
      @hl7.orders[0].respond_to?(:tests).should be_true
    end

    it 'should return a list of test_results' do
      @hl7.orders[0].tests.should_not be_nil
    end

    describe 'tests' do
      before :each do
        @tests = @hl7.orders[0].tests
      end

      it 'should be a list' do
        @tests.respond_to?(:each).should be_true
      end

      it 'should not be an empty list' do
        @tests.should_not be_empty
      end

      it 'should respond to :result' do
        @tests[0].respond_to?(:result).should be_true
      end

      it 'should return result' do
        @tests[0].result.should == 'Positive'
      end

      it 'should respond to :reference_range' do
        @tests[0].respond_to?(:reference_range).should be_true
      end

      it 'should return a reference range' do
        @tests[0].reference_range.should == 'Negative'
      end

      it 'should respond to :test_result' do
        @tests[0].respond_to?(:test_type).should be_true
      end

      it 'should return the test type' do
        @tests[0].test_type.should == '13954-3^Hepatitis Be Antigen^LN'
      end

    end
  end
end

  
