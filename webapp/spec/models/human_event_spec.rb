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
require File.expand_path(File.dirname(__FILE__) + '/../../features/support/hl7_messages.rb')

def with_human_event(event_hash=@event_hash, &block)
  event = HumanEvent.new(event_hash)
  block.call(event) if block_given?
  event
end

def set_loinc_code(msg, loinc)
  msg.gsub(/(OBX\|.\|..\|)\d+-\d/, '\1'+loinc)
end

def set_obx_5(msg, value)
  msg.gsub(/(OBX\|.\|..\|.+?\|.\|).+?\|/, '\1'+value+'|')
end

describe HumanEvent, 'associations'  do
  it { should have_one(:interested_party) }
  it { should have_many(:labs) }
  it { should have_many(:hospitalization_facilities) }
  it { should have_many(:diagnostic_facilities) }
  it { should have_many(:clinicians) }

  describe "nested attributes are assigned" do
    it { should accept_nested_attributes_for(:interested_party) }
    it { should accept_nested_attributes_for(:labs) }
    it { should accept_nested_attributes_for(:hospitalization_facilities) }
    it { should accept_nested_attributes_for(:diagnostic_facilities) }
    it { should accept_nested_attributes_for(:clinicians) }

    describe "destruction is allowed properly" do
      fixtures :events

      before(:each) do
        @event = HumanEvent.new( "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Green" } } })
      end

      it "Should not allow interested parties to be deleted via a nested attribute" do
        @event.build_interested_party.build_person_entity.build_person(:last_name => "whatever")
        @event.save
        @event.interested_party_attributes = { "_delete"=>"1" }
        @event.interested_party.should_not be_marked_for_destruction
      end

      it "Should allow labs to be deleted via a nested attribute" do
        @event.labs.build
        @event.save
        @event.labs_attributes = [ { "id" => "#{@event.labs[0].id}", "_delete"=>"1"} ]
        @event.labs[0].should be_marked_for_destruction
      end

      it "Should allow hospitalization facilities to be deleted via a nested attribute" do
        @event.hospitalization_facilities.build
        @event.save
        @event.hospitalization_facilities_attributes = [ { "id" => "#{@event.hospitalization_facilities[0].id}", "_delete"=>"1"} ]
        @event.hospitalization_facilities[0].should be_marked_for_destruction
      end

      it "Should allow diagnostic_facilities to be deleted via a nested attribute" do
        @event.diagnostic_facilities.build
        @event.save
        @event.diagnostic_facilities_attributes = [ { "id" => "#{@event.diagnostic_facilities[0].id}", "_delete"=>"1"} ]
        @event.diagnostic_facilities[0].should be_marked_for_destruction
      end

      it "Should allow clinicians to be deleted via a nested attribute" do
        @event.clinicians.build
        @event.save
        @event.clinicians_attributes = [ { "id" => "#{@event.clinicians[0].id}", "_delete"=>"1"} ]
        @event.clinicians[0].should be_marked_for_destruction
      end
    end

    describe "empty attributes are handled correctly" do
      fixtures :events, :entities, :places, :places_types

      before(:each) do
        @event = HumanEvent.new( "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Green" } } })
      end

      it "should reject hospitals with no entity ID and no settings" do
        @event.hospitalization_facilities_attributes = [ { "secondary_entity_id" => nil, "hospitals_participation_attributes" => {} } ]
        @event.hospitalization_facilities.should be_empty
      end

      it "should reject diagnostic facilities with no place" do
        @event.diagnostic_facilities_attributes = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "" } } } ]
        @event.diagnostic_facilities.should be_empty
      end

      it "should reject clinicians with no person" do
        @event.clinicians_attributes = [ { "person_entity_attributes" => { "person_attributes" => { "last_name" => "" } } } ]
        @event.clinicians.should be_empty
      end

      it "should reject labs with no lab entries" do
        @event.labs_attributes = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "" } }, "lab_results_attributes" => {} } ]
        @event.labs.should be_empty
      end

      it "should reuse existing labs" do
        @event.labs_attributes = [ { "place_entity_attributes" => { "place_attributes" => { "name" => places(:Existing_Lab_One).name } }, "lab_results_attributes" => {} } ]
        @event.labs[0].secondary_entity_id.should == places(:Existing_Lab_One).entity_id
      end
    end
  end
end

