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

require 'trisano'
require 'spec_helper'
require 'active_support'

describe StagedMessage do

  before(:all) do
   destroy_fixture_data
  end

  after(:all) do
    Fixtures.reset_cache
  end

  before(:each) do
    @user = users(:default_user)
    User.stubs(:current_user).returns(@user)
    @valid_attributes = {
      :hl7_message => unique_message(hl7_messages[:arup_1])
    }
  end

  fixtures :users

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

  it "should not be valid if there is the same MSH:message_control_id present in the database" do
    StagedMessage.create(:hl7_message => hl7_messages[:arup_1])
    m = StagedMessage.new(:hl7_message => hl7_messages[:arup_1])

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

  it "should not be valid if there's no last name" do
    m = StagedMessage.new(:hl7_message => hl7_messages[:no_last_name])
    m.should_not be_valid
    m.errors.on(:hl7_message).should == 'No last name provided for patient.'
  end

  it "should not be valid if there's no no loinc code" do
    m = StagedMessage.new(:hl7_message => hl7_messages[:no_loinc_code])
    m.should_not be_valid
    m.errors.on(:hl7_message).should =~ /^OBX segment \d+ does not contain a LOINC code.$/
  end

  it 'should respond to hl7' do
    StagedMessage.new(@valid_attributes).respond_to?(:hl7).should be_true
  end

  it 'should respond to :ack' do
    StagedMessage.new(@valid_attributes).respond_to?(:ack).should be_true
  end

  it 'should set message state to PENDING for new messages' do
    StagedMessage.create!(@valid_attributes).state.should == 'PENDING'
  end

  it 'should use OBX-23 for lab name if present' do
    staged_message = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_campylobacter_jejuni]
    first_obx = staged_message.observation_requests.first.all_tests.first.obx_segment
    staged_message.lab_name.should == first_obx.performing_organization_name.split(first_obx.item_delim).first
  end

  it 'should use MSH-4 for lab name if OBX-23 is not present' do
    staged_message = StagedMessage.new :hl7_message => HL7MESSAGES[:arup_1]
    staged_message.observation_requests.first.all_tests.should_not be_empty
    staged_message.lab_name.should == staged_message.message_header.sending_facility
  end

  it 'should not fail if the first OBR segment does not have tests' do
    msg = <<ARUP1
