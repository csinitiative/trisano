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

def with_human_event(event_hash=@event_hash, &block)
  event = HumanEvent.new(event_hash)
  block.call(event) if block_given?
  event
end

def set_loinc_code(msg, loinc)
  msg.gsub(/(OBX\|[^|]*\|[^|]*\|)\d+-\d/, '\1'+loinc)
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
        @event.interested_party_attributes = { "_destroy"=>"1" }
        @event.interested_party.should_not be_marked_for_destruction
      end

      it "Should allow labs to be deleted via a nested attribute" do
        @event.labs.build( { :secondary_entity_id => Factory.create(:place_entity).id.to_s } )
        @event.save
        @event.labs_attributes = [ { "id" => "#{@event.labs[0].id}", "_destroy"=>"1"} ]
        @event.labs[0].should be_marked_for_destruction
      end

      it "Should allow hospitalization facilities to be deleted via a nested attribute" do
        @event.hospitalization_facilities.build
        @event.save
        @event.hospitalization_facilities_attributes = [ { "id" => "#{@event.hospitalization_facilities[0].id}", "_destroy"=>"1"} ]
        @event.hospitalization_facilities[0].should be_marked_for_destruction
      end

      it "Should allow diagnostic_facilities to be deleted via a nested attribute" do
        @event.diagnostic_facilities.build
        @event.save
        @event.diagnostic_facilities_attributes = [ { "id" => "#{@event.diagnostic_facilities[0].id}", "_destroy"=>"1"} ]
        @event.diagnostic_facilities[0].should be_marked_for_destruction
      end

      it "Should allow clinicians to be deleted via a nested attribute" do
        @event.clinicians.build
        @event.save
        @event.clinicians_attributes = [ { "id" => "#{@event.clinicians[0].id}", "_destroy"=>"1"} ]
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

      it "should reject labs with a place entity structure with no lab entries" do
        @event.labs_attributes = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "" } }, "lab_results_attributes" => {} } ]
        @event.labs.should be_empty
      end

      it "should reject labs with a secondary_entity_id structure with no lab entries" do
        @event.labs_attributes = [ { "secondary_entity_id" => "", "lab_results_attributes" => {} } ]
        @event.labs.should be_empty
      end

      it "should reject labs without place_entity_attributes or a secondary_entity_id" do
        @event.labs_attributes = [ { "lab_results_attributes" => {} } ]
        @event.labs.should be_empty
      end
      
      it "should accept labs with a place entity with place attributes" do
        @event.labs_attributes = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "ARUP" } }, "lab_results_attributes" => {} } ]
        @event.labs.should_not be_empty
      end

      it "should accept labs with only a secondary_entity_id" do
        @event.labs_attributes = [ { "secondary_entity_id" => Factory.create(:place_entity).id.to_s, "lab_results_attributes" => {} } ]
        @event.labs.should_not be_empty
      end

      it "should associate labs with a secondary_entity_id with that entity" do
        lab_place_entity = Factory.create(:place_entity)
        @event.labs_attributes = [ { "secondary_entity_id" => lab_place_entity.id.to_s, "lab_results_attributes" => {} } ]
        @event.save!
        @event.labs[0].place_entity.id.should == lab_place_entity.id
      end

      it "should reuse existing labs if passed a place entity" do
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
      event.errors.on(:age_at_onset).should == "must be between 0 and 120. This is usually caused by an incorrect onset date or birth date."
    end
  end

  it 'should not be valid if > 120' do
    with_human_event do |event|
      event.safe_call_chain(:interested_party, :person_entity, :person).birth_date = Date.today - 121.years
      event.send(:set_age_at_onset)
      event.save
      event.should_not be_valid
      event.errors.on(:age_at_onset).should == "must be between 0 and 120. This is usually caused by an incorrect onset date or birth date."
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
      event.should respond_to(:parent_guardian)
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

    before :all do
      common_test_type = CommonTestType.create :common_name => 'Culture'

      disease = Factory.create :pertussis
      organism = Factory.create :bordetella_pertussis
      loinc_code = LoincCode.new :common_test_type => common_test_type,
        :loinc_code => '548-8', :test_name => 'Bordetella pertussis',
        :scale => ExternalCode.loinc_scale_by_the_code("Ord"),
        :organism => organism
      loinc_code.diseases << disease
      loinc_code.save!

      common_test_type = CommonTestType.new :common_name => 'Blood lead test'
      common_test_type.diseases << disease
      common_test_type.save!

      disease = Factory.create :lead_poisoning
      loinc_code = LoincCode.new :common_test_type => common_test_type,
        :loinc_code => '10368-9', :test_name => 'Lead BldCmCnc',
        :scale => ExternalCode.loinc_scale_by_the_code("Qn")
      loinc_code.diseases << disease
      loinc_code.save!
    end

    after :all do
      CommonTestType.find_by_common_name('Culture').destroy
      CommonTestType.find_by_common_name('Blood lead test').destroy
      Disease.find_by_disease_name('Lead poisoning').destroy
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
        event.labs.first.lab_results.first.collection_date.eql?(Date.parse(staged_message.observation_requests.first.collection_date)).should be_true
        event.labs.first.lab_results.first.lab_test_date.eql?(Date.parse(staged_message.observation_requests.first.tests.first.observation_date)).should be_true
        event.labs.first.lab_results.first.units.should == staged_message.observation_requests.first.tests.first.units
        event.labs.first.lab_results.first.reference_range.should == staged_message.observation_requests.first.tests.first.reference_range
        event.labs.first.lab_results.first.test_result.code_description.downcase.include?(staged_message.observation_requests.first.tests.first.result.downcase).should be_true
        event.labs.first.lab_results.first.result_value.should be_blank
        event.labs.first.lab_results.first.specimen_source.code_description.should =~ /#{staged_message.observation_requests.first.specimen_source}/i
        event.labs.first.lab_results.first.test_status.code_description.should == "Final"
      end
    end

    it 'should set comments from PID-11.6, OBR-3, SPM-2 and OBX-8' do
      with_human_event do |event|
        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => HL7MESSAGES[:realm_cj_abnormal_flags])
        event.labs.first.lab_results.first.comment.should == "Country: USA, Specimen ID: 23456, Abnormal flags: H"
      end
    end

    it 'should set clinician info when present' do
      with_human_event do |event|
        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => HL7MESSAGES[:realm_campylobacter_jejuni])
        event.clinicians.size.should == 1

        clinician = event.clinicians.first
        clinician.person_entity.person.first_name.should == 'Alan'
        clinician.person_entity.person.last_name.should == 'Admit'
        clinician.person_entity.telephones.size.should == 1

        telephone = clinician.person_entity.telephones.first
        telephone.entity_location_type.should ==
          external_codes(:telephonelocationtype_work)
        telephone.area_code.should == '555'
        telephone.phone_number.should == '5551005'
        telephone.extension.should be_blank
      end
    end

    it 'should set additional clinician info when present in PV1 segment' do
      with_human_event do |event|
        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => HL7MESSAGES[:realm_cj_clinicians])
        event.clinicians.size.should == 3

        clinician = event.clinicians.first
        clinician.person_entity.person.first_name.should == 'Alan'
        clinician.person_entity.person.last_name.should == 'Admit'
        clinician.person_entity.telephones.size.should == 1

        clinician = event.clinicians.second
        clinician.person_entity.person.first_name.should == 'Susan'
        clinician.person_entity.person.last_name.should == 'Jekyll'

        clinician = event.clinicians.third
        clinician.person_entity.person.first_name.should == 'Herbert'
        clinician.person_entity.person.last_name.should == 'Hyde'
      end
    end

    it 'should set death_date and died_id when appropriate' do
      login_as_super_user
      staged_message = StagedMessage.new(:hl7_message => HL7MESSAGES[:realm_cj_died])

      # build the required organism and disease for this
      disease  = Factory.create :campylobacteriosis
      organism = Factory.build :campylobacter_jejuni
      organism.diseases << disease
      organism.save!

      organism.diseases.count.should == 1

      obx = staged_message.observation_requests.first.all_tests.first
      db_organism = Organism.first(:conditions => [ "organism_name ~* ?", '^'+obx.result+'$' ])
      db_organism.should_not be_blank
      db_organism.should == organism

      db_organism.diseases.count.should == 1

      # sets the patient date of death
      event = staged_message.new_event_from
      event.interested_party.person_entity.person.date_of_death.should == Date.parse('20101111')

      # set the died_id in the disease_event
      event.add_labs_from_staged_message staged_message
      event.disease_event.died.should == ExternalCode.yes
    end

    it 'should set the ethnicity field when present' do
      login_as_super_user
      staged_message = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_campylobacter_jejuni]
      event = staged_message.new_event_from
      event.interested_party.person_entity.person.ethnicity.should == external_codes(:ethnicity_non_hispanic)
    end

    it 'should set multiple contact numbers when present' do
      login_as_super_user
      staged_message = StagedMessage.new(:hl7_message => HL7MESSAGES[:realm_campylobacter_jejuni])
      event = staged_message.new_event_from
      event.interested_party.person_entity.telephones.size.should == 2
      home_phone = event.interested_party.person_entity.telephones.first
      work_phone = event.interested_party.person_entity.telephones.second

      home_phone.entity_location_type.should ==
        external_codes(:telephonelocationtype_home)
      work_phone.entity_location_type.should ==
        external_codes(:telephonelocationtype_work)

      home_phone.area_code.should == '555'
      home_phone.phone_number.should == '5552004'
      home_phone.extension.should be_blank

      work_phone.area_code.should == '955'
      work_phone.phone_number.should == '5551009'
      work_phone.extension.should be_blank
    end

    it 'should take the LOINC code from OBR-4.1 when present' do
      with_human_event do |event|
        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => HL7MESSAGES[:realm_cj_obr_4])
        event.should be_valid
        # Which might just be nil...
        event.labs.first.lab_results.first.loinc_code.should ==
          LoincCode.find_by_loinc_code('625-4')
      end
    end

    it 'should take the primary language ID from PID-15 when possible' do
      login_as_super_user
      staged_message = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_cj_en]
      event = staged_message.new_event_from
      event.interested_party.person_entity.person.primary_language_id.should == external_codes(:language_english).id
    end

    it 'should populate the parent_guardian field when present' do
      with_human_event do |event|
        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => HL7MESSAGES[:realm_lead_laboratory_result])
        event.should be_valid
        event.parent_guardian.should == 'Mum, Martha'
      end
    end

    it 'should take the clinician info from ORC-12/14 if present' do
      with_human_event do |event|
        @hl7 = HL7::Message.parse HL7MESSAGES[:realm_campylobacter_jejuni]
        @obr_segment = @hl7.observation_requests.first.obr_segment
        @obr_segment.ordering_provider = ''
        @obr_segment.order_callback_phone_number = ''

        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => @hl7.to_hl7)
        event.should be_valid

        event.clinicians.size.should == 1

        # from the ORC segment
        clinician = event.clinicians.first
        clinician.person_entity.person.first_name.should == 'Alan'
        clinician.person_entity.person.last_name.should == 'Admit'
        clinician.person_entity.telephones.size.should == 1

        telephone = clinician.person_entity.telephones.first
        telephone.entity_location_type.should ==
          external_codes(:telephonelocationtype_work)
        telephone.area_code.should == '555'
        telephone.phone_number.should == '5551005'
        telephone.extension.should be_blank
      end
    end

    it 'should take the hospitalization status from PV1-2' do
      with_human_event do |event|
        # build the required organism and disease for this
        disease  = Factory.create :campylobacteriosis
        organism = Factory.build :campylobacter_jejuni
        organism.diseases << disease
        organism.save!

        organism.diseases.count.should == 1

        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => HL7MESSAGES[:realm_campylobacter_jejuni])
        event.should be_valid
        event.disease_event.should_not be_nil
        event.disease_event.hospitalized_id.should == ExternalCode.no.id
      end
    end

    it 'should take the hospital name from PV2-23 or ORC-21' do
      with_human_event do |event|
        # build the required organism and disease for this
        disease  = Factory.create :campylobacteriosis
        organism = Factory.build :campylobacter_jejuni
        organism.diseases << disease
        organism.save!

        organism.diseases.count.should == 1

        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => HL7MESSAGES[:realm_cj_inpatient])
        event.should be_valid
        event.hospitalization_facilities.size.should == 1
        hospital = event.hospitalization_facilities.first.place_entity.place
        hospital.name.should == 'Level Seven Healthcare, Inc.'
        hospital.short_name.should == 'Level Seven Healthcare, Inc.'
        hospital.place_types.size.should == 1
        hospital.place_types.first.should == Code.find_by_code_name_and_the_code('placetype', 'H')
      end
    end

    it 'should show different LOINC codes for each OBX segment' do
      with_human_event do |event|
        common_test_type = CommonTestType.find_by_common_name 'Culture'

        # build the required organism and disease for this
        disease  = Factory.create :campylobacteriosis
        organism = Factory.build :campylobacter_jejuni
        organism.diseases << disease
        organism.save!

        organism.diseases.count.should == 1

        cj_loinc_code = LoincCode.new :common_test_type => common_test_type,
          :loinc_code => '6331-3', :test_name => 'Campylobacter jejuni AB',
          :scale => ExternalCode.loinc_scale_by_the_code("Nom")
        cj_loinc_code.diseases << disease
        cj_loinc_code.save!

        disease  = Factory.create :shigellosis
        organism = Factory.build :shigella
        organism.diseases << disease
        organism.save!

        organism.diseases.count.should == 1

        sh_loinc_code = LoincCode.new :common_test_type => common_test_type,
          :loinc_code => '17576-0', :test_name => 'Shigella',
          :scale => ExternalCode.loinc_scale_by_the_code("Nom")
        sh_loinc_code.diseases << disease
        sh_loinc_code.save!

        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => HL7MESSAGES[:nist_sample_6])
        event.should be_valid

        # There are 3 OBX segments, but one doesn't map.
        event.labs.first.lab_results.size.should == 2
        event.labs.first.lab_results.first.loinc_code.should == cj_loinc_code
        event.labs.first.lab_results.second.loinc_code.should == sh_loinc_code

        sh_loinc_code.destroy
        cj_loinc_code.destroy
      end
    end

    it 'should assign a disease from the OBX segment even if the OBR segment has associated diseases' do
      with_human_event do |event|
        # build the required organism and disease for this
        disease  = Factory.create :campylobacteriosis
        organism = Factory.build :campylobacter_jejuni
        organism.diseases << disease
        organism.save!

        organism.diseases.count.should == 1

        staged_message = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_campylobacter_jejuni]

        staged_message.observation_requests.size.should == 1
        obr_loinc = staged_message.observation_requests.first.test_performed
        obr_loinc.should_not be_nil
        obr_loinc.should == '625-4'

        # DEBT
        # With the default deployment of TriSano, 625-4 maps to 8
        # different diseases.  Here it's not even defined.  Maybe that
        # scenario should be mocked up to verify the following test.
        # Meanwhile, we simply verify the OBR LOINC code.  The disease
        # assignment occurs on the basis of the association built
        # immediately above.

        # LoincCode.find_by_loinc_code(obr_loinc).diseases.count.should > 1

        event.add_labs_from_staged_message staged_message

        event.should be_valid
        event.disease_event.should_not be_nil
        event.disease_event.disease.should_not be_nil
        event.disease_event.disease.should == disease
      end
    end

    it "should assign a staged message to a CMR even if some OBX segments don't map" do
      with_human_event do |event|
        staged_message = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_lead_laboratory_result]
        staged_message.observation_requests.first.all_tests.size.should == 2

        event.add_labs_from_staged_message staged_message
        event.should be_valid
        event.labs.first.lab_results.size.should == 1
      end
    end

    it "should reject a staged message if all its OBX segments are invalid" do
      with_human_event do |event|
        lambda do
          event.add_labs_from_staged_message StagedMessage.new(:hl7_message => HL7MESSAGES[:ihc_1])
        end.should raise_error(StagedMessage::UnknownLoincCode, "All LOINC codes in message unknown or unlinked.")
      end
    end

    it 'should assign the clinician telephone from the OBR segment when appropriate' do
      # On assignment, we check the ORC segment first.  If the same
      # clinician appears in the OBR segment, as often happens, we
      # ignore the second occurrence.  But sometimes the phone appears
      # only in the OBR segment, not the ORC segment.  In that case,
      # TriSano did not previously register the OBR phone number.
      # That has been fixed.
      with_human_event do |event|
        staged_message = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_campylobacter_jejuni]
        hl7 = staged_message.hl7
        hl7.should_not be_nil
        obr = hl7[:OBR]
        obr.should_not be_nil

        obr.order_callback_phone_number = ''

        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => hl7.to_hl7)
        event.should be_valid
        orc_clinician = event.clinicians.first
        orc_clinician.should_not be_nil
        orc_clinician.person_entity.telephones.should_not be_blank
      end
    end

    it 'should assign an ORC clinician when the OBR clinician fields are blank' do
      with_human_event do |event|
        common_test_type = CommonTestType.find_by_common_name 'Culture'

        # build the required organism and disease for this
        disease  = Factory.create :campylobacteriosis
        organism = Factory.build :campylobacter_jejuni
        organism.diseases << disease
        organism.save!

        organism.diseases.count.should == 1

        cj_loinc_code = LoincCode.new :common_test_type => common_test_type,
          :loinc_code => '6331-3', :test_name => 'Campylobacter jejuni AB',
          :scale => ExternalCode.loinc_scale_by_the_code("Nom")
        cj_loinc_code.diseases << disease
        cj_loinc_code.save!

        disease  = Factory.create :shigellosis
        organism = Factory.build :shigella
        organism.diseases << disease
        organism.save!

        organism.diseases.count.should == 1

        sh_loinc_code = LoincCode.new :common_test_type => common_test_type,
          :loinc_code => '17576-0', :test_name => 'Shigella',
          :scale => ExternalCode.loinc_scale_by_the_code("Nom")
        sh_loinc_code.diseases << disease
        sh_loinc_code.save!

        event.add_labs_from_staged_message StagedMessage.new(:hl7_message => HL7MESSAGES[:nist_orc_clinician])
        event.should be_valid
        event.clinicians.size.should == 1
        person_entity = event.clinicians.first.person_entity
        person_entity.person.last_name.should == 'Moreau'
        person_entity.person.first_name.should == 'Glenda'
        telephone = person_entity.telephones.first
        telephone.entity_location_type.should ==
          external_codes(:telephonelocationtype_work)
        telephone.area_code.should == '800'
        telephone.phone_number.should == '5551212'
        telephone.extension.should be_blank
      end
    end

    it 'should assign the same PersonEntity as a clinician to multiple events' do
      e1 = HumanEvent.new
      e2 = HumanEvent.new

      s1 = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_campylobacter_jejuni]
      s2 = StagedMessage.new :hl7_message => HL7MESSAGES[:realm_campylobacter_jejuni]

      e1.add_labs_from_staged_message s1
      e1.save!

      e2.add_labs_from_staged_message s2
      e2.save!

      e1.should be_valid
      e2.should be_valid

      e1.clinicians.size.should == 1
      e2.clinicians.size.should == 1

      e1.clinicians.first.person_entity.should == e2.clinicians.first.person_entity
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
      with_human_event do |event|
        event.build_disease_event(:disease_id => 1)
        event.save!
        event.reload
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
            event.labs.first.lab_results.first.test_result.code_description.downcase.include?(staged_message.observation_requests.first.tests.first.result.downcase).should be_true
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
            event.labs.first.lab_results[0].result_value.should == staged_message.observation_requests.first.tests[0].result
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
      event.labs.first.lab_results.first.test_result.code_description.downcase.include?(staged_message.observation_requests.first.tests.first.result.downcase).should be_true
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

  it 'should be valid to have an out of state patient with a LHD case status of out of state' do
    @event.address.county = external_codes(:county_oos)
    @event.lhd_case_status = external_codes(:case_status_oos)
    @event.should be_valid
  end

  it 'should be valid to have an out of state patient with a state case status of out of state' do
    @event.address.county = external_codes(:county_oos)
    @event.state_case_status = external_codes(:case_status_oos)
    @event.should be_valid
  end

  it 'should not be valid to have an out of state patient with a case status of confirmed' do
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