describe HumanEvent, 'age at onset'  do

  before(:each) do
    @event_hash = {
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => {
            "last_name"=>"Green"
          }
        },
      },
      :created_at => DateTime.now,
      :updated_at => DateTime.now
    }
  end

  it 'should not be saved if there is no birthday' do
    with_human_event do |event|
      event.send(:set_age_at_onset)
      event.age_info.age_at_onset.should be_nil
      event.age_info.age_type.code_description.should == 'unknown'
    end
  end

  it 'should be saved, along w/ an age type' do
    with_human_event do |event|
      event.safe_call_chain(:interested_party, :person_entity, :person).birth_date = 20.years.ago.to_date
      event.save!
      event.age_info.age_at_onset.should_not == nil
      event.age_info.age_type.should_not == nil
      event.errors.on(:age_at_onset).should == nil
    end
  end

  it 'should not be valid if negative' do
    with_human_event do |event|
      event.safe_call_chain(:interested_party, :person_entity, :person).birth_date = DateTime.tomorrow
      event.send(:set_age_at_onset)
      event.save
      event.should_not be_valid
      event.errors.on(:age_at_onset).should == "is negative. This is usually caused by an incorrect onset date or birth date."
    end
  end
end

describe HumanEvent, 'parent/guardian field' do

  before(:each) do
    @event_hash = {
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => {
            "last_name"=>"Green"
          }
        },
      },
      :created_at => DateTime.now,
      :updated_at => DateTime.now
    }
  end


  it 'should exist' do
    with_human_event do |event|
      event.respond_to?(:parent_guardian).should be_true
    end
  end

  it 'should accept text longer then 50 chars' do
    with_human_event do |event|
      event.parent_guardian = 'r' * 51
      lambda{event.save!}.should_not raise_error
    end
  end

  it 'should be invalid for string longer then 255 (db limit)' do
    with_human_event do |event|
      event.parent_guardian = 'q' * 256
      event.should_not be_valid
    end
  end

  it 'should allow nil' do
    with_human_event do |event|
      event.parent_guardian = nil
      lambda{event.save!}.should_not raise_error
    end
  end

  it 'should allow blank data' do
    with_human_event do |event|
      event.parent_guardian = ''
      lambda{event.save!}.should_not raise_error
    end
  end

end

