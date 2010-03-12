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
        User.stubs(:current_user).returns(@user)

        place_hash = { :place_child_events_attributes => [ { "interested_place_attributes" => { "place_entity_attributes" => { "place_attributes" => { "name" => "Davis Natatorium" } } },
              "participations_place_attributes" => {} } ],
          :disease_event_attributes => {:disease_id => diseases(:chicken_pox).id} }

        event = MorbidityEvent.new(patient_attrs.merge(place_hash))
        event.save
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

  describe "When added to an event using an existing place entity" do

    before(:each) do
      @user = Factory.create(:user)
      User.stubs(:current_user).returns(@user)
      @place_entity = Factory.create(:place_entity)
      @place_event_hash = { :place_child_events_attributes => [{
            "interested_place_attributes"=>{
              "primary_entity_id"=>"#{@place_entity.id}"
            },
            "participations_place_attributes"=>{
              "date_of_exposure"=>""}
          }
        ]}
    end

    it "should receive the place entity's canonical address if one exists" do
      event = Factory.create(:morbidity_event)
      canonical_address = Factory.create(:address, :entity_id => @place_entity.id)
      event.update_attributes(@place_event_hash)
      event.place_child_events.reload
      new_place_address = event.place_child_events.first.interested_place.primary_entity.addresses.first

      new_place_address.should_not be_nil
      new_place_address.street_number.should == canonical_address.street_number
      new_place_address.street_name.should == canonical_address.street_name
      new_place_address.unit_number.should == canonical_address.unit_number
      new_place_address.city.should == canonical_address.city
      new_place_address.state_id.should == canonical_address.state_id
      new_place_address.county_id.should == canonical_address.county_id
      new_place_address.postal_code.should == canonical_address.postal_code
    end

    it "should not have an address if the place entity does not have canonical address" do
      event = Factory.create(:morbidity_event)
      place_entity = Factory.create(:place_entity)
      event.update_attributes(@place_event_hash)
      event.place_child_events.reload
      new_place_address = event.place_child_events.first.interested_place.primary_entity.addresses.first
      new_place_address.should be_nil
    end
  end

  describe "adding an address to a place event's interested place" do

    it "should establish a canonical address the first time an address is provided" do
      place_event = Factory.create(:place_event)
      place_entity = place_event.interested_place.primary_entity
      place_entity.canonical_address.should be_nil
      address = Factory.create(:address, :event_id => place_event.id, :entity_id => place_entity.id)
      place_entity.reload
      place_entity.canonical_address.should_not be_nil
      place_entity.canonical_address.street_number.should == address.street_number
      place_entity.canonical_address.street_name.should == address.street_name
      place_entity.canonical_address.unit_number.should == address.unit_number
      place_entity.canonical_address.city.should == address.city
      place_entity.canonical_address.county_id.should == address.county_id
      place_entity.canonical_address.state_id.should == address.state_id
      place_entity.canonical_address.postal_code.should == address.postal_code
    end

  end

end
