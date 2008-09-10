# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

  describe "Initializing a new place event from an existing morbidity event" do

    patient_attrs = {
      "active_patient" => {
        "active_primary_entity" => {
          "entity_type"=>"person", 
          "person" => {
            "last_name"=>"Green"
          }
        }
      },
      :active_jurisdiction => { 
        :secondary_entity_id => 1
      }
    }

    describe "When event has no place exposures" do
      it "should return an empty array" do
        event = MorbidityEvent.new(patient_attrs)
        place_events = PlaceEvent.initialize_from_morbidity_event(event)
        place_events.class.should eql(Array)
        place_events.length.should == 0
      end
    end

    describe "When event has one place exposure and a disease" do
      
      before(:each) do
        place_hash = { :new_place_exposure_attributes => [ {:name => "Davis Natatorium"} ],
                         :disease => {:disease_id => diseases(:chicken_pox).id} }
        event = MorbidityEvent.new(patient_attrs.merge(place_hash))
        @place_events = PlaceEvent.initialize_from_morbidity_event(event)
      end

      it "should return a one element array" do
        @place_events.length.should == 1
      end

      it "should have a single place_event in the array" do
        @place_events.first.class.should eql(PlaceEvent)
      end

      describe "the returned place" do
        before(:each) do
          @place_event = @place_events.first
        end

        it "should have a primary entity equal to the original place exposure" do
          @place_event.participations.each do |participation|
            if participation.role_id == codes(:participant_place_exposure)
              participation.primary_entity.place_temp.name.should == "Davis Natatorium"
            end
          end
        end

        it "should have the same jurisdiction as the original event" do
          @place_event.participations.each do |participation|
            if participation.role_id == codes(:participant_jurisdiction)
              participation.active_secondary_entity_id.should == 1
            end
          end
        end

        it "should have the original patient as a contact" do
          @place_event.participations.each do |participation|
            if participation.role_id == codes(:participant_contact)
              participation.secondary_entity.person.last_name.should == "Green"
            end
          end
        end

        it "should have the same disease as the original" do
          @place_event.disease.disease_id.should == diseases(:chicken_pox).id
        end
      end
    end

    describe "when event has two place exposures" do
      it "should return an array of two elements" do
        place_hash = { :new_place_exposure_attributes => [ {:name => "Davis Natatorium"}, {:name => "Takigawa Soba"} ] }
        event = MorbidityEvent.new(patient_attrs.merge(place_hash))
        place_events = PlaceEvent.initialize_from_morbidity_event(event)
        place_events.length.should == 2
      end
    end

  end
end
