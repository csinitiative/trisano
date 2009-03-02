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

describe ContactEvent do

  fixtures :diseases

  # TGRII: Move these tests to Event
  describe "Initializing a new contact event from an existing morbidity event" do

    patient_attrs = {
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => {
            "last_name"=>"Green"
          }
        }
      },
      :jurisdiction_attributes => { 
        :secondary_entity_id => 1
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
                                                                 "participations_contact_attributes" => {} } ],
                         :disease_event_attributes => {:disease_id => diseases(:chicken_pox).id} }

        event = MorbidityEvent.new(patient_attrs.merge(contact_hash))
        event.initialize_children
        @contact_event = event.contact_child_events[0]
      end

      it "should have the same jurisdiction as the original patient" do
        @contact_event.jurisdiction.secondary_entity_id.should == 1
      end

      it "should have the same disease as the original" do
        @contact_event.disease_event.disease_id.should == diseases(:chicken_pox).id
      end
    end
  end

  describe "Promoting a contact to a cmr" do
    fixtures :diseases, :entities, :forms, :diseases_forms

    before(:each) do
      mock_user
      
      @c = ContactEvent.new
      @c.build_disease_event(:disease => diseases(:anthrax))
      @c.build_jurisdiction(:secondary_entity_id => entities(:Davis_County).id)
      @c.get_investigation_forms
      @c.save
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
      form_ids.include?(forms(:anthrax_form_for_contact_event).id).should be_true
    end

    it "should add morbidity forms" do
      form_ids = @c.form_references.collect { |f| f.form_id }
      form_ids.include?(forms(:anthrax_form_all_jurisdictions_1).id).should be_true
      form_ids.include?(forms(:anthrax_form_all_jurisdictions_2).id).should be_true
    end

    it "should be in a NEW state" do
      @c.event_status.should == "NEW"
    end
  end
end
