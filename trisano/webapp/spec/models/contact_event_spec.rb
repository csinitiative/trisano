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
        @user = users(:default_user)
        User.stub!(:current_user).and_return(@user)

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
end
