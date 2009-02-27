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

describe PlaceEvent do

  fixtures :diseases

  # TGRII: Move these tests to Event
  describe "Initializing a new place event from an existing morbidity event" do

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

    describe "When event has no place exposures" do
      it "should return an empty array" do
        event = MorbidityEvent.new(patient_attrs)
        event.place_child_events.length.should == 0
      end
    end

    describe "When event has one place exposure and a disease" do
      fixtures :users
      
      before(:each) do
        mock_user
        @user = users(:default_user)
        User.stub!(:current_user).and_return(@user)

        place_hash = { :place_child_events_attributes => [ { "interested_place_attributes" => { "place_entity_attributes" => { "place_attributes" => { "name" => "Davis Natatorium" } } },
                                                             "participations_place_attributes" => {} } ],
                       :disease_event_attributes => {:disease_id => diseases(:chicken_pox).id} }

        event = MorbidityEvent.new(patient_attrs.merge(place_hash))
        event.initialize_children
        @place_event = event.place_child_events[0]
      end

      it "should have the same jurisdiction as the original event" do
        @place_event.jurisdiction.secondary_entity_id.should == 1
      end

      it "should have the same disease as the original" do
        @place_event.disease_event.disease_id.should == diseases(:chicken_pox).id
      end
    end
  end
end
