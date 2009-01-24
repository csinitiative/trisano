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

  describe "Initializing a new contact event from an existing morbidity event" do

    patient_attrs = {
      "active_patient" => {
        "entity_type"=>"person", 
        "person" => {
          "last_name"=>"Green"
        }
      },
      :active_jurisdiction => { 
        :secondary_entity_id => 1
      }
    }

    describe "When event has no contacts" do
      it "should return an empty array" do
        event = MorbidityEvent.new(patient_attrs)
        contact_events = ContactEvent.initialize_from_morbidity_event(event)
        contact_events.class.should eql(Array)
        contact_events.length.should == 0
      end
    end

    describe "When event has one contact and a disease" do
      fixtures :users
      
      before(:each) do
        @user = users(:default_user)
        User.stub!(:current_user).and_return(@user)

        contact_hash = { :new_contact_attributes => [ {:last_name => "White"} ],
                         :disease => {:disease_id => diseases(:chicken_pox).id} }
        event = MorbidityEvent.new(patient_attrs.merge(contact_hash))
        @contact_events = ContactEvent.initialize_from_morbidity_event(event)
      end

      it "should return a one element array" do
        @contact_events.length.should == 1
      end

      it "should have a single contact_event in the array" do
        @contact_events.first.class.should eql(ContactEvent)
      end

      describe "the returned contact" do
        before(:each) do
          @contact_event = @contact_events.first
        end

        it "should have a primary entity equal to the original contact" do
          @contact_event.participations.each do |participation|
            if participation.role_id == codes(:participant_interested_party)
              participation.primary_entity.person.last_name.should == "White"
            end
          end
        end

        it "should have the same jurisdiction as the original contact" do
          @contact_event.participations.each do |participation|
            if participation.role_id == codes(:participant_jurisdiction)
              participation.secondary_entity_id.should == 1
            end
          end
        end

        it "should have the original patient as a contact" do
          @contact_event.participations.each do |participation|
            if participation.role_id == codes(:participant_contact)
              participation.secondary_entity.person.last_name.should == "Green"
            end
          end
        end

        it "should have the same disease as the original" do
          @contact_event.disease.disease_id.should == diseases(:chicken_pox).id
        end
      end
    end

    describe "when event has two contacts" do
      fixtures :users
      
      before(:each) do
        @user = users(:default_user)
        User.stub!(:current_user).and_return(@user)
      end

      it "should return an array of two elements" do
        contact_hash = { :new_contact_attributes => [ {:last_name => "White"}, {:last_name => "Black"} ] }
        event = MorbidityEvent.new(patient_attrs.merge(contact_hash))
        contact_events = ContactEvent.initialize_from_morbidity_event(event)
        contact_events.length.should == 2
      end
    end

  end
end