MSH|^~\&|ARUP|ARUP LABORATORIES^46D0523979^CLIA|UTDOH|UT|200903261645||ORU^R01|200903261645128667|P|2.3.1|1\rPID|1||17744418^^^^MR||ZHANG^GEORGE^^^^^L||19830922|M||U^Unknown^HL70005|42 HAPPY LN^^SALT LAKE CITY^UT^84444^^M||^^PH^^^801^5552346|||||||||U^Unknown^HL70189\rORC||||||||||||^FARNSWORTH^MABEL^W|||||||||University Hospital UT|50 North Medical Drive^^Salt Lake City^UT^84132^USA^B||^^^^^USA^B\rOBR|1||09078102377|13954-3^Hepatitis Be Antigen^LN|||200903191011|||||||200903191011|BLOOD|^FARNSWORTH^MABEL^W||||||200903191011|||F||||||9^Unknown\r
ARUP1
    staged_message = StagedMessage.new :hl7_message => msg
    staged_message.observation_requests.first.all_tests.should be_empty
    staged_message.lab_name.should == staged_message.message_header.sending_facility
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

  describe 'the ACK^R01^ACK message' do
    before :all do
      @good_message = StagedMessage.new(:hl7_message => HL7MESSAGES[:realm_minimal_message])
      @bad_message  = StagedMessage.new(:hl7_message => HL7MESSAGES[:no_loinc_code])

      # Make sure to validate these messages before calling #ack.
      @good_message.should be_valid
      @bad_message.should_not be_valid

      # Work around a quirk in the ruby-hl7 gem:  The message built by
      # #ack will return nil for [:MSA] below.  But first converting
      # to HL7 and parsing back into an object removes this problem.
      @good_message_ack = HL7::Message.parse @good_message.ack.to_hl7
      @bad_message_ack  = HL7::Message.parse @bad_message.ack.to_hl7

      @good_message_ack_header = @good_message_ack.message_header.msh_segment
      @bad_message_ack_header = @bad_message_ack.message_header.msh_segment
    end

    it 'should have an MSH segment' do
      @good_message_ack_header.should_not be_nil
      @bad_message_ack_header.should_not be_nil
    end

    it 'should have an MSA segment' do
      @good_message_ack[:MSA].should_not be_nil
      @bad_message_ack[:MSA].should_not be_nil
    end

    it 'should return a success code on success' do
      @good_message_ack[:MSA].ack_code.should == 'CA'
    end

    it 'should return an error code on failure' do
      @bad_message_ack[:MSA].ack_code.should == 'AE'
    end

    it 'should return the configured recv_facility' do
      @good_message_ack_header.sending_facility.should ==
        StagedMessage.recv_facility
      @bad_message_ack_header.sending_facility.should ==
        StagedMessage.recv_facility
    end

    it 'should return the inbound processing_id' do
      @good_message_ack_header.processing_id.should ==
        @good_message.message_header.msh_segment.processing_id
      @bad_message_ack_header.processing_id.should ==
        @bad_message.message_header.msh_segment.processing_id
    end

    it 'should not have MSH-15 or MSH-16 fields' do
      @good_message_ack_header.accept_ack_type.should be_nil
      @good_message_ack_header.app_ack_type.should be_nil
      @bad_message_ack_header.accept_ack_type.should be_nil
      @bad_message_ack_header.app_ack_type.should be_nil
    end

    it 'should not have an MSH-21 field' do
      @good_message_ack_header.message_profile_identifier.should be_nil
      @bad_message_ack_header.message_profile_identifier.should be_nil
    end

    it 'should return the inbound sending app and facility' do
      @good_message_ack_header.recv_app.should ==
        @good_message.message_header.msh_segment.sending_app
      @bad_message_ack_header.recv_app.should ==
        @bad_message.message_header.msh_segment.sending_app
      @good_message_ack_header.recv_facility.should ==
        @good_message.message_header.msh_segment.sending_facility
      @bad_message_ack_header.recv_facility.should ==
        @bad_message.message_header.msh_segment.sending_facility
    end


    it 'should contain the TriSano OID in the MSH segment' do
      @good_message_ack_header.sending_app.should ==
        Trisano.application.oid.join(@good_message.message_header.msh_segment.item_delim)
      @bad_message_ack_header.sending_app.should ==
        Trisano.application.oid.join(@bad_message.message_header.msh_segment.item_delim)
    end

    it 'should contain an SFT segment' do
      @good_message_ack[:SFT].should_not be_nil
      @bad_message_ack[:SFT].should_not be_nil
    end

    it 'should contain the TriSano version number in the SFT segment' do
      # ahem
      @good_message_ack[:SFT].software_certified_version_or_release_number.should ==
        Trisano.application.version_number
      @bad_message_ack[:SFT].software_certified_version_or_release_number.should ==
        Trisano.application.version_number
    end

    it 'should not have an ERR segment in case of success' do
      @good_message_ack[:ERR].should be_nil
    end

    it 'should contain the TriSano bug-report address in the ERR segment' do
      @bad_message_ack[:ERR].should_not be_nil
      @bad_message_ack[:ERR].help_desk_contact_point.split(@bad_message_ack[:ERR].item_delim).third.should ==
          Trisano.application.bug_report_address
    end

    it 'should have the expected OID' do
      Trisano.application.oid.should == expected_oid
    end

    it 'should have the expected bug report address' do
      Trisano.application.bug_report_address.should == expected_bug_report_address
    end

    it 'should reject a message with an invalid processing ID' do
      sample = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_bad_processing_id]
      sample.should_not be_valid
      sample_ack = HL7::Message.parse sample.ack.to_hl7

      msa = sample_ack[:MSA]
      msa.ack_code.should == 'AR'

      err = sample_ack[:ERR]
      err.error_location.should == 'MSH^1^11'
      err.hl7_error_code.split(err.item_delim).first.should == '202'
      err.severity.should == 'E'
    end

    it 'should reject a message with an invalid version ID' do
      sample = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_bad_version_id]
      sample.should_not be_valid
      sample_ack = HL7::Message.parse sample.ack.to_hl7

      msa = sample_ack[:MSA]
      msa.ack_code.should == 'AR'

      err = sample_ack[:ERR]
      err.error_location.should == 'MSH^1^12'
      err.hl7_error_code.split(err.item_delim).first.should == '203'
      err.severity.should == 'E'
    end

    it 'should reject a message with an invalid message type' do
      sample = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_bad_message_type]
      sample.should_not be_valid
      sample_ack = HL7::Message.parse sample.ack.to_hl7

      msa = sample_ack[:MSA]
      msa.ack_code.should == 'AR'

      err = sample_ack[:ERR]
      err.error_location.should == 'MSH^1^9'
      err.hl7_error_code.split(err.item_delim).first.should == '200'
      err.severity.should == 'E'
    end

    it 'should use the original processing rules when no MSH-15 or 16 field is present' do
      sample = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_sample_5]
      sample.should be_valid
      sample_ack = HL7::Message.parse sample.ack.to_hl7

      msa = sample_ack[:MSA]
      msa.ack_code.should == 'AA'

      sample = StagedMessage.new :hl7_message => HL7MESSAGES[:no_last_name]
      sample.should_not be_valid
      sample_ack = HL7::Message.parse sample.ack.to_hl7

      msa = sample_ack[:MSA]
      msa.ack_code.should == 'AE'

      sample = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_bad_message_type]
      sample.should_not be_valid
      sample_ack = HL7::Message.parse sample.ack.to_hl7

      msa = sample_ack[:MSA]
      msa.ack_code.should == 'AR'
    end

    it 'should use the enhanced processing rules when MSH-15 or 16 so indicates' do
      sample = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_campylobacter_jejuni]
      sample.should be_valid
      sample_ack = HL7::Message.parse sample.ack.to_hl7

      msa = sample_ack[:MSA]
      msa.ack_code.should == 'CA'

      # message with no last name
      sample = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_animal_rabies]
      sample.should_not be_valid
      sample_ack = HL7::Message.parse sample.ack.to_hl7

      msa = sample_ack[:MSA]
      msa.ack_code.should == 'CE'

      sample = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_bad_version_id]
      sample.should_not be_valid
      sample_ack = HL7::Message.parse sample.ack.to_hl7

      msa = sample_ack[:MSA]
      msa.ack_code.should == 'CR'
    end
  end

  describe 'with NIST samples' do
    before :all do
      @nist_sample_1 = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_sample_1]
      @nist_sample_2 = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_sample_2]
      @nist_sample_3 = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_sample_3]
      @nist_sample_4 = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_sample_4]
      @nist_sample_5 = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_sample_5]
      @nist_sample_6 = StagedMessage.new :hl7_message => HL7MESSAGES[:nist_sample_6]
    end

    it 'should validate all NIST samples' do
      @nist_sample_1.should be_valid
      @nist_sample_2.should be_valid
      @nist_sample_3.should be_valid
      @nist_sample_4.should be_valid
      @nist_sample_5.should be_valid
      @nist_sample_6.should be_valid
    end
  end

  describe 'with invalid HL7' do

    it 'should contain a message header' do
      @staged_message = StagedMessage.new(:hl7_message => 'junk')
      @staged_message.should_not be_valid
      @staged_message.errors.on(:hl7_message).should == 'is missing the header'
    end

  end

  describe "class level functionality" do

    it 'should provide a hash of valid states' do
      StagedMessage.states.should == {:pending => 'PENDING', :assigned => 'ASSIGNED', :discarded => 'DISCARDED', :unprocessable => 'UNPROCESSABLE'}
    end
  end

  describe "assigning to an event" do
    fixtures :loinc_codes, :common_test_types

    before :each do
      create_unassigned_jurisdiction_entity
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

    it "should raise an error if LOINC code does not exist" do
      @staged_message = StagedMessage.create(:hl7_message => unique_message(hl7_messages[:unknown_loinc]))
      lambda{@staged_message.assigned_event=MorbidityEvent.new}.should raise_error(StagedMessage::UnknownLoincCode)
    end

    it 'should create labs for encounter events' do
      e = @staged_message.new_event_from({:event_type => "encounter_event"})
      e.save!
      @staged_message.assigned_event = e
      e.labs[0].lab_results.size.should == 1
      @staged_message.lab_results.size.should == 1
      @staged_message.lab_results[0].should eql(e.labs[0].lab_results[0])
    end


    it 'should create a lab result and link to it' do
      m = MorbidityEvent.new("first_reported_PH_date" => Date.yesterday.to_s(:db), "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Biel" } } } )
      @staged_message.assigned_event = m
      m.labs[0].lab_results.size.should == 1
      @staged_message.lab_results.size.should == 1
      @staged_message.lab_results[0].should eql(m.labs[0].lab_results[0])
    end

    it "should mark the staged message 'ASSIGNED'" do
      m = MorbidityEvent.new("first_reported_PH_date" => Date.yesterday.to_s(:db), "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Biel" } } } )
      @staged_message.assigned_event = m
      @staged_message.state.should == StagedMessage.states[:assigned]
    end

    it "should return the assigned event." do
      m = MorbidityEvent.new("first_reported_PH_date" => Date.yesterday.to_s(:db), "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Biel" } } } )
      @staged_message.assigned_event = m
      m.labs.size.should == 1
      @staged_message.assigned_event.should eql(m)
    end

  end

  describe "instantiating an event based on message" do

    before(:each) do
      create_unassigned_jurisdiction_entity
    end

    describe "with a valid, complete record" do
      before :each do
        @staged_message = StagedMessage.create(:hl7_message => unique_message(hl7_messages[:arup_1]))
        @event = @staged_message.new_event_from
      end

      it "should return a valid, unsaved morbidity event" do
        @event.class.should == MorbidityEvent
        @event.should be_valid
        @event.should be_new_record
      end

      it "should return a valid encounter event" do
        @event = @staged_message.new_event_from({:event_type => "encounter_event"})
        @event.class.should == EncounterEvent
        @event.should be_valid
        @event.should be_new_record
        @event.parent_event.class.should == MorbidityEvent
      end
      
      it "should parse MSH-6 and assign as first reported date" do
        @event.first_reported_PH_date.should == Time.parse("200903261645")
      end

      it "should populate the event" do
        @event.first_reported_PH_date.should == @staged_message.message_header.time

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

        @event.jurisdiction.name.should == "Unassigned"
      end

      it "should not fail if address is not set" do
        msg =  <<ARUP1