describe 'When added to an event using an existing person entity' do

  before(:each) do
    @user = Factory.create(:user)
    @person_entity = Factory.create(:person_entity)
    @person_event_hash = { :first_reported_PH_date => Date.yesterday.to_s(:db), :interested_party_attributes => { :primary_entity_id => "#{@person_entity.id}" } }
  end

  it "should receive the person entity's canonical address if one exists" do
    canonical_address = Factory.create(:address, :entity_id => @person_entity.id)
    event = MorbidityEvent.new(@person_event_hash)
    event.save!
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


describe "Getting a quick list of events" do
  before do
    @parent_event = Factory.create(:morbidity_event)
    @contact_event = Factory.create(:contact_event, :parent_event => @parent_event)
    @place_event = Factory.create(:place_event, :parent_event => @parent_event)
  end

  describe "children" do
    it "returns all events" do
      @parent_event.events_quick_list.size.should == 2
    end

    it "returns promoted contacts" do
      @promoted_event = Factory.create(:contact_event, :parent_event => @parent_event)
      login_as_super_user #need this to promote. pffft
      @promoted_event.promote_to_morbidity_event

      @parent_event.events_quick_list.size.should == 3
    end

    it "returns place events" do
      Factory.create(:place_event, :parent_event => @parent_event)
      @parent_event.events_quick_list.collect { |event| event if event.class.name == 'PlaceEvent' }.compact.size.should == 2
    end

    it "returns the events' names" do
      @parent_event.events_quick_list.each do |event|
        if event.class.name == "ContactEvent"
          event.full_name.should == @contact_event.interested_party.person_entity.person.full_name
        elsif event.class.name == "PlaceEvent"
          event.full_name.should == @place_event.interested_place.place_entity.place.name
        end
      end
    end
  end

  describe "siblings" do
    it "excludes 'self' from results" do
      @contact_event.events_quick_list.should == []
    end
  end
