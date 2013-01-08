# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

describe ContactEvent do

  fixtures :diseases, :places, :places_types

  describe "validating" do
    
    it 'should not be valid for disposition dates before contact patient birthday' do
      contact = Factory.create(:contact_event)
      contact.interested_party.person_entity.person.birth_date = 1.day.ago
      contact.participations_contact.disposition_date = 2.days.ago
      contact.save
      contact.participations_contact.errors.on(:disposition_date).should == "cannot be earlier than birth date"

      contact.participations_contact.disposition_date = 1.days.ago
      contact.save
      contact.participations_contact.errors.on(:disposition_date).should be_nil
    end

    it 'should be valid for disposition dates when there is no contact patient birthday' do
      contact = Factory.create(:contact_event)
      contact.interested_party.person_entity.person.birth_date = nil
      contact.participations_contact.disposition_date = 2.days.ago
      contact.save
      contact.participations_contact.errors.on(:disposition_date).should be_nil
    end

  end


  # TGRII: Move these tests to Event
  describe "Initializing a new contact event from an existing morbidity event" do

    patient_attrs = {
      "first_reported_PH_date" => Date.yesterday.to_s(:db),
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => {
            "last_name"=>"Green"
          }
        }
      },
      :jurisdiction_attributes => {
        :secondary_entity_id => 102
      }
    }

    describe "When event has no contacts" do
      it "should return an empty array" do
        event = MorbidityEvent.new(patient_attrs)
        event.contact_child_events.length.should == 0
      end
    end

    describe "When event has one contact and a disease" do
      fixtures :users

      before(:each) do
        mock_user

        contact_hash = { :contact_child_events_attributes => [ { "interested_party_attributes" => { "person_entity_attributes" => { "person_attributes" => { "last_name" => "White" },
                  "telephones_attributes" => { "99" => { "phone_number" => "" } } } },
              "participations_contact_attributes" => {} } ] }

        event = MorbidityEvent.new(patient_attrs.merge(contact_hash))
        disease_event = DiseaseEvent.new(:disease_id => diseases(:chicken_pox).id)
        #event.save!
        event.build_disease_event(disease_event.attributes)
        event.save!
        event.reload

        @contact_event = event.contact_child_events[0]
      end

      it "should have the same jurisdiction as the original patient" do
        @contact_event.jurisdiction.secondary_entity_id.should == 102
      end

      it "should have the same disease as the original" do
        @contact_event.disease_event.disease_id.should == diseases(:chicken_pox).id
      end
    end
  end

  describe "Promoting a contact to a cmr" do
    fixtures :entities, :places, :users

    before(:each) do
      #death to fixture pie
      Form.destroy_all
      ActiveRecord::Base.connection.execute('DELETE FROM diseases_forms')

      mock_user
      @disease = Factory.build(:disease)

      @c = ContactEvent.new("interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name" => "White" } } } )
      @c.build_disease_event(:disease => @disease)
      @c.build_jurisdiction(:secondary_entity_id => entities(:Davis_County).id)
      @c.save!

      @form =  Factory.build(:form, :event_type => "contact_event")
      @form.save_and_initialize_form_elements
      @published_form = @form.publish
      @c.add_forms(@published_form.id)
      @c.save!

      @morb_form_1 = Factory.build(:form, :event_type => "morbidity_event")
      @morb_form_1.diseases << @disease
      @morb_form_1.save_and_initialize_form_elements
      @published_morb_form_1 = @morb_form_1.publish

      @morb_form_2 = Factory.build(:form, :event_type => "morbidity_event")
      @morb_form_2.diseases << @disease
      @morb_form_2.save_and_initialize_form_elements
      @published_morb_form_2 = @morb_form_2.publish

      @m = @c.promote_to_morbidity_event
    end

    it "should freeze the contact event" do
      @c.should be_frozen
    end

    it "should return a morbidity event" do
      @m.should be_an_instance_of(MorbidityEvent)
    end

    it "should leave contact forms intact" do
      form_ids = @c.form_references.collect { |f| f.form_id }
      form_ids.include?(@published_form.id).should be_true
    end

    it "should add morbidity forms" do
      form_ids = @c.form_references.collect { |f| f.form_id }
      form_ids.include?(@published_morb_form_1.id).should be_true
      form_ids.include?(@published_morb_form_2.id).should be_true
    end

    it "should be in a accepted_by_lhd state" do
      @c.workflow_state == 'accepted_by_lhd'
    end

    it "leaves first reported to Public Health blank for a user to enter" do
      @m.first_reported_PH_date.should be_nil
      @m.should_not be_valid
    end
  end
end