MSH|^~\&|ARUP|ARUP LABORATORIES^46D0523979^CLIA|UTDOH|UT|200903261645||ORU^R01|200903261645128667|P|2.3.1|1\rPID|1||17744418^^^^MR||ZHANG^GEORGE^^^^^L||19560711000000|F \rORC||||||||||||^FARNSWORTH^MABEL^W|||||||||University Hospital UT|50 North Medical Drive^^Salt Lake City^UT^84132^USA^B||^^^^^USA^B\rOBR|1||09078102377|13954-3^Hepatitis Be Antigen^LN|||200903191011|||||||200903191011|BLOOD|^FARNSWORTH^MABEL^W||||||200903191011|||F||||||9^Unknown\rOBX|1|ST|13954-3^Hepatitis Be Antigen^LN|1|Positive|Metric Ton|Negative||||F|||200903210007\r
ARUP1
        @staged_message = StagedMessage.new(:hl7_message => msg)
        @event = @staged_message.new_event_from
        @event.address.should == nil
      end

      it "should parse the street number with -" do
        msg =  <<ARUP1
MSH|^~\&|ARUP|ARUP LABORATORIES^46D0523979^CLIA|UTDOH|UT|200903261645||ORU^R01|200903261645128667|P|2.3.1|1\rPID|1||17744418^^^^MR||ZHANG^GEORGE^^^^^L||19830922|M||U^Unknown^HL70005|42-12 HAPPY LN^^SALT LAKE CITY^UT^84444^USA^^^Salt Lake||^^PH^^^801^5552346|||||||||U^Unknown^HL70189\rORC||||||||||||^FARNSWORTH^MABEL^W|||||||||University Hospital UT|50 North Medical Drive^^Salt Lake City^UT^84132^USA^B||^^^^^USA^B\rOBR|1||09078102377|13954-3^Hepatitis Be Antigen^LN|||200903191011|||||||200903191011|BLOOD|^FARNSWORTH^MABEL^W||||||200903191011|||F||||||9^Unknown\rOBX|1|ST|13954-3^Hepatitis Be Antigen^LN|1|Positive|Metric Ton|Negative||||F|||200903210007\r
ARUP1
        @staged_message = StagedMessage.new(:hl7_message => msg)
        @event = @staged_message.new_event_from
        @event.address.street_number.should == "42-12"
        @event.address.street_name.should == "Happy Ln"
      end

      it "should populate the county" do
        msg =  <<ARUP1
