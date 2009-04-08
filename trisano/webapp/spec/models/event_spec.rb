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

describe MorbidityEvent do
  # fixtures :events, :participations, :entities, :places, :people, :lab_results, :hospitals_participations

  #  event_hash = {
  #    "active_patient" => {
  #      "person" => {
  #        "last_name"=>"Green"
  #      }
  #    }
  #  }

  def with_event(event_hash=@event_hash)
    event = MorbidityEvent.new event_hash
    event.save!
    event.reload
    yield event if block_given?
  end

  describe "associations" do
    it { should have_one(:jurisdiction) }
    it { should have_many(:associated_jurisdictions) }
    it { should have_many(:all_jurisdictions) }
    it { should have_one(:disease_event) }
    it { should belong_to(:event_queue) }
    it { should have_many(:form_references) }
    it { should have_many(:answers) }
    it { should have_many(:tasks) }
    it { should have_many(:notes) }
    it { should have_many(:participations) }
    it { should have_many(:place_child_events) }
    it { should have_many(:contact_child_events) }
    it { should have_many(:encounter_child_events) }
    it { should have_many(:child_events) }
    it { should belong_to(:parent_event) }
    it { should have_one(:address) }

    describe "nested attributes are assigned" do
      it { should accept_nested_attributes_for(:jurisdiction ) }
      it { should accept_nested_attributes_for(:disease_event) }
      it { should accept_nested_attributes_for(:contact_child_events) }
      it { should accept_nested_attributes_for(:place_child_events) }
      it { should accept_nested_attributes_for(:encounter_child_events) }
      it { should accept_nested_attributes_for(:notes) }
      it { should accept_nested_attributes_for(:address) }

      describe "destruction is allowed properly" do
        fixtures :events

        before(:each) do
          mock_user
          @event = MorbidityEvent.new
        end

        it "Should not allow the primary jurisdiction to be deleted via a nested attribute" do
          @event.build_jurisdiction
          @event.save
          @event.jurisdiction_attributes = { "_delete"=>"1" }
          @event.jurisdiction.should_not be_marked_for_destruction
        end

        it "Should not allow the disease event to be deleted via a nested attribute" do
          @event.build_disease_event
          @event.save
          @event.disease_event_attributes = { "_delete"=>"1" }
          @event.disease_event.should_not be_marked_for_destruction
        end

        it "Should allow contact child events to be deleted via a nested attribute" do
          @event.contact_child_events.build
          @event.save
          @event.contact_child_events_attributes = [ { "id" => "#{@event.contact_child_events[0].id}", "_delete"=>"1"} ]
          @event.contact_child_events[0].should be_marked_for_destruction
        end

        it "Should allow place child events to be deleted via a nested attribute" do
          @event.place_child_events.build
          @event.save
          @event.place_child_events_attributes = [ { "id" => "#{@event.place_child_events[0].id}", "_delete"=>"1"} ]
          @event.place_child_events[0].should be_marked_for_destruction
        end

        it "Should allow encounter child events to be deleted via a nested attribute" do
          @event.encounter_child_events.build
          @event.save
          @event.encounter_child_events_attributes = [ { "id" => "#{@event.encounter_child_events[0].id}", "_delete"=>"1"} ]
          @event.encounter_child_events[0].should be_marked_for_destruction
        end

        it "Should not allow notes to be deleted via a nested attribute" do
          @event.notes.build
          @event.save
          @event.notes_attributes = [ { "id" => "#{@event.notes[0].id}", "_delete"=>"1"} ]
          @event.notes[0].should_not be_marked_for_destruction
        end
      end

      describe "empty attributes are handled correctly" do
        fixtures :events, :entities, :places, :places_types

        before(:each) do
          @event = Event.new
        end

        it "should reject jurisdictions with no entity ID" do
          @event.jurisdiction_attributes = { "secondary_entity_id" => nil }
          @event.jurisdiction.should be_nil
        end

        it "should reject disease events with no information" do
          @event.disease_event_attributes = {}
          @event.disease_event.should be_nil
        end

        it "should reject contacts with no information" do
          @event.contact_child_events_attributes = [ { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name" => "" },
                  "telephones_attributes" => { "99" => { "phone_number" => "" } } } },
              "participations_contact_attributes" => {} } ]
          @event.contact_child_events.should be_empty
        end

        it "should not reject contacts with some information" do
          @event.contact_child_events_attributes = [ { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name" => "whatever" },
                  "telephones_attributes" => { "99" => { "phone_number" => "" } } } },
              "participations_contact_attributes" => {} } ]
          @event.contact_child_events.should_not be_empty
        end

        it "should reject place exposures with no information" do
          @event.place_child_events_attributes = [ { "interested_place_attributes" => { "place_entity_attributes" => { "place_attributes" => { "name" => "" } } },
              "participations_place_attributes" => {} } ]
          @event.place_child_events.should be_empty
        end

        it "should reject encounters with only a user and a location" do
          @event.encounter_child_events_attributes = [ { "participations_encounter_attributes" => { "user_id" => "1", "encounter_location_type" => "clinic" } } ]
          @event.encounter_child_events.should be_empty
        end

        it "should not reject encounters with a user, location, and date" do
          @event.encounter_child_events_attributes = [ { "participations_encounter_attributes" => { "user_id" => "1", "encounter_location_type" => "clinic", "encounter_date" => "March 11, 2009" } } ]
          @event.encounter_child_events.should_not be_empty
        end
      end
    end
  end

  describe "Managing associations." do

    describe "Handling notes" do
      fixtures :users

      describe "adding notes through add_note" do

        before(:each) do
          @event = MorbidityEvent.new()
          @user = users(:default_user)
          User.stub!(:current_user).and_return(@user)
          @event.save
        end
        
        it "should create an admin note by default" do
          @event.add_note("New note")
          @event.notes.first.note.should == "New note"
          @event.notes.first.note_type.should == "administrative"
        end

        it "should create a note of the provided type" do
          @event.add_note("New note", "clinical")
          @event.notes.first.note.should == "New note"
          @event.notes.first.note_type.should == "clinical"
        end
        
      end

    end
  end

  describe "Handling tasks" do
    fixtures :users

    before(:each) do
      @user = users(:default_user)
      User.stub!(:current_user).and_return(@user)
      @event = MorbidityEvent.new
      @event.save!
    end

    it "should create a new clinical note linked to the event if task notes are populated" do
      task = Task.new({
          :name => "Do it",
          :due_date => 1.day.from_now,
          :notes => "Some details",
          :event_id => @event.id
        })

      task.user_id = @user.id
      task.save.should_not be_nil

      @event.notes.reload
      @event.notes.size.should == 1

      @event.notes.collect { |note|
        if (note.note_type == "clinical")
          note
        end
      }.compact.size.should eql(1)

      @event.notes.collect { |note|
        if (note.note_type == "clinical")
          note
        end
      }.compact[0].note.should eql("Task created.\n\nName: Do it\nDescription: Some details")
      
    end

    it "should not create a new clinical note linked to the event if task notes are not populated" do
      task = Task.new({
          :name => "Do it",
          :due_date => 1.day.from_now,
          :event_id => @event.id,
          :user_id => @user.id
        })

      task.save.should_not be_nil
      @event.notes.reload
      @event.notes.size.should == 0
    end

  end

  describe "Routing an event" do
    fixtures :events, :participations, :entities, :addresses, :telephones, :people, :places, :places_types, :users, :participations_places

    before(:each) do
      @user = users(:default_user)
      User.stub!(:current_user).and_return(@user)
      @event = MorbidityEvent.find(events(:marks_cmr).id)
    end

    describe "with legitimate parameters" do

      it "should not raise an exception" do
        lambda { @event.route_to_jurisdiction(entities(:Davis_County)) }.should_not raise_error()
      end

      it "should change the jurisdiction" do
        @event.jurisdiction.place_entity.place.name.should == places(:Southeastern_District).name
        @event.route_to_jurisdiction(entities(:Davis_County).id)
        @event.jurisdiction.place_entity.place.name.should == places(:Davis_County).name
      end
    end

    describe "with bad parameters" do
      it "should raise an error if passed in a non-existant place" do
        lambda { @event.route_to_jurisdiction(99999) }.should raise_error()
      end

      it "should raise an error if passed in a place that is not a jurisdction" do
        lambda { @event.route_to_jurisdiction(entities(:AVH)) }.should raise_error()
      end
    end

    describe "with secondary jurisdictional assignment" do

      describe "adding jurisdictions" do

        it "should add the jurisdictions as secondary jurisdictions" do
          @event.route_to_jurisdiction(entities(:Southeastern_District).id, [entities(:Davis_County).id, entities(:Summit_County).id])
          @event.secondary_jurisdictions.length.should == 2 
          @event.secondary_jurisdictions.include?(places(:Davis_County)).should be_true
          @event.secondary_jurisdictions.include?(places(:Summit_County)).should be_true
        end
      end

      describe "removing jurisdictions" do
        it "should remove the secondary jurisdictions" do
          @event.route_to_jurisdiction(entities(:Southeastern_District).id, [entities(:Davis_County).id, entities(:Summit_County).id])
          @event.secondary_jurisdictions.length.should == 2 

          @event.route_to_jurisdiction(entities(:Southeastern_District).id, [entities(:Summit_County).id])
          @event.secondary_jurisdictions.length.should == 1 
          @event.secondary_jurisdictions.include?(places(:Davis_County)).should_not be_true
          @event.secondary_jurisdictions.include?(places(:Summit_County)).should be_true
        end
      end

      describe "adding some, removing others" do
        it "should add some and remove others" do
          # Start with summit and Southeastern
          @event.route_to_jurisdiction(entities(:Southeastern_District).id, [entities(:Summit_County).id, entities(:Southeastern_District).id])
          @event.secondary_jurisdictions.length.should == 2 
          @event.secondary_jurisdictions.include?(places(:Southeastern_District)).should be_true
          @event.secondary_jurisdictions.include?(places(:Summit_County)).should be_true
          @event.secondary_jurisdictions.include?(places(:Davis_County)).should_not be_true

          # Remove Southeastern, add Davis, Leave Summit alone
          @event.route_to_jurisdiction(entities(:Southeastern_District).id, [entities(:Davis_County).id, entities(:Summit_County).id])
          @event.secondary_jurisdictions.length.should == 2 
          @event.secondary_jurisdictions.include?(places(:Davis_County)).should be_true
          @event.secondary_jurisdictions.include?(places(:Summit_County)).should be_true
          @event.secondary_jurisdictions.include?(places(:Southeastern_District)).should_not be_true
        end
      end

    end

  end

  describe "Under investigation" do

    it "should not be under investigation if it is new" do
      event = MorbidityEvent.create
      event.should_not be_open_for_investigation
    end

    it "should be under investigation if set to under investigation" do
      event = MorbidityEvent.create :workflow_state => 'under_investigation'
      event = Event.find(event.id)
      event.should be_open_for_investigation
    end

    it "should be under investigation if reopened by manager" do
      event = MorbidityEvent.create :workflow_state => 'reopened_by_manager'
      event = Event.find(event.id)
      event.should be_open_for_investigation
    end

    it "should be under investigation if investigation is complete" do
      event = MorbidityEvent.create :workflow_state => 'investigation_complete'
      event = Event.find(event.id)
      event.should be_open_for_investigation
    end
  end

  describe "Saving an event" do
    it "should generate an event onset date set to today" do
      event = MorbidityEvent.new
      event.save.should be_true
      event.event_onset_date.should == Date.today
    end
  end

  describe "event transitions (events)" do
    it "should return assigned to lhd, investigation complete, and assigned to investigator when the state is re-opened by manager" do                   
      @event = MorbidityEvent.create(:workflow_state => 'reopened_by_manager')
      @event = Event.find @event.id
      @event.states(@event.state).events.should == [:assign_to_lhd, :reset_to_new, :assign_to_investigator, :complete]
    end
  end

  describe "state description" do
    before(:each) do
      @event = MorbidityEvent.create(:workflow_state => 'accepted_by_lhd')
      @event = Event.find(@event.id)
    end

    it "should come from the #state_description method" do
      @event.state_description.should == "Accepted by Local Health Dept."
    end

  end

  describe "The state transistions" do

    def updated_event(attribs={})
      @event.update_attributes attribs
      Event.find(@event.id)
    end

    before(:each) do
      @event = MorbidityEvent.create
      @permissive_jurisdiction = mock_model(Jurisdiction)
      @permissive_jurisdiction.stub!(:allows_current_user_to?).and_return(true)
      User.stub!(:current_user).and_return(nil) #just in case some old stubbin' is around
    end

    it "should be able to assign to an investigator, when accepted by lhd" do
      updated_event(:workflow_state => 'accepted_by_lhd').respond_to?(:assign_to_investigator).should be_true
    end

    it "should be able to investigate when accepted by lhd" do
      updated_event(:workflow_state => 'accepted_by_lhd').respond_to?(:investigate).should be_true
    end

    it "should not be able to investigate when rejected by lhd" do
      updated_event(:workflow_state => 'rejected_by_lhd').respond_to?(:investigate).should be_false
    end

    it 'should be able to investigate when rejected by investigator' do
      updated_event(:workflow_state => 'rejected_by_investigator').respond_to?(:investigate).should be_true
    end

    it 'should use \'new\' as the first state' do
      @event.workflow_state.should == 'new'
      @event.current_state.should == @event.states(:new)
      @event.current_state.events.should == [:assign_to_lhd, :reset_to_new]
    end

    it 'should be able to transition from :new to :assigned_to_lhd' do
      @event.should_receive(:jurisdiction).and_return @permissive_jurisdiction
      @event.should_receive(:route_to_jurisdiction)
      @event.assign_to_lhd
      @event.workflow_state.should == 'assigned_to_lhd'
      @event.current_state.name.should == :assigned_to_lhd
      @event.current_state.events.should == [:assign_to_lhd, :reset_to_new, :accept, :reject]
    end

    it 'should be to move between states, as allowed by transitions' do
      @event.stub!(:jurisdiction).and_return @permissive_jurisdiction
      @event.stub!(:route_to_jurisdiction)
      @event.stub!(:primary_jurisdiction).and_return nil
      @event.assign_to_lhd
      @event.current_state.name.should == :assigned_to_lhd
      @event.reset_to_new
      @event.current_state.name.should == :new
      @event.assign_to_lhd
      @event.current_state.name.should == :assigned_to_lhd
      @event.reject
      @event.current_state.name.should == :rejected_by_lhd
      @event.assign_to_lhd
      @event.current_state.name.should == :assigned_to_lhd
      @event.accept
      @event.current_state.name.should == :accepted_by_lhd
      @event.assign_to_investigator
      @event.current_state.name.should == :assigned_to_investigator
      @event.reject
      @event.current_state.name.should == :rejected_by_investigator
      @event.assign_to_investigator
      @event.current_state.name.should == :assigned_to_investigator
      @event.accept
      @event.current_state.name.should == :under_investigation
      @event.complete
      @event.current_state.name.should == :investigation_complete
      @event.approve
      @event.current_state.name.should == :approved_by_lhd
    end
  end

  describe "Support for investigation view elements" do

    def ref(form)
      ref = mock(FormReference)
      ref.should_receive(:form).and_return(form)
      ref
    end
    
    def investigation_form(is_a)
      form = mock(Form)
      form.stub!(:has_investigator_view_elements?).and_return(is_a)
      form
    end

    def prepare_event
      investigation_form = investigation_form(true)
      core_view_form = investigation_form(false)
      core_field_form = investigation_form(false)
      event = Event.new
      event.should_receive(:form_references).and_return([ref(core_field_form), ref(core_view_form), ref(investigation_form)])
      event
    end
    
    it "should only return refernces to forms that have investigation elements" do
      event = prepare_event
      event.investigation_form_references.size.should == 1
    end

  end

  describe 'with age info is already set' do
    before :each do
      @event_hash = {
        "age_at_onset" => 14,
        "age_type_id" => 2300,
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
              "birth_date" => Date.today.years_ago(14)
            }
          }
        }
      }
    end

    it 'should aggregate onset age and age type in age info' do
      with_event do |event|
        event.age_info.should_not be_nil
        event.age_info.age_at_onset.should == 14
        event.age_info.age_type.code_description.should == 'years'
      end
    end

  end

  describe 'just created' do
    before :each do
      @event_hash = {
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
              "birth_date" => Date.today.years_ago(14)
            }
          }
        }
      }
    end

    it 'should not generate an age at onset if the birthdate is unknown' do
      @event_hash['interested_party_attributes']['person_entity_attributes']['person_attributes']['birth_date'] = nil
      with_event do |event|
        event.age_info.should_not be_nil
        event.age_info.age_type.code_description.should == 'unknown'
        event.age_info.age_at_onset.should be_nil
      end
    end

    it 'should generate an age at onset if the birthday is known' do
      with_event do |event|
        event.interested_party.person_entity.person.birth_date.should_not be_nil
        event.event_onset_date.should_not be_nil
        event.age_info.age_at_onset.should == 14
        event.age_info.age_type.code_description.should == 'years'
      end
    end

    describe 'generating age at onset from earliest encounter date' do

      it 'should use the disease onset date' do
        onset = Date.today.years_ago(3)
        @event_hash['disease_event_attributes'] = {'disease_onset_date' => onset }
        with_event do |event|
          event.age_info.age_at_onset.should == 11
          event.age_info.age_type.code_description.should == 'years'
        end
      end        

      it 'should use the date the disease was diagnosed' do
        date_diagnosed = Date.today.years_ago(3)
        @event_hash['disease_event_attributes'] = {'date_diagnosed' => date_diagnosed }
        with_event do |event|
          event.age_info.age_at_onset.should == 11
          event.age_info.age_type.code_description.should == 'years'
        end
      end

      it 'should use the lab collection date' do
        @event_hash["labs_attributes"] = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "Quest" } }, 
            "lab_results_attributes" => [ { "test_type" => "culture", "lab_result_text" => "whatever", "collection_date" => Date.today.years_ago(1) } ] } ]
        with_event do |event|
          event.labs.count.should == 1
          event.age_info.age_at_onset.should == 13
        end
      end

      it 'should use the earliest lab collection date' do
        @event_hash["labs_attributes"] = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "Quest" } }, 
            "lab_results_attributes" => [ { "test_type" => "culture", "lab_result_text" => "pos", "collection_date" => Date.today.years_ago(1) } ] },
          { "place_entity_attributes" => { "place_attributes" => { "name" => "Merck" } },
            "lab_results_attributes" => [ { "test_type" => "culture", "lab_result_text" => "neg", "collection_date" => Date.today.months_ago(18) } ] } ]
        with_event do |event|
          event.labs.count.should == 2
          event.age_info.age_at_onset.should == 12
        end
      end

      it 'should use the lab test date' do
        @event_hash["labs_attributes"] = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "Quest" } }, 
            "lab_results_attributes" => [ { "test_type" => "culture", "lab_result_text" => "whatever", "lab_test_date" => Date.today.years_ago(1) } ] } ]
        with_event do |event|
          event.labs.count.should == 1
          event.age_info.age_at_onset.should == 13
        end
      end

      it 'should use the earliet lab test date' do
        @event_hash["labs_attributes"] = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "Quest" } }, 
            "lab_results_attributes" => [ { "test_type" => "culture", "lab_result_text" => "pos", "lab_test_date" => Date.today.years_ago(1) } ] },
          { "place_entity_attributes" => { "place_attributes" => { "name" => "Merck" } },
            "lab_results_attributes" => [ { "test_type" => "culture", "lab_result_text" => "neg", "lab_test_date" => Date.today.months_ago(18) } ] } ]
        with_event do |event|
          event.labs.count.should == 2
          event.age_info.age_at_onset.should == 12
        end
      end

      it 'should use the earliest lab collection date' do
        @event_hash["labs_attributes"] = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "Quest" } }, 
            "lab_results_attributes" => [ { "test_type" => "culture", "lab_result_text" => "pos",
                "collection_date" => Date.today.years_ago(1), "lab_test_date" => Date.today.years_ago(1) } ] },
          { "place_entity_attributes" => { "place_attributes" => { "name" => "Merck" } },
            "lab_results_attributes" => [ { "test_type" => "culture", "lab_result_text" => "neg",
                "collection_date" => Date.today.years_ago(3), "lab_test_date" => Date.today.months_ago(18) } ] } ]
        with_event do |event|
          event.labs.count.should == 2
          event.age_info.age_at_onset.should == 11
        end
      end

      it 'should use the first reported public health date (if its the earliest)' do
        @event_hash['first_reported_PH_date'] = Date.today.months_ago(6)
        with_event do |event|
          event.age_info.age_at_onset.should == 13
        end
      end
      
    end

  end      

  describe 'checking CDC and IBIS export' do

    before :each do
      mock_user
      @event_hash = {
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel"
            }
          }
        }
      }
    end

    it 'should return false for a new record, not yet sent to cdc or ibis' do
      with_event do |event|
        event.should_not be_a_new_record
        event.cdc_updated_at.should be_nil
        event.ibis_updated_at.should be_nil
        event.should_not be_sent_to_cdc
        event.should_not be_sent_to_ibis
      end
    end

    it 'should set cdc and ibis update when first_reported_PH_date value changes if already sent' do
      with_event do |event|
        event.cdc_updated_at.should be_nil
        event.first_reported_PH_date = Date.today - 1
        event.save.should be_true
        event.cdc_updated_at.should be_nil
        event.ibis_updated_at.should be_nil

        event.sent_to_cdc = event.sent_to_ibis = true
        event.first_reported_PH_date = Date.today
        event.save.should be_true
        event.cdc_updated_at.should == Date.today
        event.ibis_updated_at.should == Date.today
      end
    end

    it 'should set cdc and ibis update date when state case status id changes' do
      with_event do |event|
        event.sent_to_cdc = event.sent_to_ibis = true
        event.state_case_status = ExternalCode.find(:first, :conditions => "code_name = 'case'")
        event.save.should be_true
        event.cdc_updated_at.should == Date.today
        event.ibis_updated_at.should == Date.today
      end
    end
       
    it 'should set cdc and ibis update when event deleted' do
      with_event do |event|
        event.sent_to_cdc = event.sent_to_ibis = true
        event.soft_delete
        event.save.should be_true
        event.cdc_updated_at.should == Date.today
        event.ibis_updated_at.should == Date.today
      end
    end
  end
  
  describe "when exporting to IBIS" do
    describe " and finding records to be exported" do

      fixtures :events, :diseases, :disease_events

      before :each do
        confirmed = external_codes(:case_status_confirmed)
        discarded = external_codes(:case_status_discarded)
        anthrax = diseases(:anthrax)

        # NON_IBIS: Not sent to IBIS, no disease, not confirmed
        MorbidityEvent.create( { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Ibis1" } } },
            "event_name" => "Ibis1" } )
        # NON_IBIS: Not sent to IBIS, has disease, not confirmed
        MorbidityEvent.create( { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Ibis2" } } },
            "disease_event_attributes" => { "disease_id" => anthrax.id },
            "event_name" => "Ibis2" } )
        # NEW: Not sent to IBIS, has disease, confirmed
        MorbidityEvent.create( { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Ibis3" } } },
            "disease_event_attributes" => { "disease_id" => anthrax.id },
            "state_case_status_id" => confirmed.id,
            "event_name" => "Ibis3" } )
        # UPDATED: Sent to IBIS, has disease, confirmed
        MorbidityEvent.create( { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Ibis4" } } }, 
            "disease_event_attributes" => { "disease_id" => anthrax.id },
            "state_case_status_id" => confirmed.id,
            "sent_to_ibis" => true,
            "ibis_updated_at" => Date.today,
            "event_name" => "Ibis4" } )
        # DELETED: Sent to IBIS, has disease, not confirmed
        MorbidityEvent.create( { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Ibis4" } } }, 
            "disease_event_attributes" => { "disease_id" => anthrax.id },
            "state_case_status_id" => discarded.id,
            "sent_to_ibis" => true,
            "ibis_updated_at" => Date.today,
            "event_name" => "Ibis5" } )
        # DELETED: Sent to IBIS, has disease, confirmed but deleted
        MorbidityEvent.create( { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Ibis4" } } }, 
            "disease_event_attributes" => { "disease_id" => anthrax.id },
            "state_case_status_id" => confirmed.id,
            "sent_to_ibis" => true,
            "ibis_updated_at" => Date.today,
            "event_name" => "Ibis5",
            "deleted_at" => Time.now } )
      end

      it "should find active (new and updated) records" do
        events = Event.active_ibis_records(Date.today - 1, Date.today + 1)
        events.size.should == 3   # 2 above and 1 in the fixtures
        events.collect! { |event| Event.find(event.event_id) }
        event_names = events.collect { |event| event.event_name }
        event_names.include?("Marks Chicken Pox").should be_true
        event_names.include?("Ibis3").should be_true
        event_names.include?("Ibis4").should be_true
      end

      it "should find deleted records" do
        events = Event.deleted_ibis_records(Date.today - 1, Date.today + 1)
        events.collect! { |event| Event.find(event.event_id) }
        events.size.should == 2
        events.first.event_name.should ==  "Ibis5"
      end

      it "should find all IBIS exportable records" do
        events = Event.exportable_ibis_records(Date.today - 1, Date.today + 1)
        events.collect! { |event| Event.find(event.event_id) }
        events.size.should == 5   # 4 above and 1 in the fixtures
        event_names = events.collect { |event| event.event_name }
        event_names.include?("Marks Chicken Pox").should be_true
        event_names.include?("Ibis3").should be_true
        event_names.include?("Ibis4").should be_true
        event_names.include?("Ibis5").should be_true
      end
    end
  end

  describe 'when executing a view-filtering search' do

    fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements, :diseases, :disease_events, :places, :places_types, :participations, :event_queues, :people

    before :each do
      
      jurisdiction_id = role_memberships(:default_user_admin_role_southeastern_district).jurisdiction_id
      
      @user = users(:default_user)
      @user.stub!(:jurisdiction_ids_for_privilege).and_return([jurisdiction_id])
      User.stub!(:current_user).and_return(@user)
      MorbidityEvent.stub!(:get_allowed_queues).and_return([[1], ["Speedy-BearRiver"]])
      
      @event_hash = {
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
              "birth_date" => Date.today.years_ago(14)
            }
          }
        },
        "jurisdiction_attributes" => {
          "secondary_entity_id" => jurisdiction_id
        }
      }
    end

    # The following specs add a couple more events in addition to what is in the fixtures. If the results are off,
    # take a look at the events bootstrapped here, and what is set up in the fixtures, paying attention too, to
    # the jurisdiction_id, which is included in the search criteria.
    
    it 'should filter by disease and the other attributes' do
      @event_hash['disease_event_attributes'] = {'disease_id' => 1 }
      MorbidityEvent.create(@event_hash)

      @event_hash['event_queue_id'] = 1
      MorbidityEvent.create(@event_hash)
      
      @event_hash['workflow_state'] = 'closed'
      MorbidityEvent.create(@event_hash)

      @event_hash['investigator_id'] = 1
      m = MorbidityEvent.create(@event_hash)

      # make sure EncounterEvent doesn't show up. 
      EncounterEvent.create(:parent_id => m.id)

      MorbidityEvent.find_all_for_filtered_view.size.should == 6
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1]}).size.should == 5
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :queues => [1], :states => ['new']}).size.should == 1
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :queues => [1], :states => ['closed']}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['closed']}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :queues => [1], :states => ['closed'], :investigators => [1]}).size.should == 1
    end
    
    it 'should filter by state and the other attributes' do
      @event_hash['workflow_state'] = 'closed'
      MorbidityEvent.create(@event_hash)
      
      @event_hash['disease_event_attributes'] = {'disease_id' => 1 }
      MorbidityEvent.create(@event_hash)

      @event_hash['event_queue_id'] = 1
      MorbidityEvent.create(@event_hash)
      
      @event_hash['investigator_id'] = 1
      MorbidityEvent.create(@event_hash)

      MorbidityEvent.find_all_for_filtered_view.size.should == 6
      MorbidityEvent.find_all_for_filtered_view({:states => ['closed']}).size.should == 4
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['closed']}).size.should == 3
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['closed'], :queues => [1]}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['closed'], :queues => [1], :investigators => [1]}).size.should == 1
    end
    
    it 'should filter by queue and the other attributes' do
      @event_hash['event_queue_id'] = 1
      MorbidityEvent.create(@event_hash)
      
      @event_hash['workflow_state'] = 'closed'
      MorbidityEvent.create(@event_hash)
      
      @event_hash['disease_event_attributes'] = {'disease_id' => 1 }
      MorbidityEvent.create(@event_hash)
      
      @event_hash['investigator_id'] = 1
      MorbidityEvent.create(@event_hash)

      MorbidityEvent.find_all_for_filtered_view.size.should == 6
      MorbidityEvent.find_all_for_filtered_view({:queues => [1]}).size.should == 4
      MorbidityEvent.find_all_for_filtered_view({:queues => [1], :states => ['closed']}).size.should == 3
      MorbidityEvent.find_all_for_filtered_view({:queues => [1], :states => ['closed'], :diseases => [1]}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:queues => [1], :states => ['closed'], :diseases => [1], :investigators => [1]}).size.should == 1
    end

    it "should filter by investigator and the other attributes" do
      @event_hash['investigator_id'] = 1
      MorbidityEvent.create(@event_hash)
      
      @event_hash['workflow_state'] = 'closed'
      MorbidityEvent.create(@event_hash)
      
      @event_hash['disease_event_attributes'] = {'disease_id' => 1 }
      MorbidityEvent.create(@event_hash)
      
      @event_hash['event_queue_id'] = 1
      MorbidityEvent.create(@event_hash)

      MorbidityEvent.find_all_for_filtered_view.size.should == 6
      MorbidityEvent.find_all_for_filtered_view({:investigators => [1]}).size.should == 4
      MorbidityEvent.find_all_for_filtered_view({:investigators => [1], :states => ['closed']}).size.should == 3
      MorbidityEvent.find_all_for_filtered_view({:investigators => [1], :states => ['closed'], :diseases => [1]}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:investigators => [1], :states => ['closed'], :diseases => [1], :queues => [1]}).size.should == 1
    end

    it "should not show deleted records if told so" do
      @event_hash['investigator_id'] = 1
      MorbidityEvent.create(@event_hash)
      
      @event_hash['workflow_state'] = 'closed'
      MorbidityEvent.create(@event_hash)
      
      @event_hash['disease_event_attributes'] = {'disease_id' => 1 }
      MorbidityEvent.create(@event_hash)
      
      @event_hash['event_queue_id'] = 1
      a = MorbidityEvent.create(@event_hash)
      a.soft_delete

      MorbidityEvent.find_all_for_filtered_view.size.should == 6
      MorbidityEvent.find_all_for_filtered_view({:do_not_show_deleted => [1], :investigators => [1]}).size.should == 3
      MorbidityEvent.find_all_for_filtered_view({:do_not_show_deleted => [1], :investigators => [1], :states => ['closed']}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:do_not_show_deleted => [1], :investigators => [1], :states => ['closed'], :diseases => [1]}).size.should == 1
      MorbidityEvent.find_all_for_filtered_view({:do_not_show_deleted => [1], :investigators => [1], :states => ['closed'], :diseases => [1], :queues => [1]}).size.should == 0
    end

    it "should sort appropriately" do
      @user.stub!(:jurisdiction_ids_for_privilege).and_return([places(:Southeastern_District).entity_id, 
          places(:Davis_County).entity_id,
          places(:Summit_County).entity_id])

      @event_hash['workflow_state'] = 'new'
      @event_hash['disease_event_attributes'] = {'disease_id' => diseases(:chicken_pox).id }
      MorbidityEvent.create(@event_hash)
      
      @event_hash['workflow_state'] = 'closed'
      @event_hash['disease_event_attributes'] = {'disease_id' => diseases(:anthrax).id }
      @event_hash.merge!("interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Zulu" } } } )
      @event_hash.merge!("jurisdiction_attributes" => {"secondary_entity_id" => places(:Davis_County).entity_id})
      MorbidityEvent.create(@event_hash)
      
      @event_hash['workflow_state'] = 'under_investigation'
      @event_hash['disease_event_attributes'] = {'disease_id' => 1 }
      @event_hash['disease_event_attributes'] = {'disease_id' => diseases(:tuberculosis).id }
      @event_hash.merge!("interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Lima" } } } )
      @event_hash.merge!("jurisdiction_attributes" => {"secondary_entity_id" => places(:Summit_County).entity_id})
      MorbidityEvent.create(@event_hash)

      events = MorbidityEvent.find_all_for_filtered_view(:order_by => 'patient')
      last_names = events.collect { |event| event.interested_party.person_entity.person.last_name }
      last_names.should == last_names.sort

      events = MorbidityEvent.find_all_for_filtered_view(:order_by => 'jurisdiction')
      jurisdictions = events.collect { |event| event.jurisdiction.place_entity.place.name }
      jurisdictions.should == jurisdictions.sort

      events = MorbidityEvent.find_all_for_filtered_view(:order_by => 'disease')
      diseases = events.collect { |event| event.disease_event.disease.disease_name if event.disease_event }
      jurisdictions.should == jurisdictions.sort

      events = MorbidityEvent.find_all_for_filtered_view(:order_by => 'status')
      states = events.collect { |event| event.workflow_state }
      states.should == states.sort
    end

    it 'should set the query string on the user if the view change is to be the default' do
      @event_hash['event_queue_id'] = 1
      MorbidityEvent.create(@event_hash)
            
      HumanEvent.find_all_for_filtered_view.size.should == 3
      @user.should_receive(:update_attribute)
      HumanEvent.find_all_for_filtered_view({:queues => ["Enterics-BearRiver"], :set_as_default_view => "1"}).size.should == 1
    end

  end

  describe 'form builder cdc export fields' do
    fixtures :diseases, :export_conversion_values, :export_columns

    before(:each) do
      @question = Question.create(:data_type => 'radio_button', :question_text => 'Contact?', :short_name => "contact" )
      @question_element = QuestionElement.create(:question => @question)
      @event = MorbidityEvent.create( { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"CdcExportHep", } } }, 
          "disease_event_attributes"        => { "disease_id" => diseases(:hep_a).id },
          "event_name"     => "CdcExportHepA",
          "new_radio_buttons" => { @question.id.to_s => {:radio_button_answer => ['Unknown'], :export_conversion_value_id => export_conversion_values(:jaundiced_unknown).id } }
        } )
    end

    it "should have one answer" do
      Answer.find(:all).length.should == 1
    end

    it "should have an export conversion value" do
      answer = @event.answers.find_by_question_id(@question.id)
      answer.export_conversion_value.should_not be_nil
    end

    it "should have the correct export conversion value" do
      answer = @event.answers.find_by_question_id(@question.id)
      answer.export_conversion_value.value_from.should == 'Unknown'
      answer.export_conversion_value.value_to.should == '9'
    end

    it "should have insert the answer value in the correct field location" do
      answer = @event.answers.export_answers.first
      result = ''
      answer.write_export_conversion_to(result)
      result.length.should == 69
      result.last.should == '9'
    end
   
  end                      

  describe 'updating longitudinal data' do
    before :each do
      @event_hash = {
        "address_attributes" => { "street_name" => "Example Lane" },
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
            }
          }
        }
      }
    end

    it 'should associate address with interested party\'s person_entity on create' do
      with_event do |event|
        event.interested_party.person_entity.person.last_name.should == 'Biel'
        event.interested_party.primary_entity_id.should_not be_nil
        event.address.entity_id.should_not be_nil
        event.address.entity.person.last_name.should == "Biel"
      end
    end

    it 'should associate address with interested party\'s person_entity on save' do
      @event_hash.delete("address_attributes")
      with_event do |event|
        event.update_attributes("address_attributes" => { "street_name" => 'freshy' })
        event.address.entity_id.should_not be_nil
      end
    end
  end

  describe "adding forms to an event" do

    describe "an event without forms already" do
      fixtures :events, :forms

      before(:each) do
        @event = events(:has_anthrax_cmr)
        @form_ids = [forms(:anthrax_form_all_jurisdictions_1), forms(:anthrax_form_all_jurisdictions_2)].map { |form| form.id }
      end

      it "should add new forms" do
        @event.add_forms(@form_ids)
        event_form_ids = @event.form_references.map { |ref| ref.form_id }
        (event_form_ids & @form_ids).sort.should == @form_ids.sort
      end

      it "should add 'viable' forms" do
        @event.get_investigation_forms
        viable_form_ids = @event.form_references.map { |ref| ref.form_id }
        @event = events(:has_anthrax_cmr)

        @event.add_forms(@form_ids)
        event_form_ids = @event.form_references.map { |ref| ref.form_id }
        (event_form_ids & viable_form_ids).sort.should == viable_form_ids.sort
      end

    end

    describe "an event with existing forms" do
      fixtures :events, :forms, :form_references

      before(:each) do
        @event = events(:marks_cmr)
        @form_ids = [forms(:anthrax_form_all_jurisdictions_1), forms(:anthrax_form_all_jurisdictions_2)].map { |form| form.id }
        @form_ids << form_references(:marks_form_reference_1).form_id
      end

      it "should add new forms with no dups" do
        @event.add_forms(@form_ids)
        event_form_ids = @event.form_references.map { |ref| ref.form_id }
        (event_form_ids & @form_ids).sort.should == @form_ids.sort
      end

    end

    describe "argument handling" do
      fixtures :events, :forms

      before(:each) do
        @event = events(:marks_cmr)
      end

      it "should raise an error if form does not exist" do
        lambda { @event.add_forms([999]) }.should raise_error()
      end

      it "should accept a single non-array element" do
        lambda { @event.add_forms(forms(:anthrax_form_all_jurisdictions_1).id) }.should_not raise_error()
      end

      it "should accept forms and not just form IDs" do
        lambda { @event.add_forms(forms(:anthrax_form_all_jurisdictions_1)) }.should_not raise_error()
      end
    end

  end
  
  describe "when soft deleting" do
    fixtures :users

    before(:each) do
      @user = users(:default_user)
      User.stub!(:current_user).and_return(@user)
      @event_hash = {
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Green"
            }
          }
        },
        "contact_child_events_attributes" => [ { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name" => "White" },
                "telephones_attributes" => { "99" => { "phone_number" => "" } } } },
            "participations_contact_attributes" => {} } ],
        "place_child_events_attributes"   => [ { "interested_place_attributes" => { "place_entity_attributes" => { "place_attributes" => { "name" => "Red" } } },
            "participations_place_attributes" => {} } ]
      }
      @event = MorbidityEvent.new(@event_hash)
    end

    it "should give an active event a deleted_at time" do
      result = @event.soft_delete
      result.should be_true
      @event.deleted_at.should_not be_nil
      @event.deleted_at.class.name.should eql("Time")
    end
    
    it "should return nil when trying to delete an already soft-deleted form" do
      result = @event.soft_delete
      result.should be_true
      first_delete_time = @event.deleted_at
      result = @event.soft_delete
      result.should be_nil
      @event.deleted_at.should_not be_nil
      @event.deleted_at.should eql(first_delete_time)
    end

    it "should delete all children" do
      @event.child_events.each { |event| event.deleted_at.should be_nil }
      @event.soft_delete
      @event.child_events.each { |event| event.deleted_at.should_not be_nil }
    end
  end

  describe 'find by criteria' do
    before(:all) do
      # a little hack because PG adapters don't consistently escape single quotes      
      begin
        PostgresPR
        @oreilly_string = "o\\\\'reilly"
      rescue
        @oreilly_string = "o''reilly"
      end
      @event_hash = {
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Green"
            }
          }
        },
        "jurisdiction_attributes" => {
          "secondary_entity_id" => 1
        }
      }
    end

    it 'should include soundex codes for fulltext search' do
      where_clause, x, y = Event.generate_event_search_where_clause(:fulltext_terms => "davis o'reilly", :jurisdiction_id => 1)
      where_clause.should =~ /'davis \| #@oreilly_string \| #{'davis'.to_soundex.downcase} \| #{"o'reilly".to_soundex.downcase}'/
    end

    describe 'searching for cases by disease' do
      fixtures :diseases
      before(:each) do
        with_event(@event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:chicken_pox).id }))
        with_event(@event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:tuberculosis).id}))
        with_event(@event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:anthrax).id}))
      end

      it 'should be done with a single disease' do
        Event.find_by_criteria(:diseases => [diseases(:chicken_pox).id], :jurisdiction_id => '1').size.should == 1
      end
    
      it 'should be done with multiple diseases' do
        Event.find_by_criteria(:diseases => [diseases(:chicken_pox).id, diseases(:tuberculosis).id], :jurisdiction_id => '1').size.should == 2
      end

      it 'should ignore empty disease arrays' do
        Event.find_by_criteria(:diseases => [], :jurisdiction_id => '1').size.should == 3
      end
    end
    
  end
