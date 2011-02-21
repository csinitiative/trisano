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

describe MorbidityEvent do

  def with_event(event_hash=@event_hash)
    event = MorbidityEvent.new(event_hash)
    event.save!
    event.reload
    yield event if block_given?
  end

  def with_published_form(form_hash=@form_hash)
    form = Form.new(form_hash)
    form.save_and_initialize_form_elements.should_not be_nil
    question_element = QuestionElement.new(
      {
        :parent_element_id => form.form_base_element.children[0].id,
        :question_attributes => { :question_text => "What gives?",:data_type => "single_line_text", :short_name => "gives" }
      }
    )
    question_element.save_and_add_to_form.should_not be_nil
    published_form = form.publish
    yield published_form if block_given?
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
          @event = MorbidityEvent.new( :first_reported_PH_date => Date.yesterday.to_s(:db) )
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
          User.stubs(:current_user).returns(@user)
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

        it "should accept a hash for setting other, less common note attributes" do
          @event.add_note("New nore", "clinical", :user => author = Factory.create(:user))
          @event.notes.first.note.should == 'New nore'
          @event.notes.first.note_type.should == 'clinical'
          @event.notes.first.user.should == author
        end

      end

    end
  end

  describe "Handling tasks" do
    fixtures :users

    before(:each) do
      @user = users(:default_user)
      User.stubs(:current_user).returns(@user)
      @event = MorbidityEvent.new(:first_reported_PH_date => Date.yesterday.to_s(:db))
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
    fixtures :events, :participations, :entities, :addresses, :telephones, :people, :places, :places_types, :users, :participations_places, :hospitals_participations

    before(:each) do
      @user = users(:default_user)
      User.stubs(:current_user).returns(@user)
      @event = MorbidityEvent.find(events(:marks_cmr).id)
    end

    describe "with legitimate parameters" do

      it "should not raise an exception" do
        lambda { @event.route_to_jurisdiction(entities(:Davis_County)) }.should_not raise_error()
      end

      it "should change the jurisdiction and event state" do
        @event.jurisdiction.stubs(:allows_current_user_to?).returns(true)
        @event.jurisdiction.place_entity.place.name.should == places(:Southeastern_District).name
        @event.assign_to_lhd(entities(:Davis_County), [], nil)
        @event.jurisdiction.place_entity.place.name.should == places(:Davis_County).name
        @event.current_state.name.should == :assigned_to_lhd
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

    describe "that has been invalidated by a code change" do
      before do
        DiseaseEvent.update_all("disease_onset_date = '#{Date.today + 1.month}'",
          ['event_id = ?', @event.id])
      end

      it "should not route event in an invalid state" do
        @event.route_to_jurisdiction(entities(:Davis_County)).should == false
      end
    end

    describe "with secondary jurisdictional assignment" do

      describe "adding jurisdictions" do

        it "should add the jurisdictions as secondary jurisdictions and not change state" do
          cur_state = @event.state
          @event.route_to_jurisdiction(entities(:Southeastern_District).id, [entities(:Davis_County).id, entities(:Summit_County).id])
          @event.secondary_jurisdictions.length.should == 2
          @event.secondary_jurisdictions.include?(places(:Davis_County)).should be_true
          @event.secondary_jurisdictions.include?(places(:Summit_County)).should be_true
          @event.state.should == cur_state
        end
      end

      describe "removing jurisdictions" do
        it "should remove the secondary jurisdictions" do
          @event.route_to_jurisdiction(entities(:Southeastern_District).id, [entities(:Davis_County).id, entities(:Summit_County).id])
          @event.secondary_jurisdictions.length.should == 2

          @event.route_to_jurisdiction(entities(:Southeastern_District).id, [entities(:Summit_County).id])
          @event.secondary_jurisdictions(true).length.should == 1
          @event.secondary_jurisdictions.include?(places(:Davis_County)).should_not be_true
          @event.secondary_jurisdictions.include?(places(:Summit_County)).should be_true
        end
      end

      describe "adding some, removing others" do
        it "should add some and remove others" do
          # Start with summit and Southeastern
          @event.route_to_jurisdiction(entities(:Southeastern_District).id, [entities(:Summit_County).id, entities(:Southeastern_District).id])
          @event.secondary_jurisdictions(true).length.should == 2
          @event.secondary_jurisdictions.include?(places(:Southeastern_District)).should be_true
          @event.secondary_jurisdictions.include?(places(:Summit_County)).should be_true
          @event.secondary_jurisdictions.include?(places(:Davis_County)).should_not be_true

          # Remove Southeastern, add Davis, Leave Summit alone
          @event.route_to_jurisdiction(entities(:Southeastern_District).id, [entities(:Davis_County).id, entities(:Summit_County).id])
          @event.secondary_jurisdictions.length.should == 2
          @event.secondary_jurisdictions(true).include?(places(:Davis_County)).should be_true
          @event.secondary_jurisdictions(true).include?(places(:Summit_County)).should be_true
          @event.secondary_jurisdictions(true).include?(places(:Southeastern_District)).should_not be_true
        end
      end

    end

  end

  describe "Under investigation" do

    it "should not be under investigation if it is new" do
      event = MorbidityEvent.create(:first_reported_PH_date => Date.yesterday.to_s(:db))
      event.should_not be_open_for_investigation
    end

    it "should be under investigation if set to under investigation" do
      event = MorbidityEvent.create(:first_reported_PH_date => Date.yesterday.to_s(:db))
      event.workflow_state = 'under_investigation'
      event.save!
      event = Event.find(event.id)
      event.should be_open_for_investigation
    end

    it "should be under investigation if reopened by manager" do
      event = MorbidityEvent.create(:first_reported_PH_date => Date.yesterday.to_s(:db))
      event.workflow_state = 'reopened_by_manager'
      event.save!
      event = Event.find(event.id)
      event.should be_open_for_investigation
    end

    it "should be under investigation if investigation is complete" do
      event = MorbidityEvent.create(:first_reported_PH_date => Date.yesterday.to_s(:db))
      event.workflow_state = 'investigation_complete'
      event.save!
      event = Event.find(event.id)
      event.should be_open_for_investigation
    end

    it 'should set completed by state date automatically' do
      require File.join(RAILS_ROOT, 'features', 'support', 'trisano')
      event = create_basic_event 'morbidity', 'Jack'
      event.workflow_state = 'approved_by_lhd'
      event.save!
      event = Event.find(event.id)
      event.review_completed_by_state_date.should == nil
      event.jurisdiction.stubs(:allows_current_user_to?).returns true
      event.approve 'A note'
      event.save!
      event.review_completed_by_state_date.should == Date.today
    end
  end

  describe "Saving an event" do
    it "should generate an event onset date set to today" do
      event = MorbidityEvent.new(:first_reported_PH_date => Date.today.to_s(:db))
      event.save.should be_true
      event.event_onset_date.should == Date.today
    end
  end

  describe "event transitions (events)" do
    it "should show the proper states that can be transitioned to when the current state is re-opened by manager" do
      @event = MorbidityEvent.create(:first_reported_PH_date => Date.yesterday.to_s(:db))
      @event.workflow_state = 'reopened_by_manager'
      @event.save!
      @event = Event.find @event.id
      @event.states(@event.state).events.should == [:assign_to_lhd, :reset_to_new, :assign_to_queue, :assign_to_investigator, :complete]
    end
  end

  describe "state description" do
    before(:each) do
      @event = MorbidityEvent.create(:first_reported_PH_date => Date.yesterday.to_s(:db))
      @event.workflow_state = 'accepted_by_lhd'
      @event.save!
      @event = Event.find(@event.id)
    end

    it "should come from the #state_description method" do
      @event.state_description.should == "Accepted by Local Health Dept."
    end
  end

  describe "The state transistions" do

    def updated_event(attribs={})
      workflow_state = attribs.delete(:workflow_state)
      @event.update_attributes attribs
      @event.workflow_state = workflow_state if workflow_state
      @event.save!
      Event.find(@event.id)
    end

    before(:each) do
      @event = MorbidityEvent.create(:first_reported_PH_date => Date.yesterday.to_s(:db))
      @permissive_jurisdiction = Factory.build(:jurisdiction)
      @permissive_jurisdiction.stubs(:allows_current_user_to?).returns(true)
      User.stubs(:current_user).returns(nil) #just in case some old stubbin' is around
    end

    it "should be able to assign to an investigator, when accepted by lhd" do
      updated_event(:workflow_state => 'accepted_by_lhd').respond_to?(:assign_to_investigator).should be_true
    end

    it "should be able to assign to a queue, when accepted by lhd" do
      updated_event(:workflow_state => 'accepted_by_lhd').respond_to?(:assign_to_queue).should be_true
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
      @event.stubs(:jurisdiction).returns @permissive_jurisdiction
      @event.expects(:route_to_jurisdiction).returns true
      @event.assign_to_lhd(nil, nil, nil)
      @event.workflow_state.should == 'assigned_to_lhd'
      @event.current_state.name.should == :assigned_to_lhd
      @event.current_state.events.should == [:assign_to_lhd, :reset_to_new, :accept, :reject]
    end

    it 'should be able to move between states, as allowed by transitions' do
      @event.stubs(:jurisdiction).returns @permissive_jurisdiction
      @event.stubs(:route_to_jurisdiction).returns true
      @event.stubs(:primary_jurisdiction).returns nil
      @event.assign_to_lhd(nil, nil, nil)
      @event.current_state.name.should == :assigned_to_lhd
      @event.reset_to_new
      @event.current_state.name.should == :new
      @event.assign_to_lhd(nil, nil, nil)
      @event.current_state.name.should == :assigned_to_lhd
      @event.reject(nil)
      @event.current_state.name.should == :rejected_by_lhd
      @event.assign_to_lhd(nil, nil, nil)
      @event.current_state.name.should == :assigned_to_lhd
      @event.accept(nil)
      @event.current_state.name.should == :accepted_by_lhd
      @event.assign_to_investigator(nil)
      @event.current_state.name.should == :assigned_to_investigator
      @event.reject(nil)
      @event.current_state.name.should == :rejected_by_investigator
      @event.assign_to_investigator(nil)
      @event.current_state.name.should == :assigned_to_investigator
      @event.assign_to_queue(nil)
      @event.current_state.name.should == :assigned_to_queue
      @event.accept(nil)
      @event.current_state.name.should == :under_investigation
      @event.complete(nil)
      @event.current_state.name.should == :investigation_complete
      @event.approve(nil)
      @event.current_state.name.should == :approved_by_lhd
    end
  end

  describe "Support for investigation view elements" do

    def ref(form)
      ref = Factory.build(:form_reference)
      ref.expects(:form).returns(form)
      ref
    end

    def investigation_form(is_a)
      form = Factory.build(:form)
      form.stubs(:has_investigator_view_elements?).returns(is_a)
      form
    end

    def prepare_event
      investigation_form = investigation_form(true)
      core_view_form = investigation_form(false)
      core_field_form = investigation_form(false)
      event = Event.new
      event.expects(:form_references).returns([ref(core_field_form), ref(core_view_form), ref(investigation_form)])
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
        "first_reported_PH_date" => Date.today,
        "age_at_onset" => 14,
        "age_type_id" => 2300,
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
              "birth_date" => Date.today.years_ago(14)-5.days
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
        "first_reported_PH_date" => Date.today,
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
              "birth_date" => Date.today.years_ago(14)-5.days
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
            "lab_results_attributes" => [ { "test_type_id" => 1, "collection_date" => Date.today.years_ago(1) } ] } ]
        with_event do |event|
          event.labs.count.should == 1
          event.age_info.age_at_onset.should == 13
        end
      end

      it 'should use the earliest lab collection date' do
        @event_hash["labs_attributes"] = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "Quest" } },
            "lab_results_attributes" => [ { "test_type_id" => 1, "collection_date" => Date.today.years_ago(1) } ] },
          { "place_entity_attributes" => { "place_attributes" => { "name" => "Merck" } },
            "lab_results_attributes" => [ { "test_type_id" => 1, "collection_date" => Date.today.months_ago(18) } ] } ]
        with_event do |event|
          event.labs.count.should == 2
          event.age_info.age_at_onset.should == 12
        end
      end

      it 'should use the earliest lab collection date' do
        @event_hash["labs_attributes"] = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "Quest" } },
            "lab_results_attributes" => [ { "test_type_id" => 1,
                "collection_date" => Date.today.years_ago(1), "lab_test_date" => Date.today.years_ago(1) } ] },
          { "place_entity_attributes" => { "place_attributes" => { "name" => "Merck" } },
            "lab_results_attributes" => [ { "test_type_id" => 1,
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
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
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

    it 'should set cdc and ibis update when first_reported_PH_date value changes' do
      with_event do |event|
        event.cdc_updated_at.should be_nil
        event.first_reported_PH_date = Date.today - 1
        event.save.should be_true

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

  context "IBIS exports" do
    let(:event) do
      Factory.create(:morbidity_event_with_disease, {
        :first_reported_PH_date => Date.parse("2009-11-29"),
        :created_at => DateTime.parse("2009-11-30 13:30")
      })
    end
      
    describe "includes records" do
      it "created on the first day of the date range" do
        Event.exportable_ibis_records("2009-11-30", "2009-12-1").should be_empty
        event.should_not be_nil
        results = Event.exportable_ibis_records("2009-11-30", "2009-12-1")
        results.map(&:record_number).should == [event.record_number]
      end

      it "created on the last day of the date range" do
        Event.exportable_ibis_records("2009-11-29", "2009-11-30").should be_empty
        event.should_not be_nil
        results = Event.exportable_ibis_records("2009-11-29", "2009-11-30")
        results.map(&:record_number).should == [event.record_number]
      end

      it "created between the start and end dates" do
        Event.exportable_ibis_records("2009-11-15", "2009-12-15").should be_empty
        event.should_not be_nil
        results = Event.exportable_ibis_records("2009-11-15", "2009-12-15")
        results.map(&:record_number).should == [event.record_number]
      end

      it "ibis updated on the first day of the date range" do
        Event.exportable_ibis_records("2009-12-15", "2009-12-16").should be_empty
        event.update_attributes!(:ibis_updated_at => '2009-12-15')
        results = Event.exportable_ibis_records("2009-12-15", "2009-12-16")
        results.map(&:record_number).should == [event.record_number]
      end

      it "ibis updated on the last day of the date range" do
        Event.exportable_ibis_records("2009-12-14", "2009-12-15").should be_empty
        event.update_attributes!(:ibis_updated_at => '2009-12-15')
        results = Event.exportable_ibis_records("2009-12-14", "2009-12-15")
        results.map(&:record_number).should == [event.record_number]
      end

      it "ibis updated between the start and end dates" do
        Event.exportable_ibis_records("2009-12-01", "2009-12-31").should be_empty
        event.update_attributes!(:ibis_updated_at => '2009-12-15')
        results = Event.exportable_ibis_records("2009-12-01", "2009-12-31")
        results.map(&:record_number).should == [event.record_number]
      end

      describe "sent to ibis, and then later deleted" do
        it "if deleted on the first day of the date range" do
          Event.exportable_ibis_records("2009-12-15", "2009-12-16").should == []
          event.update_attributes!(:sent_to_ibis => true, :deleted_at => "2009-12-15 15:00")
          results = Event.exportable_ibis_records("2009-12-15", "2009-12-16")
          results.map(&:record_number).should == [event.record_number]
        end

        it "if deleted on the last day of the date range" do
          Event.exportable_ibis_records("2009-12-14", "2009-12-15").should == []
          event.update_attributes!(:sent_to_ibis => true, :deleted_at => "2009-12-15 15:00")
          results = Event.exportable_ibis_records("2009-12-14", "2009-12-15")
          results.map(&:record_number).should == [event.record_number]
        end

        it "if deleted between the date ranges" do
          Event.exportable_ibis_records("2009-12-01", "2009-12-31").should == []
          event.update_attributes!(:sent_to_ibis => true, :deleted_at => "2009-12-15 15:00")
          results = Event.exportable_ibis_records("2009-12-01", "2009-12-31")
          results.map(&:record_number).should == [event.record_number]
        end
      end
    end

    describe "excludes records" do
      it "if they don't have a disease" do
        event.disease_event.update_attributes!(:disease => nil)
        Event.exportable_ibis_records("2009-11-29", "2009-11-30").should == []
      end

      it "if they are deleted" do
        event.update_attributes!(:deleted_at => DateTime.parse("2009-11-30 15:00"))
        Event.exportable_ibis_records("2009-11-29", "2009-11-30").should == []
      end
    end
  end

  describe 'when executing a view-filtering search' do

    fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :diseases, :disease_events, :places, :places_types, :participations, :event_queues, :people

    before :each do

      jurisdiction_id = role_memberships(:default_user_admin_role_southeastern_district).jurisdiction_id

      @user = users(:default_user)
      @user.stubs(:jurisdiction_ids_for_privilege).returns([jurisdiction_id])
      User.stubs(:current_user).returns(@user)
      MorbidityEvent.stubs(:get_allowed_queues).returns([[1], ["Speedy-BearRiver"]])

      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
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

      a = MorbidityEvent.create(@event_hash)
      a.workflow_state = 'closed'
      a.save!

      @event_hash['investigator_id'] = 1
      m = MorbidityEvent.create(@event_hash)
      m.workflow_state = 'closed'
      m.save!

      # make sure EncounterEvent doesn't show up.
      EncounterEvent.create(:parent_id => m.id)

      MorbidityEvent.find_all_for_filtered_view.size.should == 6
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1]}).size.should == 5
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :queues => [1], :states => ['accepted_by_lhd']}).size.should == 1
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :queues => [1], :states => ['closed']}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['closed']}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :queues => [1], :states => ['closed'], :investigators => [1]}).size.should == 1
    end

    it 'should filter by state and the other attributes' do
      a = MorbidityEvent.create(@event_hash)
      a.workflow_state = 'closed'
      a.save!

      @event_hash['disease_event_attributes'] = {'disease_id' => 1 }
      b = MorbidityEvent.create(@event_hash)
      b.workflow_state = 'closed'
      b.save!

      @event_hash['event_queue_id'] = 1
      c = MorbidityEvent.create(@event_hash)
      c.workflow_state = 'closed'
      c.save!

      @event_hash['investigator_id'] = 1
      d = MorbidityEvent.create(@event_hash)
      d.workflow_state = 'closed'
      d.save!

      MorbidityEvent.find_all_for_filtered_view.size.should == 6
      MorbidityEvent.find_all_for_filtered_view({:states => ['closed']}).size.should == 4
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['closed']}).size.should == 3
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['closed'], :queues => [1]}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['closed'], :queues => [1], :investigators => [1]}).size.should == 1
    end

    it 'should filter by queue and the other attributes' do
      @event_hash['event_queue_id'] = 1
      MorbidityEvent.create(@event_hash)

      a = MorbidityEvent.create(@event_hash)
      a.workflow_state = 'closed'
      a.save!

      @event_hash['disease_event_attributes'] = {'disease_id' => 1 }
      b = MorbidityEvent.create(@event_hash)
      b.workflow_state = 'closed'
      b.save!

      @event_hash['investigator_id'] = 1
      c = MorbidityEvent.create(@event_hash)
      c.workflow_state = 'closed'
      c.save!

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
      a = MorbidityEvent.create(@event_hash)
      a.workflow_state = 'closed'
      a.save!

      @event_hash['disease_event_attributes'] = {'disease_id' => 1 }
      b = MorbidityEvent.create(@event_hash)
      b.workflow_state = 'closed'
      b.save!

      @event_hash['event_queue_id'] = 1
      c = MorbidityEvent.create(@event_hash)
      c.workflow_state = 'closed'
      c.save!

      MorbidityEvent.find_all_for_filtered_view.size.should == 6
      MorbidityEvent.find_all_for_filtered_view({:investigators => [1]}).size.should == 4
      MorbidityEvent.find_all_for_filtered_view({:investigators => [1], :states => ['closed']}).size.should == 3
      MorbidityEvent.find_all_for_filtered_view({:investigators => [1], :states => ['closed'], :diseases => [1]}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:investigators => [1], :states => ['closed'], :diseases => [1], :queues => [1]}).size.should == 1
    end

    it "should not show deleted records if told so" do
      @event_hash['investigator_id'] = 1
      MorbidityEvent.create(@event_hash)

      me = MorbidityEvent.create(@event_hash)
      me.workflow_state = 'closed'
      me.save!

      @event_hash['disease_event_attributes'] = {'disease_id' => 1 }
      b = MorbidityEvent.create(@event_hash)
      b.workflow_state = 'closed'
      b.save!

      @event_hash['event_queue_id'] = 1
      a = MorbidityEvent.create(@event_hash)
      a.workflow_state = 'closed'
      a.soft_delete

      MorbidityEvent.find_all_for_filtered_view.size.should == 6
      MorbidityEvent.find_all_for_filtered_view({:do_not_show_deleted => [1], :investigators => [1]}).size.should == 3
      MorbidityEvent.find_all_for_filtered_view({:do_not_show_deleted => [1], :investigators => [1], :states => ['closed']}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:do_not_show_deleted => [1], :investigators => [1], :states => ['closed'], :diseases => [1]}).size.should == 1
      MorbidityEvent.find_all_for_filtered_view({:do_not_show_deleted => [1], :investigators => [1], :states => ['closed'], :diseases => [1], :queues => [1]}).size.should == 0
    end

    it "should sort appropriately" do
      @user.stubs(:jurisdiction_ids_for_privilege).returns([places(:Southeastern_District).entity_id,
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
      @user.expects(:update_attribute)
      HumanEvent.find_all_for_filtered_view({:queues => ["Enterics-BearRiver"], :set_as_default_view => "1"}).size.should == 1
    end

  end

  describe 'form builder cdc export fields' do
    fixtures :diseases, :export_conversion_values, :export_columns

    before(:each) do
      @question = Question.create(:data_type => 'radio_button', :question_text => 'Contact?', :short_name => "contact" )
      @question_element = QuestionElement.create(:question => @question)
      @event = MorbidityEvent.create( { "first_reported_PH_date" => Date.yesterday.to_s(:db), "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"CdcExportHep", } } },
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
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
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

  describe "forms assignment during event creation" do
    fixtures :diseases, :entities

    before(:each) do
      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
            }
          }
        }
      }

      @form_hash = {
        "name"=>"Form Assignment Form",
        "short_name"=> Digest::MD5::hexdigest(DateTime.now.to_s),
        "event_type"=>"morbidity_event",
        "disease_ids"=>[diseases(:form_assignment_disease).id],
        "jurisdiction_id"=>""
      }

    end

    it 'should assign available forms at creation time when the event has a jurisdiction and a disease' do
      with_published_form(@form_hash) do |form|
        @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:form_assignment_disease).id })
        @event_hash = @event_hash.merge("jurisdiction_attributes" => { "secondary_entity_id" => entities(:Southeastern_District).id })
        @event = MorbidityEvent.new(@event_hash)
        @event.form_references.size.should == 0
        @event.save!
        @event.reload
        @event.form_references.size.should == 1
        @event.undergone_form_assignment.should be_true
      end
    end

    it 'should not assign forms at creation time when the event has no disease' do
      with_published_form(@form_hash) do |form|
        @event_hash = @event_hash.merge("jurisdiction_attributes" => { "secondary_entity_id" => entities(:Southeastern_District).id })
        @event = MorbidityEvent.new(@event_hash)
        @event.form_references.size.should == 0
        @event.save!
        @event.reload
        @event.form_references.size.should == 0
        @event.undergone_form_assignment.should be_false
      end
    end

    it 'should not assign forms at creation time when the event has no jurisdiction' do
      with_published_form(@form_hash) do |form|
        @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:form_assignment_disease).id })
        @event = MorbidityEvent.new(@event_hash)
        @event.jurisdiction = nil
        @event.form_references.size.should == 0
        @event.save!
        @event.reload
        @event.form_references.size.should == 0
        @event.undergone_form_assignment.should be_false
      end
    end

    it 'should not assign forms at creation time when there are no forms for the disease' do
      @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:form_assignment_disease).id })
      @event_hash = @event_hash.merge("jurisdiction_attributes" => { "secondary_entity_id" => entities(:Southeastern_District).id })
      @event = MorbidityEvent.new(@event_hash)
      @event.form_references.size.should == 0
      @event.save!
      @event.reload
      @event.form_references.size.should == 0
    end

    it 'should still mark the event as having gone through form assignment even when there are no forms for the disease' do
      with_published_form(@form_hash) do |form|
        @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:form_assignment_disease).id })
        @event_hash = @event_hash.merge("jurisdiction_attributes" => { "secondary_entity_id" => entities(:Southeastern_District).id })
        @event = MorbidityEvent.new(@event_hash)
        @event.save!
        @event.undergone_form_assignment.should be_true
      end
    end

  end

  describe "forms assignment during event updates" do
    fixtures :diseases, :entities

    before(:each) do
      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
            }
          }
        },
        "jurisdiction_attributes" => { "secondary_entity_id" => entities(:Southeastern_District).id }
      }
      
      @form_hash = {
        "name"=>"Form Assignment Form",
        "short_name"=> Digest::MD5::hexdigest(DateTime.now.to_s),
        "event_type"=>"morbidity_event",
        "disease_ids"=>[diseases(:form_assignment_disease).id],
        "jurisdiction_id"=>""
      }

    end

    it 'should assign available forms at update time when the event has a jurisdiction and a disease and has not previously gone through form assignment' do
      with_published_form(@form_hash) do |form|
        @event = MorbidityEvent.new(@event_hash)
        @event.save!
        @event.reload
        @event.form_references.size.should == 0
        @event.undergone_form_assignment.should be_false
        @event.update_attributes("disease_event_attributes" => { "disease_id" => diseases(:form_assignment_disease).id })
        @event.reload
        @event.form_references.size.should == 1
        @event.undergone_form_assignment.should be_true
      end
    end

    it 'should not assign additional forms at update time when the event has a jurisdiction and a disease but has previously gone through form assignment' do
      @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:form_assignment_disease).id })
      @event = MorbidityEvent.new(@event_hash)
      @event.save!
      @event.reload
      @event.form_references.size.should == 0
      @event.undergone_form_assignment.should be_true

      with_published_form(@form_hash) do |form|
        @event.update_attributes("outbreak_name" => "Outbreak")
        @event.save!
        @event.reload
        @event.form_references.size.should == 0
        @event.undergone_form_assignment.should be_true
      end
    end

  end

  describe "forms assignment during routing" do
    fixtures :diseases, :entities

    before(:each) do
      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
            }
          }
        },
        "jurisdiction_attributes" => { "secondary_entity_id" => entities(:Southeastern_District).id }
      }

      @form_hash = {
        "name"=>"Form Assignment Form",
        "short_name"=> Digest::MD5::hexdigest(DateTime.now.to_s),
        "event_type"=>"morbidity_event",
        "disease_ids"=>[diseases(:form_assignment_disease).id],
        "jurisdiction_id"=>""
      }
    end

    it 'should receive a applicable new form if the disease changed before routing' do
      with_published_form(@form_hash) do |form|
        @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:no_forms_disease).id })
        @event = MorbidityEvent.new(@event_hash)
        @event.save!
        @event.reload
        @event.undergone_form_assignment.should be_true
        @event.form_references.size.should == 0
        @event.update_attributes("disease_event_attributes" => { "disease_id" => diseases(:form_assignment_disease).id })
        @event.reload
        @event.form_references.size.should == 0 # Changing disease doesn't trigger forms assignment
        @event.route_to_jurisdiction(entities(:Davis_County).id)
        @event.form_references.size.should == 1 # Pick up the new form through routing
      end
    end
  end

  describe "adding forms to an event" do

    describe "an event without forms already" do

      before(:each) do
        # Create an event
        @event = Factory.create(:morbidity_event)
        @event.save!

        # Create two forms
        @form =  Factory.build(:form, :event_type => "morbidity_event")
        @form.save_and_initialize_form_elements
        @published_form = @form.publish
        @second_form =  Factory.build(:form, :event_type => "morbidity_event")
        @second_form.save_and_initialize_form_elements
        @second_published_form = @second_form.publish
      end

      it "should add new forms" do
        @event.add_forms([@published_form.id, @second_published_form.id])
        event_form_ids = @event.form_references.map { |ref| ref.form_id }
        event_form_ids.sort.should == [@published_form.id, @second_published_form.id].sort
      end

    end

    describe "an event with existing forms" do    # No fixture specs

      before(:each) do
        # Create a form and assign it to an event
        @event = Factory.create(:morbidity_event)
        @form =  Factory.build(:form, :event_type => "morbidity_event")
        @form.save_and_initialize_form_elements
        @published_form = @form.publish
        @event.add_forms(@published_form.id)
        @event.save!

        # Create a second form and just publish it
        @second_form =  Factory.build(:form, :event_type => "morbidity_event")
        @second_form.save_and_initialize_form_elements
        @second_published_form = @second_form.publish
      end

      it "should add new forms with no dups" do
        # Try adding the first form again, in addition to a form the event doesn't have yet
        @event.add_forms([@published_form.id, @second_published_form.id])

        event_form_ids = @event.form_references.map { |ref| ref.form_id }
        event_form_ids.sort.should == [@published_form.id, @second_published_form.id]
      end

      it "should add new forms with no dups, including older versions" do
        # Rev the form already on the event by publishing it again
        @second_version_of_first_form = @form.publish

        # Try to add a second form and another version of a form already on the event
        @event.add_forms([@second_version_of_first_form.id, @second_published_form.id])

        # The new version of a form already on the event should not be added
        @event.form_references.size.should == 2
        @event.form_references.detect { |ref| ref.form_id == @second_version_of_first_form }.should be_nil
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

  describe "removing forms from an event" do
    fixtures :diseases, :entities

    before(:each) do
      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
            }
          }
        },
        "disease_event_attributes" => { "disease_id" => diseases(:form_assignment_disease).id },
        "jurisdiction_attributes" => { "secondary_entity_id" => entities(:Southeastern_District).id }
      }

      @event = MorbidityEvent.new(@event_hash)

      @form_hash = {
        "name"=>"Form Assignment Form",
        "short_name"=> Digest::MD5::hexdigest(DateTime.now.to_s),
        "event_type"=>"morbidity_event",
        "disease_ids"=>[diseases(:form_assignment_disease).id],
        "jurisdiction_id"=>""
      }
    end

    it "should remove the form reference" do
      with_published_form(@form_hash) do |form|
        @event.save!
        @event.reload
        @event.form_references.size.should == 1
        @event.remove_forms(form.id).should be_true
        @event.reload
        @event.form_references.size.should == 0
      end
    end

    it "should return nil if the form provided is not on the event" do
      with_published_form(@form_hash) do |form|
        @event.save!
        @event.reload
        @event.form_references.size.should == 1
        @event.remove_forms(9999).should be_nil
        @event.reload
        @event.form_references.size.should == 1
      end
    end

    it "should remove answers to the form questions" do
      with_published_form(@form_hash) do |form|
        @event.save!
        @event.reload
        @event.form_references.size.should == 1
        @event.answers = {
          "1" => { :question_id => form.form_base_element.children[0].children[1].question.id, :text_answer => "Nothin'" },
        }
        @event.answers.size.should == 1
        @event.remove_forms(form.id).should be_true
        @event.reload
        @event.form_references.size.should == 0
        @event.answers.size.should == 0
      end
    end

  end

  describe "when soft deleting" do
    fixtures :users

    before(:each) do
      @user = users(:default_user)
      User.stubs(:current_user).returns(@user)
      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
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
    fixtures :entities, :places

    before(:each) do
      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Green"
            }
          }
        },
        "jurisdiction_attributes" => {
          "secondary_entity_id" => entities(:Davis_County).id
        }
      }
    end

    describe 'searching for cases by disease' do
      fixtures :diseases
      before(:each) do
        with_event(@event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:chicken_pox).id }))
        with_event(@event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:tuberculosis).id}))
        with_event(@event_hash.merge("disease_event_attributes" => { "disease_id" => diseases(:anthrax).id}))
      end

      it 'should be done with a single disease' do
        Event.find_by_criteria(:diseases => [diseases(:chicken_pox).id], :jurisdiction_ids => [entities(:Davis_County).id]).size.should == 1
      end

      it 'should be done with multiple diseases' do
        Event.find_by_criteria(:diseases => [diseases(:chicken_pox).id, diseases(:tuberculosis).id], :jurisdiction_ids => [entities(:Davis_County).id]).size.should == 2
      end

      it 'should ignore empty disease arrays' do
        Event.find_by_criteria(:diseases => [], :jurisdiction_ids => [entities(:Davis_County).id]).size.should == 3
      end
    end

    describe "finding by criteria" do
      before { login_as_super_user }
      after  { logout }

      it "should accept a limit for returned results" do
        11.times { searchable_event!(:morbidity_event, 'Jones') }
        results = Event.find_by_criteria(:event_type => 'MorbidityEvent', :limit => "10")
        results.size.should == 10
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
    User.stubs(:current_user).returns(users(:default_user))

    @event_hash = {
      "first_reported_PH_date" => Date.yesterday.to_s(:db),
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

    it "the new event should be persistable without a first reported date" do
      @new_event.first_reported_PH_date.should be_nil
      @new_event.save.should be_true
      @new_event.errors.empty?.should be_true
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

    it "should copy the address associated with the original event, not an address associated with another event cloned from the original" do
      @another_event = @org_event.clone_event
      @another_event.address.street_name = 'Doit St.'
      @another_event.save!
      
      @yet_another_event = @org_event.clone_event
      @yet_another_event.address.street_name = 'Lala Ln.'
      @yet_another_event.save!

      @one_more_time = @org_event.clone_event
      @one_more_time.address.street_name.should == 'Example Lane'
    end

  end

  describe "deep clone" do
    fixtures :common_test_types

    it "should first do a shallow clone" do
      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event

      @new_event.interested_party.secondary_entity_id.should == @org_event.interested_party.secondary_entity_id
      @new_event.primary_jurisdiction.name.should == "Unassigned"
      @new_event.should be_new
    end

    it "the new event should be persistable without a first reported date" do
      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event

      @new_event.first_reported_PH_date.should be_nil
      @new_event.save.should be_true
      @new_event.errors.empty?.should be_true
    end

    it "should copy over disease information, but not the actual disease" do
      @event_hash["disease_event_attributes"] = {:disease_id => diseases(:chicken_pox).id,
        :hospitalized_id => external_codes(:yesno_yes).id,
        :died_id => external_codes(:yesno_no).id,
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

    it "should copy over hospitalization data even if there are no additional attributes beyond a hospital" do
      @event_hash["hospitalization_facilities_attributes"] = [
        { :secondary_entity_id => entities(:AVH).id },
        { :secondary_entity_id => entities(:BRVH).id }
      ]
      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @new_event.hospitalization_facilities.size.should == 2
      
      @new_event.hospitalization_facilities.each do |h|
        h.hospitals_participation.should be_nil
      end
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
      @leeches_treatment = Factory.create(:treatment, :treatment_name => "Leeches")
      @maggots_treatment = Factory.create(:treatment, :treatment_name => "Maggots")

      @event_hash["interested_party_attributes"]["treatments_attributes"] =
        [
        {
          :treatment_given_yn_id => external_codes(:yesno_no).id,
          :treatment_date => Date.today,
          :stop_treatment_date => Date.today + 1,
          :treatment_id => @leeches_treatment.id
        },
        {
          :treatment_given_yn_id => external_codes(:yesno_yes).id,
          :treatment_date => Date.today - 2,
          :stop_treatment_date => Date.today - 1,
          :treatment_id => @maggots_treatment.id
        }
      ]
      @org_event = MorbidityEvent.create(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @new_event.interested_party.treatments.size.should == 2
      @new_event.interested_party.treatments.each do |pt|
        if pt.treatment.treatment_name == "Leeches"
          pt.treatment_given_yn_id.should == external_codes(:yesno_no).id
          pt.treatment_date.should == Date.today
          pt.stop_treatment_date.should == Date.today + 1
        elsif pt.treatment.treatment_name == "Maggots"
          pt.treatment_given_yn_id.should == external_codes(:yesno_yes).id
          pt.treatment_date.should == Date.today - 2
          pt.stop_treatment_date.should == Date.today - 1
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
            { "specimen_source_id" => external_codes(:specimen_blood).id,
              "collection_date" => Date.today,
              "lab_test_date" => Date.today,
              "specimen_sent_to_state_id" => external_codes(:yesno_yes).id,
              "test_type" => common_test_types(:blood_test),
              "test_result_id" => external_codes(:state_alaska).id, # It's not really important what it is, just that it's there.  Tired of adding fixtures.
              "test_status_id" => external_codes(:state_alabama).id, # It's not really important what it is, just that it's there.  Tired of adding fixtures.
              "result_value" => "one",
              "units" => "two",
              "reference_range" => "three",
              "comment" => "four"
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
      org_result.specimen_sent_to_state_id.should == new_result.specimen_sent_to_state_id
      org_result.test_type.should == new_result.test_type
      org_result.test_result_id.should == new_result.test_result_id
      org_result.test_status_id.should == new_result.test_status_id
      org_result.result_value.should == new_result.result_value
      org_result.units.should == new_result.units
      org_result.reference_range.should == new_result.reference_range
      org_result.comment.should == new_result.comment
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
      form.short_name = 'event_spec_aids'
      form.disease_ids = [diseases(:chicken_pox).id]
      form.save_and_initialize_form_elements.should_not be_nil
      form.form_base_element.children_count.should == 3
      question_element = QuestionElement.new(
        {
          :parent_element_id => form.form_base_element.children[0].id,
          :question_attributes => { :question_text => "What gives?",:data_type => "single_line_text", :short_name => "gives" }
        }
      )
      question_element.save_and_add_to_form.should_not be_nil
      form.publish

      @org_event = MorbidityEvent.new(@event_hash)
      @org_event.save
      @org_event.answers = { "1" => { :question_id => question_element.question.id, :text_answer => "Nothin'"} }
      @org_event.save

      @new_event = @org_event.clone_event(['disease_specific'])
      @new_event.save!

      @org_event.form_references.first.form_id.should == @new_event.form_references.first.form_id
      @org_event.form_references.first.template_id.should == @new_event.form_references.first.template_id
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

describe Event, "deep copied event" do
  before do
    @event = Factory.create(:morbidity_event)
    @event.save!
    @note_user = Factory.create(:user)
    @event.add_note('Just a sample note', 'clinical', :user => @note_user)
    login_as_super_user
    @new_event = MorbidityEvent.new
    @event.copy_event @new_event, ['notes']
    @new_event.save!
  end

  it "should have copies of clinical notes, if notes component was specified" do
    @new_event.notes.select { |note| note.note_type == 'clinical' }.size.should == 1
  end

  it "has copied notes from the original note user" do
    @new_event.notes.select { |note| note.note_type == 'clinical' }.each do |note|
      note.user.should == @note_user
    end
  end
end


describe Event, "when saving events with deleted entities" do

  it "saving an event with a deleted entity should not pass validation" do
    @jurisdiction = Factory.create(:jurisdiction)
    @jurisdiction.place_entity.deleted_at = Time.now
    @jurisdiction.place_entity.save!
    @jurisdiction.reload
    @morbidity_event = Factory.build(:morbidity_event, :jurisdiction => @jurisdiction)
    @morbidity_event.save.should be_false
    @morbidity_event.errors.empty?.should be_false
  end

end

describe Event, "mmwr date" do
  before do
    the_past = Date.today - 21
    first_reported = the_past - 1.week
    @expected_mmwr = Mmwr.new(first_reported)
    @event = Factory.create(:morbidity_event)
    @event.update_attributes!(:created_at => the_past, :first_reported_PH_date => first_reported)
  end

  it "is based on first reported date, which is required" do
    assert_equal @expected_mmwr.mmwr_year, @event.MMWR_year, "Wrong MMWR year"
    assert_equal @expected_mmwr.mmwr_week, @event.MMWR_week, "Wrong MMWR week"
  end
end

describe Event, "jurisdiction entity ids" do
  before do
    @event = Factory.build(:morbidity_event)
  end

  it "are pulled from the database on record that already exists" do
    @event.save!
    @event.jurisdiction_entity_ids.to_a.should == [@event.jurisdiction.secondary_entity_id]
  end

  it "are collected from jurisdiction and associated jursidictions on new records" do
    @event.associated_jurisdictions.build :place_entity => create_jurisdiction_entity
    @event.jurisdiction_entity_ids.to_a.should == [@event.jurisdiction.secondary_entity_id, @event.associated_jurisdictions.map(&:secondary_entity_id)].flatten
  end
end