MSH|^~\&|ARUP|ARUP LABORATORIES^46D0523979^CLIA|UTDOH|UT|200903261645||ORU^R01|200903261645128667|P|2.3.1|1\rPID|1||17744418^^^^MR||ZHANG^GEORGE^^^^^L||19830922|M||U^Unknown^HL70005|42 HAPPY LN^^SALT LAKE CITY^UT^84444^USA^^^Salt Lake||^^PH^^^801^5552346|||||||||U^Unknown^HL70189\rORC||||||||||||^FARNSWORTH^MABEL^W|||||||||University Hospital UT|50 North Medical Drive^^Salt Lake City^UT^84132^USA^B||^^^^^USA^B\rOBR|1||09078102377|13954-3^Hepatitis Be Antigen^LN|||200903191011|||||||200903191011|BLOOD|^FARNSWORTH^MABEL^W||||||200903191011|||F||||||9^Unknown\rOBX|1|ST|13954-3^Hepatitis Be Antigen^LN|1|Positive|Metric Ton|Negative||||F|||200903210007\r
ARUP1
        @staged_message = StagedMessage.create(:hl7_message => unique_message(msg))
        @event = @staged_message.new_event_from
        @event.address.county.should == external_codes(:county_salt_lake)
      end

      it "should fill in the person's address if it's not present" do
        a = @event.address
        pa = @event.interested_party.person_entity.canonical_address
        pa.should_not be_blank
        pa.street_number.should == a.street_number
        pa.unit_number.should == a.unit_number
        pa.street_name.should == a.street_name
        pa.city.should == a.city
        pa.state_id.should == a.state_id
        pa.postal_code.should == a.postal_code
      end
    end

    describe "with a record missing address and phone" do
      before :each do
        @staged_message = StagedMessage.new(:hl7_message => unique_message(hl7_messages[:arup_simple_pid]))
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
      @staged_message = StagedMessage.new(:hl7_message => unique_message(hl7_messages[:arup_1]))
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

  describe "search" do
    before do
      @jones_message     = StagedMessage.create! :hl7_message => unique_message(hl7_messages[:arup_replace_name].call('David Jones'))
      @davis_message     = StagedMessage.create! :hl7_message => unique_message(hl7_messages[:arup_replace_name].call('Mike Davis'))
      @quest_message     = StagedMessage.create! :hl7_message => unique_message(hl7_messages[:arup_replace_lab].call('Quest Labs'))
      @date_message      = StagedMessage.create! :hl7_message => unique_message(hl7_messages[:arup_replace_collection_date].call('200810011645'))
      @test_type_message = StagedMessage.create! :hl7_message => unique_message(hl7_messages[:arup_replace_test_type].call('Monkey test'))
    end

    it 'finds records by last name' do
      StagedMessage.find_by_search(:last_name => 'Jones').should == [@jones_message]
    end

    it 'finds records by first name' do
      StagedMessage.find_by_search(:first_name => 'mike').should == [@davis_message]
    end

    it 'finds records by lab name' do
      StagedMessage.find_by_search(:laboratory => 'quest').should == [@quest_message]
    end

    it 'finds records by collection date' do
      StagedMessage.find_by_search(:start_date => '2008-01-01', :end_date => '2008-12-31').should == [@date_message]
    end

    it 'finds records by test type' do
      StagedMessage.find_by_search(:test_type => 'Monkey').should == [@test_type_message]
    end

    it 'finds nothing if criteria is empty' do
      StagedMessage.find_by_search(:test_type => '').should == []
    end

    it "finds nothing if criteria contains only options we don't care about" do
      StagedMessage.find_by_search(:action => 'Search').should == []
    end
  end

  def unique_message(message)
    message = HL7::Message.new(message)
    message[:MSH].message_control_id = ActiveSupport::SecureRandom.hex(32)
    message.to_hl7
  end
end

