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

  describe 'set_onset_date before validation' do
    before do
      module TestCdcExportAttributes
        attr_accessor :event_created_at, :first_reported_ph_date, :lab_test_dates, :lab_collection_dates, :disease_onset_date, :disease_event_date_diagnosed
      end
      @event = HumanEvent.new
      @event.extend TestCdcExportAttributes
    end

    it 'should pick the earliest lab_test_date' do
      @event.labs << Lab.new(:lab_results => [LabResult.new(:lab_test_date => Date.parse("2011-05-03"))])
      @event.labs << Lab.new(:lab_results => [LabResult.new(:lab_test_date => Date.parse("2012-01-01"), :collection_date => Date.parse("2011-12-30"))])
      @event.valid?
      @event.event_onset_date.should == Date.parse("2011-05-03")
    end

     it 'should pick the earliest lab_collection_date' do
      @event.labs << Lab.new(:lab_results => [LabResult.new(:lab_test_date => Date.parse("2011-05-03"))])
      @event.labs << Lab.new(:lab_results => [LabResult.new(:lab_test_date => Date.parse("2012-01-01"), :collection_date => Date.parse("2010-12-30"))])
      @event.valid?
      @event.event_onset_date.should == Date.parse("2010-12-30")
     end

    it 'should pick disease_onset_date if present' do
      @event.build_disease_event(:date_diagnosed => Date.parse("2012-05-01"), :disease_onset_date => Date.parse("2012-05-25"))
      @event.valid?
      @event.event_onset_date.should == Date.parse("2012-05-25")
    end

     it 'should pick disease_event_date_diagnosed if present' do
      @event.labs << Lab.new(:lab_results => [LabResult.new(:lab_test_date => Date.parse("2011-05-03"))])
      @event.labs << Lab.new(:lab_results => [LabResult.new(:collection_date => Date.parse("2010-12-30"))])
      @event.build_disease_event(:date_diagnosed => Date.parse("2012-05-25"))
      @event.valid?
      @event.event_onset_date.should == Date.parse("2012-05-25")
     end

     it 'should pick first_reported_ph_date over event created date' do
      @event.created_at =  Date.parse("2011-05-04")
      @event.first_reported_PH_date = Date.parse("2012-05-04")
      @event.valid?
      @event.event_onset_date.should == Date.parse("2012-05-04")
     end

    it 'should pick event_created_at date if nothing present' do
      @event.created_at =  Date.parse("2011-05-04")
      @event.valid?
      @event.event_onset_date.should == Date.parse("2011-05-04")
    end

    it 'should fallback to today if nothing present' do
      @event.valid?
      @event.event_onset_date.should == Date.today
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
