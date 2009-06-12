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

  it 'should respond to :message_header' do
    @hl7.respond_to?(:message_header).should be_true
  end

  it 'should respond to :patient_id' do
    @hl7.respond_to?(:patient_id).should be_true
  end

  it 'should respond to :observation_request' do
    @hl7.respond_to?(:observation_request).should be_true
  end

  it 'should return a message_header' do
    @hl7.message_header.class == StagedMessages::MshWrapper
  end

  it 'should return a patient ID' do
    @hl7.patient_id.class == StagedMessages::PidWrapper
  end

  it 'should return an observation request' do
    @hl7.observation_request.class == StagedMessages::ObrWrapper
  end

  describe 'message header' do
    it 'should respond_to :sending_facility' do
      @hl7.message_header.respond_to?(:sending_facility).should be_true
    end

    it 'should return the sending facility (without noise)' do
      @hl7.message_header.sending_facility.should == 'ARUP LABORATORIES'
    end
  end

  describe 'patient identifier' do
    it 'should respond_to :patient_name' do
      @hl7.patient_id.respond_to?(:patient_name).should be_true
    end

    it 'should return the patient name (formatted)' do
      @hl7.patient_id.patient_name.should == 'LIN, GENYAO'
    end
 end

  describe 'observation request' do
    it 'should respond_to :test_performed' do
      @hl7.observation_request.respond_to?(:test_performed).should be_true
    end

    it 'should return the test performed (without noise)' do
      @hl7.observation_request.test_performed.should == 'Hepatitis Be Antigen'
    end

    it 'should respond_to :colection_date' do
      @hl7.observation_request.respond_to?(:collection_date).should be_true
    end

    it 'should return the colection date' do
      @hl7.observation_request.collection_date.should == '2009-03-19'
    end

    it 'should respond_to :specimen_source' do
      @hl7.observation_request.respond_to?(:specimen_source).should be_true
    end

    it 'should return the specimen source' do
      @hl7.observation_request.specimen_source.should == 'X'
    end

    it 'should respond_to :tests' do
      @hl7.observation_request.respond_to?(:tests).should be_true
    end

    it 'should return a list of test_results' do
      @hl7.observation_request.tests.should_not be_nil
    end

    describe 'tests' do
      before :each do
        @tests = @hl7.observation_request.tests
      end

      it 'should be a list' do
        @tests.respond_to?(:each).should be_true
      end

      it 'should not be an empty list' do
        @tests.should_not be_empty
      end

      it 'should respond to :observation_date' do
        @tests[0].respond_to?(:observation_date).should be_true
      end

      it 'should return observation_date' do
        @tests[0].observation_date.should == '2009-03-21'
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

      it 'should respond to :test_type' do
        @tests[0].respond_to?(:test_type).should be_true
      end

      it 'should return the test type (without the noise)' do
        @tests[0].test_type.should == 'Hepatitis Be Antigen'
      end
    end
  end
end