describe HumanEvent, 'adding staged messages' do
  fixtures :loinc_codes, :common_test_types

  describe "basic processing" do
    before(:each) do
      @event_hash = {
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Green"
            }
          },
        },
        :created_at => DateTime.now,
        :updated_at => DateTime.now
      }
    end

    it 'should raise an exception when not passed a staged message' do
      with_human_event do |event|
        lambda{event.add_labs_from_staged_message("noise")}.should raise_error(ArgumentError)
      end
    end

    it 'should create a new lab and a single lab result when using the ARUP1 staged message' do
      with_human_event do |event|
        staged_message = StagedMessage.new(:hl7_message => hl7_messages[:arup_1])
        event.add_labs_from_staged_message(staged_message)
        event.labs.size.should == 1
        event.labs.first.place_entity.place.name.should == staged_message.message_header.sending_facility
        event.labs.first.lab_results.size.should == 1
        event.labs.first.lab_results.first.test_type.common_name.should == common_test_types(:hep_b_ag).common_name
        event.labs.first.lab_results.first.collection_date.eql?(Date.parse(staged_message.observation_request.collection_date)).should be_true
        event.labs.first.lab_results.first.lab_test_date.eql?(Date.parse(staged_message.observation_request.tests.first.observation_date)).should be_true
        event.labs.first.lab_results.first.units.should == staged_message.observation_request.tests.first.units
        event.labs.first.lab_results.first.reference_range.should == staged_message.observation_request.tests.first.reference_range
        event.labs.first.lab_results.first.test_result.code_description.downcase.include?(staged_message.observation_request.tests.first.result.downcase).should be_true
        event.labs.first.lab_results.first.result_value.should be_blank
        event.labs.first.lab_results.first.specimen_source.code_description.should =~ /#{staged_message.observation_request.specimen_source}/i
        event.labs.first.lab_results.first.test_status.code_description.should == "Final"
      end
    end
  end

  describe "setting disease" do
    fixtures :diseases_loinc_codes, :diseases

    before(:each) do
      @event_hash = {
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Green"
            }
          },
        },
        :created_at => DateTime.now,
        :updated_at => DateTime.now
      }
    end

    it "should not assign disease if disease already assigned" do
      @event_hash['disease_event_attributes'] = {'disease_id' => 1}
      with_human_event do |event|
        msg = set_loinc_code(hl7_messages[:arup_1], loinc_codes(:one_disease).loinc_code)
        staged_message = StagedMessage.new(:hl7_message => msg)
        event.add_labs_from_staged_message(staged_message)
        event.disease_event.disease_id.should == 1
      end
    end

    it "should assign disease if LOINC points to just one disease" do
      with_human_event do |event|
        msg = set_loinc_code(hl7_messages[:arup_1], loinc_codes(:one_disease).loinc_code)
        staged_message = StagedMessage.new(:hl7_message => msg)
        event.add_labs_from_staged_message(staged_message)
        event.disease_event.disease_id.should == loinc_codes(:one_disease).diseases.first.id
      end
    end

    it "should not assign disease if LOINC points to multiple diseases" do
      with_human_event do |event|
        msg = set_loinc_code(hl7_messages[:arup_1], loinc_codes(:two_diseases).loinc_code)
        staged_message = StagedMessage.new(:hl7_message => msg)
        event.add_labs_from_staged_message(staged_message)
        event.disease_event.should be_nil
      end
    end

    it "should not assign disease if LOINC points to no diseases" do
      with_human_event do |event|
        msg = set_loinc_code(hl7_messages[:arup_1], loinc_codes(:no_disease).loinc_code)
        staged_message = StagedMessage.new(:hl7_message => msg)
        event.add_labs_from_staged_message(staged_message)
        event.disease_event.should be_nil
      end
    end
  end

  describe "mapping based on scale type" do
    describe "Mapping organisms for Ord and Qn" do
      describe "When no organism exists" do
        before(:each) do
          with_human_event do |event|
            staged_message = StagedMessage.new(:hl7_message => hl7_messages[:arup_1])
            event.add_labs_from_staged_message(staged_message)
            @event = event
          end
        end

        it "should not set the organism_id" do
          @event.labs.first.lab_results.first.organism_id.should be_nil
        end

        it "should make a note" do
          @event.labs.first.lab_results.first.comment.should_not be_nil
        end
      end

      describe "When one organism exists" do
        before(:each) do
          with_human_event do |event|
            msg = set_loinc_code(hl7_messages[:arup_1], loinc_codes(:ord_one_organism).loinc_code)
            staged_message = StagedMessage.new(:hl7_message => msg)
            event.add_labs_from_staged_message(staged_message)
            @event = event
          end
        end

        fixtures :organisms
        it "should set the organism_id" do
          @event.labs.first.lab_results.first.organism.should == loinc_codes(:ord_one_organism).organism
        end
      end
    end

    describe "Mapping OBX-5" do
      describe "When scale type is Ord" do
        it "Should map matching values to test_result_id" do
          with_human_event do |event|
            staged_message = StagedMessage.new(:hl7_message => hl7_messages[:arup_1])
            event.add_labs_from_staged_message(staged_message)
            event.labs.first.lab_results.first.test_result.code_description.downcase.include?(staged_message.observation_request.tests.first.result.downcase).should be_true
          end
        end

        it "Should place unmappable results in result_value" do
          with_human_event do |event|
            msg = set_obx_5(hl7_messages[:arup_1], "unmappable")
            staged_message = StagedMessage.new(:hl7_message => msg)
            event.add_labs_from_staged_message(staged_message)
            event.labs.first.lab_results.first.result_value == "unmappable" 
          end
        end
      end

      describe "when scale type is Qn" do
        it "should populate the test_result field" do
          with_human_event do |event|
            staged_message = StagedMessage.new(:hl7_message => hl7_messages[:unknown_observation_value])
            event.add_labs_from_staged_message(staged_message)
            event.labs.first.lab_results[0].result_value.should == staged_message.observation_request.tests[0].result
            event.labs.first.lab_results[0].test_result.should be_nil
          end
        end
      end

      describe "when scale type is Nom" do
        fixtures :organisms
        it "should map matching organisms to organism_id" do
          with_human_event do |event|
            msg = set_loinc_code(hl7_messages[:arup_1], loinc_codes(:nominal).loinc_code)
            msg = set_obx_5(msg, organisms(:organism_1).organism_name)
            staged_message = StagedMessage.new(:hl7_message => msg)
            event.add_labs_from_staged_message(staged_message)
            event.labs.first.lab_results[0].organism.should == organisms(:organism_1)
          end
        end

        it "should map everything else to result_value" do
          with_human_event do |event|
            msg = set_loinc_code(hl7_messages[:arup_1], loinc_codes(:nominal).loinc_code)
            msg = set_obx_5(msg, "unknown")
            staged_message = StagedMessage.new(:hl7_message => msg)
            event.add_labs_from_staged_message(staged_message)
            event.labs.first.lab_results[0].result_value.should == "unknown"
            event.labs.first.lab_results[0].organism.should be_nil
          end
        end
      end
    end
  end

  it 'It should assign multi-word test_results properly' do
    with_human_event do |event|
      staged_message = StagedMessage.new(:hl7_message => hl7_messages[:arup_simple_pid])
      event.add_labs_from_staged_message(staged_message)
      event.labs.first.lab_results.first.test_result.code_description.downcase.include?(staged_message.observation_request.tests.first.result.downcase).should be_true
    end
  end

  it 'should create a new lab and two lab results when using the ARUP2 staged message' do
    with_human_event do |event|
      staged_message = StagedMessage.new(:hl7_message => hl7_messages[:arup_2])
      event.add_labs_from_staged_message(staged_message)
      event.labs.size.should == 1
      event.labs.first.lab_results.size.should == 2
    end
  end

