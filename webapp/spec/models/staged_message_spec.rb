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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../features/support/hl7_messages.rb')

describe StagedMessage do
  before(:each) do
    @valid_attributes = {
      :hl7_message => hl7_messages[:arup_1]
    }
  end

  it "should create a new instance given valid attributes" do
    m = StagedMessage.new(@valid_attributes)
    m.should be_valid
  end

  it "should not be valid if there's no HL7 message" do
    m = StagedMessage.new
    m.should_not be_valid
  end

  it "should not be valid if there's no MSH segment" do
    m = StagedMessage.new(:hl7_message => hl7_messages[:no_msh])
    m.should_not be_valid
  end

  it "should not be valid if there's no PID segment" do
    m = StagedMessage.new(:hl7_message => hl7_messages[:no_pid])
    m.should_not be_valid
  end

  it "should not be valid if there's no OBR segment" do
    m = StagedMessage.new(:hl7_message => hl7_messages[:no_obr])
    m.should_not be_valid
  end

  it "should not be valid if there's no OBX segment" do
    m = StagedMessage.new(:hl7_message => hl7_messages[:no_obx])
    m.should_not be_valid
  end

  it 'should respond to hl7' do
    StagedMessage.new(@valid_attributes).respond_to?(:hl7).should be_true
  end

  it 'should set message state to PENDING for new messages' do
    StagedMessage.create!(@valid_attributes).state.should == 'PENDING'
  end

  describe 'received HL7 2.3 +' do
    
    before :each do
      @staged_message = StagedMessage.new(:hl7_message => hl7_messages[:arup_1])
    end

    it 'should return the MSH segement' do
      @staged_message.message_header.class.should == StagedMessages::MshWrapper
    end

  end

  describe 'HL7 2.5 not already handled by HL7 2.3' do
    # nothing here at the moment
  end

  describe 'with invalid HL7' do

    it 'should contain a message header' do
      @staged_message = StagedMessage.new(:hl7_message => 'junk')
      @staged_message.should_not be_valid
      @staged_message.errors.on(:hl7_message).should be_true
    end

  end

  describe "class level functionality" do

    it 'should provide a hash of valid states' do
      StagedMessage.states.should == {:pending => 'PENDING', :assigned => 'ASSIGNED'}
    end 
  end

  describe "assigning to an event" do

    before :each do
      @staged_message = StagedMessage.new(:hl7_message => hl7_messages[:arup_1])
    end

    it "should raise an error if not given an event" do
      lambda{@staged_message.assigned_event="noise"}.should raise_error(ArgumentError)
    end

    it "should raise an error if message has already been assigned" do
      @staged_message.state = StagedMessage.states[:assigned]
      lambda{@staged_message.assigned_event=MorbidityEvent.new}.should raise_error(RuntimeError)
    end

    it "should link the message to the event" do
      m = MorbidityEvent.new( "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Biel" } } } )
      @staged_message.assigned_event = m
      m.labs.size.should == 1
      @staged_message.assigned_event.should eql(m)
      @staged_message.state.should == StagedMessage.states[:assigned]
    end
  end
end