end

describe HumanEvent, "#possible_treatments" do
  before do
    @treatments = {}
    [{ :treatment_name => 'Shot', :active => true, :default => true },
     { :treatment_name => 'Beer', :active => true, :default => true },
     { :treatment_name => 'Leeches', :active => true, :default => false },
     { :treatment_name => 'Placebo', :active => false, :default => true }
    ].each do |attributes|
      @treatments[attributes[:treatment_name]] = Factory.create(:treatment, attributes)
    end
  end

  describe "when no disease is present" do
    shared_examples_for "an event listing default treatments" do
      it "returns all active, default treatments sorted by name" do
        @event.possible_treatments.map(&:treatment_name).should == ['Beer', 'Shot']
      end

      it "returns any treatments already associated w/ the event in sorted order" do
        @event.interested_party.treatments.create!(:treatment_id => @treatments['Leeches'].id)
        @event.possible_treatments.map(&:treatment_name).should == ['Beer', 'Leeches', 'Shot']
      end
    end

    describe "on a morbidity event" do
      before { @event = Factory.create(:morbidity_event) }
      it_should_behave_like "an event listing default treatments"
    end

    describe "on a contact event" do
      before { @event = Factory.create(:contact_event) }
      it_should_behave_like "an event listing default treatments"
    end

    describe "on an encounter event" do
      before { @event = Factory.create(:encounter_event) }
      it_should_behave_like "an event listing default treatments"
    end

  end

  describe "when a disease is present" do
    before do
      @disease = Factory.create(:disease)
      @disease.treatments << @treatments['Leeches']
      @disease.treatments << @treatments['Shot']
    end

    shared_examples_for "an event listing disease specific treatments" do
      it "returns treatments associated w/ the disease" do
        @event.possible_treatments.map(&:treatment_name).should == ['Leeches', 'Shot']
      end

      it "returns any treatment already associated w/ the event" do
        @event.interested_party.treatments.create!(:treatment_id =>  @treatments['Beer'].id)
        @event.possible_treatments.map(&:treatment_name).should == ['Beer', 'Leeches', 'Shot']
      end

      it "returns an empty array if no treatments are associated" do
        DiseaseSpecificTreatment.destroy_all
        ParticipationsTreatment.destroy_all
        @event.possible_treatments.should == []
      end
    end

    describe "on a morbidity event" do
      before do
        @event = Factory.create(:morbidity_event)
        @event.create_disease_event(:disease => @disease)
      end
      it_should_behave_like "an event listing disease specific treatments"
    end

    describe "on a contact event" do
      before do
        @event = Factory.create(:contact_event)
        @event.create_disease_event(:disease => @disease)
      end
      it_should_behave_like "an event listing disease specific treatments"
    end

    describe "on an encounter event" do
      before do
        @event = Factory.create(:encounter_event)
        @event.create_disease_event(:disease => @disease)
      end
      it_should_behave_like "an event listing disease specific treatments"
    end

  end
end