end

describe HumanEvent, 'validating out of state patients' do

  before(:each) do
    @event = Factory.build(:morbidity_event, :address => Factory.build(:address))
  end

  it 'should be valid to have an out of state patient with no case status' do
    @event.address.county = external_codes(:county_oos)
    @event.should be_valid
  end

  it 'should be valid to have an out of state patient with a case status of out of state' do
    @event.address.county = external_codes(:county_oos)
    @event.lhd_case_status = external_codes(:case_status_oos)
    @event.should be_valid
    @event.lhd_case_status = nil
    @event.state_case_status = external_codes(:case_status_oos)
    @event.should be_valid
  end

  it 'should not be valid to have an out of state patient with a case status of out of state' do
    @event.address.county = external_codes(:county_oos)
    @event.lhd_case_status = external_codes(:case_status_confirmed)
    @event.should_not be_valid
    @event.lhd_case_status = nil
    @event.state_case_status = external_codes(:case_status_confirmed)
    @event.should_not be_valid
    @event.errors.on(:base).should == "Local or state case status must be 'Out of state' or blank for an event with a county of 'Out of state'"
  end

end

describe "adding an address to a human event's interested party" do

  it "should establish a canonical address the first time an address is provided" do
    e = Factory.build(:morbidity_event)
    person_entity = e.interested_party.person_entity
    person_entity.canonical_address.should be_nil
    address = Factory.create(:address, :event_id => e.id, :entity_id => person_entity.id)
    person_entity.reload
    person_entity.canonical_address.should_not be_nil
    person_entity.canonical_address.street_number.should == address.street_number
    person_entity.canonical_address.street_name.should == address.street_name
    person_entity.canonical_address.unit_number.should == address.unit_number
    person_entity.canonical_address.city.should == address.city
    person_entity.canonical_address.county_id.should == address.county_id
    person_entity.canonical_address.state_id.should == address.state_id
    person_entity.canonical_address.postal_code.should == address.postal_code
  end

end

describe "When added to an event using an existing person entity" do

  before(:each) do
    @user = Factory.create(:user)
    User.stubs(:current_user).returns(@user)
    @person_entity = Factory.create(:person_entity)
    @person_event_hash = { :interested_party_attributes => { :primary_entity_id => "#{@person_entity.id}" } }
  end

  it "should receive the person entity's canonical address if one exists" do
    canonical_address = Factory.create(:address, :entity_id => @person_entity.id)
    event = MorbidityEvent.new(@person_event_hash)
    event.save
    event.reload
    new_person_address = event.address
    new_person_address.should_not be_nil
    new_person_address.street_number.should == canonical_address.street_number
    new_person_address.street_name.should == canonical_address.street_name
    new_person_address.unit_number.should == canonical_address.unit_number
    new_person_address.city.should == canonical_address.city
    new_person_address.state_id.should == canonical_address.state_id
    new_person_address.county_id.should == canonical_address.county_id
    new_person_address.postal_code.should == canonical_address.postal_code
  end

  it "should not have an address if the person entity does not have canonical address" do
    event = MorbidityEvent.new(@person_event_hash)
    new_person_address = event.address
    new_person_address.should be_nil
  end

end