end

describe Event, 'pagination' do
  
  it 'should default to 25 records per page' do
    Event.per_page.should == 25
  end

end

describe Event, 'declarative task, attachment support' do

  it 'should indicate that mobidity events support tasks and attachments' do
    morbidity_event = MorbidityEvent.new
    morbidity_event.supports_attachments?.should be_true
    morbidity_event.supports_tasks?.should be_true
  end

  it 'should indicate that contact events support tasks and attachments' do
    contact_event = ContactEvent.new
    contact_event.supports_attachments?.should be_true
    contact_event.supports_tasks?.should be_true
  end

  it 'should indicate that place events do not support tasks and attachments' do
    place_event = PlaceEvent.new
    place_event.supports_attachments?.should be_false
    place_event.supports_tasks?.should be_false
  end

  it 'should indicate that encounter events not not support tasks and attachments' do
    encounter_event = EncounterEvent.new
    encounter_event.supports_attachments?.should be_false
    encounter_event.supports_tasks?.should be_false
  end
  
end

describe Event, 'cloning an event' do
  fixtures :users, :places, :places_types, :diseases, :entities

  before :each do
    User.stub!(:current_user).and_return(users(:default_user))

    @event_hash = {
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => {
            "last_name"=>"Biel",
          }
        }
      }
    }
  end

  describe "shallow clone" do
    before :each do
      @event_hash["address_attributes"] = { "street_name" => "Example Lane" }
      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event
    end

    it "should copy over demographic information only" do
      @new_event.interested_party.secondary_entity_id.should == @org_event.interested_party.secondary_entity_id
      @new_event.primary_jurisdiction.name.should == "Unassigned"
      @new_event.should be_new

      # Only interested party and jurisdiction, nothing else
      lambda {@new_event.save!}.should change(Participation, :count).by(2)

    end

    it "should create a new address instance and link it up" do
      lambda {@new_event.save!}.should change(Address, :count)
      @new_event.address.id.should_not == @org_event.address.id
      @new_event.address.street_name.should == 'Example Lane'
    end

  end

  describe "deep clone" do
    it "should first do a shallow clone" do
      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event

      @new_event.interested_party.secondary_entity_id.should == @org_event.interested_party.secondary_entity_id
      @new_event.primary_jurisdiction.name.should == "Unassigned"
      @new_event.should be_new
    end

    it "should copy over disease information, but not the actual disease" do
      @event_hash["disease_event_attributes"] = {:disease_id => diseases(:chicken_pox).id, 
                                                 :hospitalized_id => external_codes(:yesno_yes), 
                                                 :died_id => external_codes(:yesno_no),
                                                 :disease_onset_date => Date.today - 1, 
                                                 :date_diagnosed => Date.today
                                                }
      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @new_event.disease_event.disease_id.should be_blank
      @new_event.disease_event.hospitalized_id.should == @org_event.disease_event.hospitalized_id
      @new_event.disease_event.died_id.should == @org_event.disease_event.died_id
      @new_event.disease_event.disease_onset_date.should == @org_event.disease_event.disease_onset_date
      @new_event.disease_event.date_diagnosed.should == @org_event.disease_event.date_diagnosed
    end

    it "should copy over hospitalization data" do
      @event_hash["hospitalization_facilities_attributes"] = [
        {
          :secondary_entity_id => entities(:AVH).id, 
          :hospitals_participation_attributes => {
            :admission_date => Date.today - 4,
            :discharge_date => Date.today - 3,
            :medical_record_number => "1234"
          } 
        },
        {
          :secondary_entity_id => entities(:BRVH).id, 
          :hospitals_participation_attributes => {
            :admission_date => Date.today - 2,
            :discharge_date => Date.today - 1,
            :medical_record_number => "5678"
          } 
        }
      ]
      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @new_event.hospitalization_facilities.size.should == 2
      @new_event.hospitalization_facilities.each do |h|
        if h.secondary_entity_id == entities(:AVH).id
          h.hospitals_participation.admission_date.should == Date.today - 4
          h.hospitals_participation.discharge_date.should == Date.today - 3
          h.hospitals_participation.medical_record_number == "1234"
        elsif h.secondary_entity_id == entities(:BRVH).id
          h.hospitals_participation.admission_date.should == Date.today - 2
          h.hospitals_participation.discharge_date.should == Date.today - 1
          h.hospitals_participation.medical_record_number == "5678"
        else
          # Forcing a stupid error, we should not get here.
          "hosiptalization facilites".should == "AVH and BRVH"
        end
      end
    end

    it "should copy over treatment data" do
      @event_hash["interested_party_attributes"]["treatments_attributes"] =
        [
          {
            :treatment_given_yn_id => external_codes(:yesno_no).id,
            :treatment_date => Date.today,
            :treatment => "Leeches"
          },
          {
            :treatment_given_yn_id => external_codes(:yesno_yes).id,
            :treatment_date => Date.today - 1,
            :treatment => "Maggots"
          }
      ] 
      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @new_event.interested_party.treatments.size.should == 2
      @new_event.interested_party.treatments.each do |t|
        if t.treatment == "Leeches"
          t.treatment_given_yn_id.should == external_codes(:yesno_no).id
          t.treatment_date.should == Date.today
        elsif t.treatment == "Maggots"
          t.treatment_given_yn_id.should == external_codes(:yesno_yes).id
          t.treatment_date.should == Date.today - 1
        else
          # Forcing a stupid error, we should not get here.
          "treatments ".should == "Leecehs and Maggots"
        end
      end
    end

    it "should copy over risk factor data" do 
      @event_hash["interested_party_attributes"]["risk_factor_attributes"] =
          {
            :food_handler_id => external_codes(:yesno_no).id,
            :healthcare_worker_id => external_codes(:yesno_yes).id,
            :group_living_id => external_codes(:yesno_no).id,
            :day_care_association_id => external_codes(:yesno_yes).id,
            :pregnant_id => external_codes(:yesno_no).id,
            :pregnancy_due_date => Date.today ,
            :risk_factors => "Smokes",
            :risk_factors_notes => "A lot",
            :occupation => "Smoker"
          }

      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      org_rf = @org_event.interested_party.risk_factor
      new_rf = @new_event.interested_party.risk_factor

      org_rf.food_handler_id.should == new_rf.food_handler_id
      org_rf.healthcare_worker_id.should == new_rf.healthcare_worker_id
      org_rf.group_living_id.should == new_rf.group_living_id
      org_rf.day_care_association_id.should == new_rf.day_care_association_id
      org_rf.pregnant_id.should == new_rf.pregnant_id
      org_rf.risk_factors.should == new_rf.risk_factors
      org_rf.risk_factors_notes.should == new_rf.risk_factors_notes
      org_rf.occupation.should == new_rf.occupation
   end

    it "should copy over clinician data" do
      @event_hash["clinicians_attributes"] = [
        "person_entity_attributes" => {
          "person_attributes" => {
            "last_name"=>"Bombay",
            "person_type" => 'clinician'
          }
        }
      ]

      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @org_event.clinicians.first.secondary_entity_id.should == @new_event.clinicians.first.secondary_entity_id
    end

    it "should copy over diagnostic data" do
       @event_hash["diagnostic_facilities_attributes"] = [
        "place_entity_attributes" => {
          "place_attributes" => {
            "name"=>"DiagOne",
          }
        }
      ]

      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @org_event.diagnostic_facilities.first.secondary_entity_id.should == @new_event.diagnostic_facilities.first.secondary_entity_id
    end

    it "should copy over lab data" do
      @event_hash["labs_attributes"] = [
        { 
          "place_entity_attributes" => {
            "place_attributes" => {
              "name"=>"LabOne",
            }
          },
          "lab_results_attributes" => [
            { "specimen_source_id" => external_codes(:specimen_blood),
              "collection_date" => Date.today,
              "lab_test_date" => Date.today,
              "specimen_sent_to_uphl_yn_id" => external_codes(:yesno_yes),
              "lab_result_text" => "Scary",
              "test_type" => "Painful",
              "test_detail" => "Blood drawn",
              "interpretation_id" => external_codes(:state_alaska), # It's not really important what it is, just that it's there.  Tired of adding fixtures.
              "reference_range" => "one"
            }
          ]
        }
      ]

      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['lab'])

      @org_event.labs.first.secondary_entity_id.should == @new_event.labs.first.secondary_entity_id
      
      org_result = @org_event.labs.first.lab_results.first
      new_result = @new_event.labs.first.lab_results.first

      org_result.specimen_source_id.should == new_result.specimen_source_id 
      org_result.collection_date.should == new_result.collection_date 
      org_result.lab_test_date.should == new_result.lab_test_date 
      org_result.specimen_sent_to_uphl_yn_id.should == new_result.specimen_sent_to_uphl_yn_id 
      org_result.lab_result_text.should == new_result.lab_result_text 
      org_result.test_type.should == new_result.test_type 
      org_result.test_detail.should == new_result.test_detail 
      org_result.interpretation_id.should == new_result.interpretation_id 
      org_result.reference_range.should == new_result.reference_range 
   end
    
    it "should copy over reporting data" do
      @event_hash["reporting_agency_attributes"] =
        { 
          "place_entity_attributes" => {
            "place_attributes" => {
              "name"=>"AgencyOne",
            }
          }
        }
      @event_hash["reporter_attributes"] =
        { 
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Starr",
            }
          }
        }

      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['reporting'])

      @org_event.reporting_agency.secondary_entity_id.should == @new_event.reporting_agency.secondary_entity_id
      @org_event.reporter.secondary_entity_id.should == @new_event.reporter.secondary_entity_id
    end
    
    it "should copy over forms and answers" do
      @event_hash["disease_event_attributes"] = {:disease_id => diseases(:chicken_pox).id}
      @event_hash["jurisdiction_attributes"] = {:secondary_entity_id => entities(:Davis_County).id}

      form = Form.new
      form.event_type = "morbidity_event"
      form.name = "AIDS Form"
      form.disease_ids = [diseases(:chicken_pox).id]
      form.save_and_initialize_form_elements
      question_element = QuestionElement.new(
        {
          :parent_element_id => form.form_base_element.id,
          :question_attributes => { :question_text => "What gives?",:data_type => "single_line_text", :short_name => "gives" }
        }
      )
      question_element.save_and_add_to_form
      form.publish

      @org_event = MorbidityEvent.new(@event_hash)
      @org_event.get_investigation_forms
      @org_event.answers = { "1" => { :question_id => question_element.question.id, :text_answer => "Nothin'"} }
      @org_event.save

      @new_event = @org_event.clone_event(['disease_specific'])

      @org_event.form_references.first.form_id.should == @new_event.form_references.first.form_id
      @org_event.answers.first.text_answer.should == @new_event.answers.first.text_answer
      @org_event.answers.first.question_id.should == @new_event.answers.first.question_id
    end

    it "should copy over clinical notes" do
      @event_hash["notes_attributes"] = [ { "note" => "note 1", "note_type" => "clinical" }, { "note" => "note 2", "note_type" => "administrative" } ]

      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['notes'])

      new_notes = @new_event.notes.size.should == 1
      @new_event.notes.first.note.should == "note 1"
    end

  end
end
