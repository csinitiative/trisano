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
  fixtures :users, :places, :places_types, :entities, :codes

  before(:each) do
    @user = users(:default_user)
    User.stub!(:current_user).and_return(@user)

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

  it "should not be valid if there's no OBX segment" do
    m = StagedMessage.new(:hl7_message => hl7_messages[:no_last_name])
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
      StagedMessage.states.should == {:pending => 'PENDING', :assigned => 'ASSIGNED', :discarded => 'DISCARDED'}
    end
  end

  describe "assigning to an event" do

    before :each do
      @staged_message = StagedMessage.create(:hl7_message => hl7_messages[:arup_1])
    end

    it "should default to a state of 'PENDING'" do
      @staged_message.state.should == StagedMessage.states[:pending]
    end

    it "should raise an error if not given an event" do
      lambda{@staged_message.assigned_event="noise"}.should raise_error(ArgumentError)
    end

    it "should raise an error if message has already been assigned" do
      @staged_message.state = StagedMessage.states[:assigned]
      lambda{@staged_message.assigned_event=MorbidityEvent.new}.should raise_error(RuntimeError)
    end

    it 'should create a lab result and link to it' do
      m = MorbidityEvent.new( "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Biel" } } } )
      @staged_message.assigned_event = m
      m.labs[0].lab_results.size.should == 1
      @staged_message.lab_results.size.should == 1
      @staged_message.lab_results[0].should eql(m.labs[0].lab_results[0])
    end

    it "should mark the staged message 'ASSIGNED'" do
      m = MorbidityEvent.new( "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Biel" } } } )
      @staged_message.assigned_event = m
      @staged_message.state.should == StagedMessage.states[:assigned]
    end

    it "should return the assigned event." do
      m = MorbidityEvent.new( "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Biel" } } } )
      @staged_message.assigned_event = m
      m.labs.size.should == 1
      @staged_message.assigned_event.should eql(m)
    end

  end

  describe "instantiating an event based on message" do

    describe "with a valid, complete record" do
      before :each do
        @staged_message = StagedMessage.new(:hl7_message => hl7_messages[:arup_1])
        @event = @staged_message.new_event_from
      end

      it "should return a valid, unsaved morbidity event" do
        @event.class.should == MorbidityEvent
        @event.should be_valid
        @event.should be_new_record
      end

      it "should populate the event" do
        p = @event.interested_party.person_entity.person
        p.last_name.should == @staged_message.patient.patient_last_name
        p.first_name.should == @staged_message.patient.patient_first_name
        p.middle_name.should == @staged_message.patient.patient_middle_name
        p.birth_date.should == @staged_message.patient.birth_date
        p.birth_gender_id.should == @staged_message.patient.trisano_sex_id

        a = @event.address
        a.street_number.should == @staged_message.patient.address_street_no
        a.unit_number.should == @staged_message.patient.address_unit_no
        a.street_name.should == @staged_message.patient.address_street
        a.city.should == @staged_message.patient.address_city
        a.state_id.should == @staged_message.patient.address_trisano_state_id
        a.postal_code.should == @staged_message.patient.address_zip

        t = @event.interested_party.person_entity.telephones.first
        area_code, number, extension = @staged_message.patient.telephone_home
        t.area_code.should == area_code
        t.phone_number.should == number
        t.extension.should == extension
        t.entity_location_type_id.should == ExternalCode.find_by_code_name_and_the_code('telephonelocationtype', 'HT').id

        @event.primary_jurisdiction.name.should == "Unassigned"
      end
    end

    describe "with a record missing address and phone" do
      before :each do
        @staged_message = StagedMessage.new(:hl7_message => hl7_messages[:arup_simple_pid])
        @event = @staged_message.new_event_from
      end

      it "should not instantiate an address" do
        @event.address.should be_nil
      end

      it "should not instantiate a phone" do
        @event.interested_party.person_entity.telephones.should be_empty
      end
    end
  end

  describe "discarding a message" do
#    raise "Message is already assigned to an event." if self.state == self.class.states[:assigned]
#    self.state = self.class.states[:discarded]
#    self.save!

    before :each do
      @staged_message = StagedMessage.new(:hl7_message => hl7_messages[:arup_1])
    end

    it "should raise an error if message has already been assigned" do
      @staged_message.state = StagedMessage.states[:assigned]
      lambda{@staged_message.discard}.should raise_error(RuntimeError)
    end

    it 'should set state to discarded and save message' do
      @staged_message.discard
      @staged_message.state.should == StagedMessage.states[:discarded]
      @staged_message.should_not be_new_record
    end
  end
end

