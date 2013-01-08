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

require 'spec_helper'

describe MorbidityEvent do
  before do
    destroy_fixture_data
  end

  after do
    Fixtures.reset_cache
  end

  def with_event(event_hash=@event_hash)
    event = Factory(:morbidity_event, event_hash)
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

  it "should validate date format of results reported to clinician date" do
    event = Event.new
    event.update_attribute(:results_reported_to_clinician_date, 'not a date string')
    event.should_not be_valid
    event.errors.on(:results_reported_to_clinician_date).should_not be_nil
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

        before(:each) do
          Factory(:user)
          #@event = MorbidityEvent.new( :first_reported_PH_date => Date.yesterday.to_s(:db) )
          @event = Factory(:morbidity_event)
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
          @event.place_child_events_attributes = [ { "interested_place_attributes" => {
            "place_entity_attributes" => {
              "place_attributes" => {
                "name" => "" } } },
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

      describe "adding notes through add_note" do

        before(:each) do
          @event = MorbidityEvent.new()
          @user = Factory(:user)
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

    before(:each) do
      @user = Factory(:user)
      @event = Factory(:morbidity_event)
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

    before(:each) do
      @user = Factory(:user)
      @event = Factory(:morbidity_event)
    end

    describe "with legitimate parameters" do
      before { @jurisdiction = create_jurisdiction_entity }

      it "should not raise an exception" do
        lambda { @event.route_to_jurisdiction(@jurisdiction) }.should_not raise_error()
      end

      it "should change the jurisdiction and event state" do
        @event.jurisdiction.stubs(:allows_current_user_to?).returns(true)
        @event.assign_to_lhd(@jurisdiction, [], nil)
        @event.jurisdiction.place_entity.should == @jurisdiction
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

    describe "that has been invalidated" do
      before do
        @event.stubs(:valid?).returns(false)
      end

      it "should not route event in an invalid state" do
        @event.route_to_jurisdiction(create_jurisdiction_entity).should == false
      end
    end

    describe "with secondary jurisdictional assignment" do

      describe "adding jurisdictions" do

        it "should add the jurisdictions as secondary jurisdictions and not change state" do
          cur_state = @event.state
          secondary_jurisdictions = [create_jurisdiction_entity.id, create_jurisdiction_entity.id]
          @event.route_to_jurisdiction(@event.jurisdiction.place_entity, secondary_jurisdictions)
          @event.associated_jurisdictions.map(&:secondary_entity_id).should == secondary_jurisdictions
          @event.state.should == cur_state
        end
      end

      describe "removing jurisdictions" do
        it "should remove the secondary jurisdictions" do
          secondary_jurisdictions = [create_jurisdiction_entity.id, create_jurisdiction_entity.id]
          @event.route_to_jurisdiction(@event.jurisdiction.place_entity, secondary_jurisdictions)
          @event.associated_jurisdictions.length.should == 2

          @event.route_to_jurisdiction(@event.jurisdiction.place_entity, [secondary_jurisdictions.first])
          @event.associated_jurisdictions(true).map(&:secondary_entity_id).should == [secondary_jurisdictions.first]
        end
      end

      describe "adding some, removing others" do
        it "should add some and remove others" do
          secondary_jurisdictions = [create_jurisdiction_entity.id, create_jurisdiction_entity.id]
          @event.route_to_jurisdiction(@event.jurisdiction.place_entity, secondary_jurisdictions)
          @event.associated_jurisdictions(true).map(&:secondary_entity_id).should == secondary_jurisdictions

          new_secondary_jurisdictions = [secondary_jurisdictions.first, create_jurisdiction_entity.id]
          @event.route_to_jurisdiction(@event.jurisdiction.place_entity, new_secondary_jurisdictions)
          @event.associated_jurisdictions(true).map(&:secondary_entity_id).should == new_secondary_jurisdictions
        end
      end

    end

  end

  describe "Under investigation" do

    it "should not be under investigation if it is new" do
      event = Factory(:morbidity_event)
      event.should_not be_open_for_investigation
    end

    it "should be under investigation if set to under investigation" do
      event = Factory(:morbidity_event)
      event.workflow_state = 'under_investigation'
      event.save!
      event = Event.find(event.id)
      event.should be_open_for_investigation
    end

    it "should be under investigation if reopened by manager" do
      event = Factory(:morbidity_event)
      event.workflow_state = 'reopened_by_manager'
      event.save!
      event = Event.find(event.id)
      event.should be_open_for_investigation
    end

    it "should be under investigation if investigation is complete" do
      event = Factory(:morbidity_event)
      event.workflow_state = 'investigation_complete'
      event.save!
      event = Event.find(event.id)
      event.should be_open_for_investigation
    end

    it 'should set completed by state date automatically' do
      event = Factory(:morbidity_event)
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

  describe "saving an event" do
    it "should generate an event onset date set to today" do
      event = Factory.build(:morbidity_event, :first_reported_PH_date => Date.today)
      event.save.should be_true
      event.event_onset_date.should == Date.today
    end
  end

  describe "event transitions (events)" do
    it "should show the proper states that can be transitioned to when the current state is re-opened by manager" do
      @event = Factory(:morbidity_event)
      @event.workflow_state = 'reopened_by_manager'
      @event.save!
      @event = Event.find @event.id
      @event.states(@event.state).events.should == [:assign_to_lhd, :reset_to_new, :assign_to_queue, :assign_to_investigator, :complete]
    end
  end

  describe "state description" do
    before(:each) do
      @event = Factory(:morbidity_event)
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
      @event = Factory(:morbidity_event)
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
      event = MorbidityEvent.new
      event.workflow_state.should == 'new'
      event.current_state.should == event.states(:new)
      event.current_state.events.should == [:assign_to_lhd, :reset_to_new]
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
      event = Factory.build(:morbidity_event)
      event.update_attributes(@event_hash)
      event.age_info.should_not be_nil
      event.age_info.age_at_onset.should == 14
      event.age_info.age_type.code_description.should == 'years'
    end

  end

  describe 'just created' do
    before :each do
      @event = Factory(:morbidity_event)
      @event.interested_party.person_entity.person.update_attribute :birth_date, (Date.today.years_ago(14) - 5.days)
    end

    it 'should not generate an age at onset if the birthdate is unknown' do
      @event.age_info.should_not be_nil
      @event.age_info.age_type.code_description.should == 'unknown'
      @event.age_info.age_at_onset.should be_nil
    end

    it 'should generate an age at onset if the birthday is known' do
      @event.interested_party.person_entity.person.birth_date = Date.today.years_ago(14) - 5.days
      @event.save!
      @event.event_onset_date.should_not be_nil
      @event.age_info.age_at_onset.should == 14
      @event.age_info.age_type.code_description.should == 'years'
    end

    describe 'generating age at onset from earliest encounter date' do

      it 'should use the disease onset date' do
        onset = Date.today.years_ago(3)
        @event_hash = { 'disease_event_attributes' => {'disease_onset_date' => onset } }
        @event.update_attributes(@event_hash)
        @event.age_info.age_at_onset.should == 11
        @event.age_info.age_type.code_description.should == 'years'
      end

      it 'should use the date the disease was diagnosed' do
        date_diagnosed = Date.today.years_ago(3)
        @event_hash = { 'disease_event_attributes' => {'date_diagnosed' => date_diagnosed } }
        @event.update_attributes(@event_hash)
        @event.age_info.age_at_onset.should == 11
        @event.age_info.age_type.code_description.should == 'years'
      end

      it 'should use the lab collection date' do
        @event.labs << Factory(:lab)
        @event.labs.first.lab_results.first.update_attributes(:collection_date => Date.today.years_ago(1))
        @event.save!
        @event.labs.count.should == 1
        @event.age_info.age_at_onset.should == 13
      end

      it 'should use the earliest lab collection date' do
        @event.labs << Factory(:lab)
        @event.labs.first.lab_results.first.update_attributes(:collection_date => Date.today.years_ago(1))
        @event.labs << Factory(:lab)
        @event.labs.last.lab_results.first.update_attributes(:collection_date => Date.today.months_ago(18))
        @event.save!
        @event.labs.count.should == 2
        @event.age_info.age_at_onset.should == 12
      end

      it 'should use the earliest lab test date' do
        @event.labs << Factory(:lab)
        @event.labs.first.lab_results.first.update_attributes(:collection_date => Date.today.years_ago(1),
                                                              :lab_test_date => Date.today.years_ago(1))
        @event.labs << Factory(:lab)
        @event.labs.last.lab_results.first.update_attributes(:collection_date => Date.today.years_ago(3),
                                                             :lab_test_date => Date.today.months_ago(18))
        @event.save!
        @event.labs.count.should == 2
        @event.age_info.age_at_onset.should == 11
      end

      it 'should use the first reported public health date (if its the earliest)' do
        @event_hash = { 'first_reported_PH_date' => Date.today.months_ago(6) }
        @event.update_attributes(@event_hash)
        @event.age_info.age_at_onset.should == 13
      end

    end

  end

  describe 'checking CDC and IBIS export' do

    before :each do
      @user = Factory(:user)
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
      event = Factory(:morbidity_event)
      event.sent_to_cdc = event.sent_to_ibis = true
      event.soft_delete
      event.save.should be_true
      event.cdc_updated_at.should == Date.today
      event.ibis_updated_at.should == Date.today
    end
  end

  describe 'when executing a view-filtering search' do

    before :each do
      @jurisdiction_id = create_jurisdiction_entity.id

      @user = Factory(:user)
      # decouple find_all_for_filtered_view from current_user
      User.stubs(:current_user).returns(nil)

      @queue = Factory(:event_queue, :jurisdiction_id => @jurisdiction_id)

      @search_hash = { :view_jurisdiction_ids => [@jurisdiction_id] }
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
          "secondary_entity_id" => @jurisdiction_id
        }
      }
    end

    it 'should filter by disease and the other attributes' do
      disease_id = Factory(:disease).id
      @event_hash['disease_event_attributes'] = {'disease_id' => disease_id }
      MorbidityEvent.create(@event_hash)

      @event_hash['event_queue_id'] = @queue.id
      MorbidityEvent.create(@event_hash)

      a = MorbidityEvent.create(@event_hash)
      a.workflow_state = 'closed'
      a.save!

      @event_hash['investigator_id'] = @user.id
      m = MorbidityEvent.create(@event_hash)
      m.workflow_state = 'closed'
      m.save!

      # make sure EncounterEvent doesn't show up.
      EncounterEvent.create(:parent_id => m.id)

      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:diseases => [disease_id])).size.should == 4
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:queues => [@queue.id], :states => ['accepted_by_lhd'])).size.should == 1
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:states => ['closed'])).size.should == 2
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:investigators => [@user.id])).size.should == 1
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:queues => nil, :investigators => nil)).size.should == 2
    end

    it 'should filter by state and the other attributes' do
      a = MorbidityEvent.create(@event_hash)
      a.save!

      MorbidityEvent.find_all_for_filtered_view(@search_hash).size.should == 1
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:event_types => [])).size.should == 1
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:event_types => ["AssessmentEvent"])).size.should == 0
    end

    it 'should filter by state and the other attributes' do
      a = MorbidityEvent.create(@event_hash)
      a.workflow_state = 'closed'
      a.save!

      disease_id = Factory(:disease).id
      @event_hash['disease_event_attributes'] = {'disease_id' => disease_id }
      b = MorbidityEvent.create(@event_hash)
      b.workflow_state = 'closed'
      b.save!

      @event_hash['event_queue_id'] = @queue.id
      c = MorbidityEvent.create(@event_hash)
      c.workflow_state = 'closed'
      c.save!

      @event_hash['investigator_id'] = @user.id
      d = MorbidityEvent.create(@event_hash)
      d.workflow_state = 'closed'
      d.save!

      MorbidityEvent.find_all_for_filtered_view(@search_hash).size.should == 4
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:states => ['closed'])).size.should == 4
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:diseases => [disease_id])).size.should == 3
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:queues => [@queue.id])).size.should == 2
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:investigators => [@user.id])).size.should == 1
    end

    it 'should filter by queue and the other attributes' do
      @event_hash['event_queue_id'] = @queue.id
      MorbidityEvent.create(@event_hash)

      a = MorbidityEvent.create(@event_hash)
      a.workflow_state = 'closed'
      a.save!

      disease_id = Factory(:disease).id
      @event_hash['disease_event_attributes'] = {'disease_id' => disease_id }
      b = MorbidityEvent.create(@event_hash)
      b.workflow_state = 'closed'
      b.save!

      @event_hash['investigator_id'] = @user.id
      c = MorbidityEvent.create(@event_hash)
      c.workflow_state = 'closed'
      c.save!

      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:queues => [@queue.id])).size.should == 4
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:states => ['closed'])).size.should == 3
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:diseases => [disease_id])).size.should == 2
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:investigators => [@user.id])).size.should == 1
    end

    it "should filter by investigator and the other attributes" do
      @event_hash['investigator_id'] = @user.id
      MorbidityEvent.create(@event_hash)

      @event_hash['workflow_state'] = 'closed'
      a = MorbidityEvent.create(@event_hash)
      a.workflow_state = 'closed'
      a.save!

      disease_id = Factory(:disease).id
      @event_hash['disease_event_attributes'] = {'disease_id' => disease_id }
      b = MorbidityEvent.create(@event_hash)
      b.workflow_state = 'closed'
      b.save!

      @event_hash['event_queue_id'] = @queue.id
      c = MorbidityEvent.create(@event_hash)
      c.workflow_state = 'closed'
      c.save!

      MorbidityEvent.find_all_for_filtered_view(@search_hash).size.should == 4
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:investigators => [@user.id])).size.should == 4
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:states => ['closed'])).size.should == 3
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:diseases => [disease_id])).size.should == 2
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!(:queues => [@queue.id])).size.should == 1
    end

    it "should not show deleted records if told so" do
      @event_hash['investigator_id'] = @user.id
      MorbidityEvent.create!(@event_hash)

      me = MorbidityEvent.create!(@event_hash)
      me.workflow_state = 'closed'
      me.save!

      disease_id = Factory(:disease).id
      @event_hash['disease_event_attributes'] = {'disease_id' => disease_id }
      b = MorbidityEvent.create!(@event_hash)
      b.workflow_state = 'closed'
      b.save!

      @event_hash['event_queue_id'] = @queue.id
      a = MorbidityEvent.create(@event_hash)
      a.workflow_state = 'closed'
      a.soft_delete

      MorbidityEvent.find_all_for_filtered_view(@search_hash).size.should == 4
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!({:do_not_show_deleted => [1], :investigators => [@user.id]})).size.should == 3
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!({:states => ['closed']})).size.should == 2
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!({:diseases => [disease_id]})).size.should == 1
      MorbidityEvent.find_all_for_filtered_view(@search_hash.merge!({:queues => [@queue.id]})).size.should == 0
    end

    it "should sort appropriately" do
      jurisdiction_ids = [create_jurisdiction_entity.id, create_jurisdiction_entity.id, create_jurisdiction_entity.id]
      @user.stubs(:jurisdiction_ids_for_privilege).returns(jurisdiction_ids)

      @event_hash['workflow_state'] = 'new'
      @event_hash['disease_event_attributes'] = {'disease_id' => Factory(:disease).id }
      MorbidityEvent.create(@event_hash)

      @event_hash['workflow_state'] = 'closed'
      @event_hash['disease_event_attributes'] = {'disease_id' => Factory(:disease).id }
      @event_hash.merge!("interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Zulu" } } } )
      @event_hash.merge!("jurisdiction_attributes" => {"secondary_entity_id" => jurisdiction_ids.first})
      MorbidityEvent.create(@event_hash)

      @event_hash['workflow_state'] = 'under_investigation'
      @event_hash['disease_event_attributes'] = {'disease_id' => Factory(:disease).id }
      @event_hash.merge!("interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name"=>"Lima" } } } )
      @event_hash.merge!("jurisdiction_attributes" => {"secondary_entity_id" => jurisdiction_ids.second})
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

  end

  describe "filtering sensitive events" do
    before do
      @event = Factory(:morbidity_event_with_disease)
      @event.disease_event.disease.update_attribute(:sensitive, true)
      @primary_jurisdiction = @event.jurisdiction.secondary_entity_id
      @secondary_jurisdiction = create_jurisdiction_entity.id
      @event.associated_jurisdictions.create(:secondary_entity_id => @secondary_jurisdiction)
    end

    it "should not return sensitive events, if the user doesn't have that privilege" do
      MorbidityEvent.find_all_for_filtered_view(:view_jurisdiction_ids => [@primary_jurisdiction]).size.should == 0
    end

    it "should return senstive events if the user has that privilege in the event's primary jurisdiction" do
      MorbidityEvent.find_all_for_filtered_view({
        :view_jurisdiction_ids => [@primary_jurisdiction],
        :access_sensitive_jurisdiction_ids => [@primary_jurisdiction]
      }).size.should == 1
    end

    it "should return senstive events if the user has that privilege in one of the event's secondary jurisdictions" do
      MorbidityEvent.find_all_for_filtered_view({
        :view_jurisdiction_ids => [@primary_jurisdiction],
        :access_sensitive_jurisdiction_ids => [@secondary_jurisdiction]
      }).size.should == 1
    end
  end

  describe 'form builder cdc export fields' do

    before(:each) do
      @question = Question.create(:data_type => 'radio_button', :question_text => 'Contact?', :short_name => "contact" )
      @question_element = QuestionElement.create(:question => @question)
      @export_column = Factory(:export_column, :start_position => 69, :length_to_output => 1)
      @export_conversion_value = Factory(:export_conversion_value, :value_from => "Unknown", :value_to => "9", :export_column => @export_column)
      @event = Factory.build(:morbidity_event)
      @event.update_attributes({
        "disease_event_attributes" => {
          "disease_id" => Factory(:disease).id },
        "event_name" => "CdcExportHepA",
        "new_radio_buttons" => {
          @question.id.to_s => {
            :radio_button_answer => ['Unknown'],
            :export_conversion_value_id => @export_conversion_value.id }
        }
      })
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
      @event = Factory.build(:morbidity_event)
    end

    it 'should associate address with interested party\'s person_entity on create' do
      @event.address_attributes = { :street_name => "Example Lane" }
      @event.save!
      @event.address.entity_id.should_not be_nil
    end

    it 'should associate address with interested party\'s person_entity on save' do
      @event.save!
      @event.update_attributes("address_attributes" => { "street_name" => 'freshy' })
      @event.address.entity_id.should_not be_nil
    end
  end

  describe "forms assignment during event creation" do

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

      @disease_id = Factory(:disease).id
      @form_hash = {
        "name"=>"Form Assignment Form",
        "short_name"=> Digest::MD5::hexdigest(DateTime.now.to_s),
        "event_type"=>"morbidity_event",
        "disease_ids"=>[@disease_id],
        "jurisdiction_id"=>""
      }
      @jurisdiction_id = create_jurisdiction_entity.id

    end

    it 'should assign available forms at creation time when the event has a jurisdiction and a disease' do
      with_published_form(@form_hash) do |form|
        @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => @disease_id })
        @event_hash = @event_hash.merge("jurisdiction_attributes" => { "secondary_entity_id" => @jurisdiction_id })
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
        @event_hash = @event_hash.merge("jurisdiction_attributes" => { "secondary_entity_id" => @jurisdiction_id })
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
        @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => @disease_id })
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
      @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => @disease_id })
      @event_hash = @event_hash.merge("jurisdiction_attributes" => { "secondary_entity_id" => @jurisdiction_id })
      @event = MorbidityEvent.new(@event_hash)
      @event.form_references.size.should == 0
      @event.save!
      @event.reload
      @event.form_references.size.should == 0
    end

    it 'should still mark the event as having gone through form assignment even when there are no forms for the disease' do
      with_published_form(@form_hash) do |form|
        @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => @disease_id })
        @event_hash = @event_hash.merge("jurisdiction_attributes" => { "secondary_entity_id" => @jurisdiction_id })
        @event = MorbidityEvent.new(@event_hash)
        @event.save!
        @event.undergone_form_assignment.should be_true
      end
    end

  end

  describe "forms assignment during event updates" do

    before(:each) do
      @jurisdiction_id = create_jurisdiction_entity.id
      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
            }
          }
        },
        "jurisdiction_attributes" => { "secondary_entity_id" => @jurisdiction_id }
      }

      @disease_id = Factory(:disease).id
      @form_hash = {
        "name"=>"Form Assignment Form",
        "short_name"=> Digest::MD5::hexdigest(DateTime.now.to_s),
        "event_type"=>"morbidity_event",
        "disease_ids"=>[@disease_id],
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
        @event.update_attributes("disease_event_attributes" => { "disease_id" => @disease_id })
        @event.reload
        @event.form_references.size.should == 1
        @event.undergone_form_assignment.should be_true
      end
    end

    it 'should not assign additional forms at update time when the event has a jurisdiction and a disease but has previously gone through form assignment' do
      @event_hash = @event_hash.merge("disease_event_attributes" => { "disease_id" => @disease_id })
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

    before(:each) do
      @jurisdiction_id = create_jurisdiction_entity.id
      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
            }
          }
        },
        "jurisdiction_attributes" => { "secondary_entity_id" => @jurisdiction_id }
      }

      @disease_id = Factory(:disease).id
      @form_hash = {
        "name"=>"Form Assignment Form",
        "short_name"=> Digest::MD5::hexdigest(DateTime.now.to_s),
        "event_type"=>"morbidity_event",
        "disease_ids"=>[@disease_id],
        "jurisdiction_id"=>""
      }
    end

    it 'should receive a applicable new form if the disease changed before routing' do
      with_published_form(@form_hash) do |form|
        @event = MorbidityEvent.new(@event_hash)
        @event.build_disease_event(:disease_id => Factory(:disease).id)
        @event.save!
        @event.reload
        @event.undergone_form_assignment.should be_true
        @event.form_references.size.should == 0
        @event.save!
        @event.reload
        @event.disease_event.disease_id = @disease_id
        @event.save!
        @event.reload
        @event.form_references.size.should == 1
        @event.route_to_jurisdiction(@jurisdiction_id)
        @event.form_references.size.should == 1
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

      before(:each) do
        @event = Factory(:morbidity_event)
        @template = Factory.build(:form)
        @template.save_and_initialize_form_elements
        @form = @template.publish
      end

      it "should raise an error if form does not exist" do
        lambda { @event.add_forms([999]) }.should raise_error()
      end

      it "should accept a single non-array element" do
        lambda { @event.add_forms(@form.id) }.should_not raise_error()
      end

      it "should accept forms and not just form IDs" do
        lambda { @event.add_forms(@form) }.should_not raise_error()
      end
    end

  end

  describe "removing forms from an event" do

    before(:each) do
      @disease_id = Factory(:disease).id
      @jurisdiction_id = create_jurisdiction_entity.id
      @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Biel",
            }
          }
        },
        "disease_event_attributes" => { "disease_id" => @disease_id },
        "jurisdiction_attributes" => { "secondary_entity_id" => @jurisdiction_id }
      }

      @event = MorbidityEvent.new(@event_hash)

      @form_hash = {
        "name"=>"Form Assignment Form",
        "short_name"=> Digest::MD5::hexdigest(DateTime.now.to_s),
        "event_type"=>"morbidity_event",
        "disease_ids"=>[@disease_id],
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

    before(:each) do
      @user = Factory(:user)
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
      @event = Factory.build(:morbidity_event)
      @event.update_attributes(@event_hash)
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

    before(:each) do
      @jurisdiction_id = create_jurisdiction_entity.id
    end

    describe 'searching for cases by disease' do
      before(:each) do
        @disease_ids = [Factory(:disease).id, Factory(:disease).id, Factory(:disease).id]
        @disease_ids.each do |did|
          event = Factory.build(:morbidity_event)
          event.update_attributes(:disease_event_attributes => { :disease_id => did },
                                  :jurisdiction_attributes => { :secondary_entity_id => @jurisdiction_id } )
        end
      end

      it 'should be done with a single disease' do
        Event.find_by_criteria(:diseases => [@disease_ids.first], :jurisdiction_ids => [@jurisdiction_id]).size.should == 1
      end

      it 'should be done with multiple diseases' do
        Event.find_by_criteria(:diseases => @disease_ids[0, 2], :jurisdiction_ids => [@jurisdiction_id]).size.should == 2
      end

      it 'should ignore empty disease arrays' do
        Event.find_by_criteria(:diseases => [], :jurisdiction_ids => [@jurisdiction_id]).size.should == 3
      end
    end

    describe "finding by criteria" do
      before { Factory(:user) }

      it "should accept a limit for returned results" do
        11.times { Factory(:morbidity_event) }
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

  before :each do
    @user = Factory(:user)
    @jurisdiction_place = create_jurisdiction_entity.place
    @user.stubs(:jurisdictions_for_privilege).with(:create_event).returns([@jurisdiction_place])
  end

  describe "shallow clone" do
    before :each do
      @org_event = Factory(:morbidity_event)
      @org_event.update_attributes(:address_attributes => { :street_name => 'Example Lane' })
      @new_event = @org_event.clone_event
    end

    it "the new event should be persistable without a first reported date" do
      @new_event.first_reported_PH_date.should be_nil
      @new_event.save.should be_true
      @new_event.errors.empty?.should be_true
    end

    it "should copy over demographic information only" do
      @new_event.interested_party.secondary_entity_id.should == @org_event.interested_party.secondary_entity_id
      @new_event.jurisdiction.name.should == @jurisdiction_place.name
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

    it "should first do a shallow clone" do
      @org_event = Factory(:morbidity_event)
      @new_event = @org_event.clone_event

      @new_event.interested_party.secondary_entity_id.should == @org_event.interested_party.secondary_entity_id
      @new_event.jurisdiction.name.should == @jurisdiction_place.name
      @new_event.should be_new
    end

    it "the new event should be persistable without a first reported date" do
      @org_event = Factory(:morbidity_event)
      @new_event = @org_event.clone_event

      @new_event.first_reported_PH_date.should be_nil
      @new_event.save.should be_true
      @new_event.errors.empty?.should be_true
    end

    it "should copy over disease information, but not the actual disease" do
      @event_hash = { "disease_event_attributes" => {:disease_id => Factory(:disease).id,
        :hospitalized_id => external_codes(:yesno_yes).id,
        :died_id => external_codes(:yesno_no).id,
        :disease_onset_date => Date.today - 1,
        :date_diagnosed => Date.today
      }}
      @org_event = Factory.build(:morbidity_event)
      @org_event.update_attributes(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @new_event.disease_event.disease_id.should be_blank
      @new_event.disease_event.hospitalized_id.should == @org_event.disease_event.hospitalized_id
      @new_event.disease_event.died_id.should == @org_event.disease_event.died_id
      @new_event.disease_event.disease_onset_date.should == @org_event.disease_event.disease_onset_date
      @new_event.disease_event.date_diagnosed.should == @org_event.disease_event.date_diagnosed
    end

    it "should copy over hospitalization data even if there are no additional attributes beyond a hospital" do
      @event_hash = { "hospitalization_facilities_attributes" => [
        { "secondary_entity_id" => Factory(:hospitalization_facility_entity).id },
        { "secondary_entity_id" => Factory(:hospitalization_facility_entity).id }
      ]}
      @org_event = Factory.build(:morbidity_event)
      @org_event.update_attributes(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @new_event.hospitalization_facilities.size.should == 2

      @new_event.hospitalization_facilities.each do |h|
        h.hospitals_participation.should be_nil
      end
    end

    it "should copy over hospitalization data" do
      facility_entities = [Factory(:hospitalization_facility_entity).id, Factory(:hospitalization_facility_entity).id]
      @event_hash = { "hospitalization_facilities_attributes" => [
        {
          :secondary_entity_id => facility_entities.first,
          :hospitals_participation_attributes => {
            :admission_date => Date.today - 4,
            :discharge_date => Date.today - 3,
            :medical_record_number => "1234"
          }
        },
        {
          :secondary_entity_id => facility_entities.second,
          :hospitals_participation_attributes => {
            :admission_date => Date.today - 2,
            :discharge_date => Date.today - 1,
            :medical_record_number => "5678"
          }
        }
      ]}
      @org_event = Factory.build(:morbidity_event)
      @org_event.update_attributes(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @new_event.hospitalization_facilities.size.should == 2
      @new_event.hospitalization_facilities.each do |h|
        if h.secondary_entity_id == facility_entities.first
          h.hospitals_participation.admission_date.should == Date.today - 4
          h.hospitals_participation.discharge_date.should == Date.today - 3
          h.hospitals_participation.medical_record_number == "1234"
        elsif h.secondary_entity_id == facility_entities.second
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

      @event_hash = { "treatments_attributes" =>
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
      ]}
      @org_event = Factory.build(:morbidity_event)
      @org_event.interested_party.update_attributes(@event_hash)
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
      @event_hash = { "risk_factor_attributes" =>
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
      }}

      @org_event = Factory.build(:morbidity_event)
      @org_event.interested_party.update_attributes(@event_hash)
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
      @event_hash = { "clinicians_attributes" => [
        "person_entity_attributes" => {
          "person_attributes" => {
            "last_name"=>"Bombay",
            "person_type" => 'clinician'
          }
        }
      ]}

      @org_event = Factory.build(:morbidity_event)
      @org_event.update_attributes(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @org_event.clinicians.first.secondary_entity_id.should == @new_event.clinicians.first.secondary_entity_id
    end

    it "should copy over diagnostic data" do
      @event_hash = { "diagnostic_facilities_attributes" => [{"place_entity_attributes" => {"place_attributes" => {"name"=>"DiagOne"}}}]}
      @org_event = Factory.build(:morbidity_event)
      @org_event.update_attributes(@event_hash)
      @new_event = @org_event.clone_event(['clinical'])

      @org_event.diagnostic_facilities.first.secondary_entity_id.should == @new_event.diagnostic_facilities.first.secondary_entity_id
    end

    it "should copy over lab data" do
      @event_hash = { "labs_attributes" => [
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
              "test_type" => Factory(:common_test_type),
              "test_result_id" => external_codes(:state_alaska).id, # It's not really important what it is, just that it's there.  Tired of adding fixtures.
              "test_status_id" => external_codes(:state_alabama).id, # It's not really important what it is, just that it's there.  Tired of adding fixtures.
              "result_value" => "one",
              "units" => "two",
              "reference_range" => "three",
              "comment" => "four"
            }
          ]
        }
      ]}

      @org_event = Factory.build(:morbidity_event)
      @org_event.update_attributes(@event_hash)
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
      @event_hash = {
        "reporting_agency_attributes" => {
          "place_entity_attributes" => {
            "place_attributes" => {
              "name"=>"AgencyOne",
            }
          }
        },
        "reporter_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Starr"
            }
          }
        }
      }

      @org_event = Factory.build(:morbidity_event)
      @org_event.update_attributes(@event_hash)
      @new_event = @org_event.clone_event(['reporting'])

      @org_event.reporting_agency.secondary_entity_id.should == @new_event.reporting_agency.secondary_entity_id
      @org_event.reporter.secondary_entity_id.should == @new_event.reporter.secondary_entity_id
    end

    it "should copy over forms and answers" do
      disease_id = Factory(:disease).id
      @event_hash = { "disease_event_attributes" => {:disease_id => disease_id},
                      "jurisdiction_attributes" => {:secondary_entity_id => create_jurisdiction_entity.id} }

      form = Form.new
      form.event_type = "morbidity_event"
      form.name = "AIDS Form"
      form.short_name = 'event_spec_aids'
      form.disease_ids = [disease_id]
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

      @org_event = Factory.build(:morbidity_event)
      @org_event.update_attributes(@event_hash)
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
      @org_event = Factory.build(:morbidity_event)
      @org_event.update_attributes(:notes_attributes => [ { "note" => "note 1", "note_type" => "clinical" }, { "note" => "note 2", "note_type" => "administrative" } ])
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

  describe "filtering sensitive diseases" do
    before do
      destroy_fixture_data
      @sensitive_event = Factory(:morbidity_event_with_sensitive_disease)
      @nonsensitive_event = Factory(:morbidity_event_with_disease)
      @event_without_disease = Factory(:morbidity_event)

      @sensitive_role = create_role_with_privileges! 'Sensitive', :access_sensitive_diseases
      @privileged_user = create_user_in_role! 'Sensitive', 'sensitive'
      @unprivileged_user = Factory(:user)
    end

    it "shows all events to a privileged user" do
      Event.sensitive(@privileged_user).length.should == 3
    end

    it "does not show sensitive events to an unprivileged user" do
      Event.sensitive(@unprivileged_user).length.should == 2
    end

    it "does not show a privileged user extrajurisdictional sensitive events" do
      primary_jurisdiction_id = @sensitive_event.jurisdiction.secondary_entity_id
      primary_jurisdiction_id.should_not be_nil
      @privileged_user.role_memberships.find_by_role_id_and_jurisdiction_id(@sensitive_role.id, primary_jurisdiction_id).destroy
      Event.sensitive(@privileged_user).length.should == 2
    end

    it "shows a privileged user events by secondary jurisdiction" do
      # take away the user's right to see sensitive diseases in the
      # sensitive event's primary jurisdiction
      primary_jurisdiction_id = @sensitive_event.jurisdiction.secondary_entity_id
      primary_jurisdiction_id.should_not be_nil
      @privileged_user.role_memberships.find_by_role_id_and_jurisdiction_id(@sensitive_role.id, primary_jurisdiction_id).destroy

      # find another jurisdiction in which the user is entitled to see
      # sensitive diseases
      jurisdictions = @privileged_user.jurisdictions_for_privilege(:access_sensitive_diseases).map(&:entity)
      jurisdictions.should_not be_nil
      jurisdictions.count.should > 1
      secondary_jurisdiction = jurisdictions.find { |j| j != @sensitive_event.jurisdiction.place_entity }

      # associate that other jurisdiction as a secondary jurisdiction
      Factory(:associated_jurisdiction, :event_id => @sensitive_event.id, :place_entity => secondary_jurisdiction)

      # verify that the user can still see the event
      Event.sensitive(@privileged_user).length.should == 3
    end

    it "returns one object per event (as opposed to one per jurisdiction)" do
      # find another jurisdiction in which the user is entitled to see
      # sensitive diseases
      jurisdictions = @privileged_user.jurisdictions_for_privilege(:access_sensitive_diseases).map(&:entity)
      jurisdictions.should_not be_nil
      jurisdictions.count.should > 1
      secondary_jurisdiction = jurisdictions.find { |j| j != @sensitive_event.jurisdiction.place_entity }

      # associate that other jurisdiction as a secondary jurisdiction
      Factory(:associated_jurisdiction, :event_id => @sensitive_event.id, :place_entity => secondary_jurisdiction)

      # verify that the user can still see the event (once)
      events = Event.sensitive(@privileged_user)
      events.length.should == 3
    end

    it 'does not show an unprivileged user sensitive events' do
      Event.find_by_criteria(:sw_last_name => @sensitive_event.interested_party.person_entity.person.last_name).count.should == 0
      Event.find_by_criteria(:sw_last_name => @nonsensitive_event.interested_party.person_entity.person.last_name).count.should == 1
      Event.find_by_criteria(:sw_last_name => @nonsensitive_event.interested_party.person_entity.person.last_name).count.should == 1
    end

    it 'shows a privileged user an event by primary jurisdiction' do
      allowed_ids = [ @sensitive_event.jurisdiction.secondary_entity_id ]

      Event.find_by_criteria(:sw_last_name => @sensitive_event.interested_party.person_entity.person.last_name,
        :access_sensitive_jurisdiction_ids => allowed_ids).count.should == 1
      Event.find_by_criteria(:sw_last_name => @nonsensitive_event.interested_party.person_entity.person.last_name,
        :access_sensitive_jurisdiction_ids => allowed_ids).count.should == 1
      Event.find_by_criteria(:sw_last_name => @nonsensitive_event.interested_party.person_entity.person.last_name,
        :access_sensitive_jurisdiction_ids => allowed_ids).count.should == 1
    end

    it 'shows a privileged user an event by secondary jurisdiction' do
      associated_jurisdiction = create_jurisdiction_entity
      Factory(:associated_jurisdiction, :event_id => @sensitive_event.id, :place_entity => associated_jurisdiction)
      allowed_ids = [ associated_jurisdiction.id ]

      Event.find_by_criteria(:sw_last_name => @sensitive_event.interested_party.person_entity.person.last_name,
        :access_sensitive_jurisdiction_ids => allowed_ids).count.should == 1
      Event.find_by_criteria(:sw_last_name => @nonsensitive_event.interested_party.person_entity.person.last_name,
        :access_sensitive_jurisdiction_ids => allowed_ids).count.should == 1
      Event.find_by_criteria(:sw_last_name => @nonsensitive_event.interested_party.person_entity.person.last_name,
        :access_sensitive_jurisdiction_ids => allowed_ids).count.should == 1
    end

  end
end

describe Event do

  describe "#is_sensitive?" do

    it "should return true if it has a sensitive disease associated" do
      event = create_morbidity_event(:disease => Factory.create(:disease, :disease_name => 'AIDS', :sensitive => true))
      event.sensitive?.should be_true
    end

    it "should return false if it does not have a sensitive disease associated" do
      event = create_morbidity_event(:disease => Factory.create(:disease, :disease_name => 'The Pops', :sensitive => false))
      event.sensitive?.should be_false
    end

    it "should return false if there is no disease event associated" do
      event = create_morbidity_event
      event.disease_event = nil
      event.save!
      event.sensitive?.should be_false
    end

    it "should return false if there is no disease associated" do
      event = create_morbidity_event
      event.disease_event = Factory.create(:disease_event, :event => event)
      event.disease_event.disease = nil
      event.save!
      event.sensitive?.should be_false
    end
  end
end
