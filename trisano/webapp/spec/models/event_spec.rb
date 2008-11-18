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

describe MorbidityEvent do
  fixtures :events, :participations, :entities, :places, :people, :lab_results, :hospitals_participations

  #  event_hash = {
  #    "active_patient" => {
  #      "person" => {
  #        "last_name"=>"Green"
  #      }
  #    }
  #  }

  def with_event(event_hash=@event_hash)
    event = MorbidityEvent.new event_hash
    event.save
    event.reload
    yield event if block_given?
  end

  describe "Managing Jurisdictions" do
  end

  describe "Managing associations." do
    before(:each) do
      @event_hash = {
        "active_patient" => {
          "person" => {
            "last_name"=>"Green"
          }
        }
      }
    end

    describe "Handling new labs and lab results" do

      describe "Receiving a new lab and lab result" do

        before(:each) do
          new_lab_hash_1 = {
            "new_lab_attributes" => 
              [
              { "lab_entity_id" => nil, "name"=>"New Lab One", "lab_result_text"=>"New Lab One Result", "test_type" => "Urinalysis", "interpretation" => "Healthy"}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_lab_hash_1))
        end

        it "should create a new participation linked to the event" do
          lambda {@event.save}.should change {Participation.count}.by(2)
          @event.participations.find_by_role_id(codes(:participant_testing_lab).id).should_not be_nil
        end

        it "should add a new lab" do
          lambda {@event.save}.should change {Place.count}.by(1)
          @event.labs.first.secondary_entity.place_temp.name.should == "New Lab One"
        end

        it "should add a new lab result" do
          lambda {@event.save}.should change {LabResult.count}.by(1)
          @event.labs.first.lab_results.first.lab_result_text.should == "New Lab One Result"
          @event.labs.first.lab_results.first.test_type.should == "Urinalysis"
          @event.labs.first.lab_results.first.interpretation.should == "Healthy"
        end
      end

      describe "Receiving an existing lab and a new lab result" do

        before(:each) do
          exisitng_lab_hash_1 = {
            "new_lab_attributes" => 
              [
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(exisitng_lab_hash_1))
        end

        it "should not create a new lab" do
          lambda {@event.save}.should_not change {Place.count}
        end

        it "should link to the existing lab" do
          @event.save
          @event.labs.first.secondary_entity.should eql(entities(:Existing_Lab_One))
        end

        it "should add a new lab result" do
          lambda {@event.save}.should change {LabResult.count}.by(1)
          @event.labs.first.lab_results.first.lab_result_text.should == "Existing Lab Result"
        end
      end

      describe "Receiving a lab with no lab result" do

        before(:each) do
          new_lab_hash_1 = {
            "new_lab_attributes" => 
              [
              { "lab_entity_id" => nil, "name"=>"New Lab One", "lab_result_text"=>""}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_lab_hash_1))
        end

        it "should be invalid" do
          @event.should_not be_valid
          @event.labs.first.lab_results.first.should have(1).error_on(:lab_result_text)
        end

      end

      describe "Receiving a lab result with no lab" do

        before(:each) do
          new_lab_hash_1 = {
            "new_lab_attributes" => 
              [
              { "lab_entity_id" => nil, "name"=>"", "lab_result_text"=>"Whatever"}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_lab_hash_1))
        end

        it "should be invalid" do
          @event.should_not be_valid
        end
      end

      describe "Receiving a lab result with no lab and no lab result information" do

        before(:each) do
          new_lab_hash_1 = {
            "new_lab_attributes" => 
              [
              { "lab_entity_id" => nil, "name"=>"", "lab_result_text"=>"", "test_type" => "", "interpretation" => ""}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_lab_hash_1))
        end


        it "should do nothing" do
          @event.should be_valid
          @event.labs.should be_empty
        end
      end

      describe "Receiving two labs/lab results, one old one new" do

        before(:each) do
          new_lab_hash_1 = {
            "new_lab_attributes" => 
              [
              { "lab_entity_id" => nil, "name"=>"New Lab One", "lab_result_text"=>"New Lab One Result"},
              { "lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_lab_hash_1))
        end

        it "should create one new lab" do
          lambda {@event.save}.should change {Place.count}.by(1)
          lab_names = @event.labs.collect { |lab| lab.secondary_entity.place_temp.name }
          lab_names.size.should == 2
          lab_names.include?("New Lab One").should be_true
        end
        
        it "should create two new lab results" do
          lambda {@event.save}.should change {LabResult.count}.by(2)
        end

        it "should create three participations (1 patient + 2 labs)" do
          lambda {@event.save}.should change {Participation.count}.by(3)
        end
      end

      describe "Receiving two labs, both existing" do

        before(:each) do
          new_lab_hash_1 = {
            "new_lab_attributes" => 
              [
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"},
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_lab_hash_1))
        end

        it "should not create any new labs" do
          lambda {@event.save}.should_not change {Place.count}
        end

        it "should create two new lab results" do
          lambda {@event.save}.should change {LabResult.count}.by(2)
        end
      end

      describe "Receiving a new lab result for an existing event and participation" do
        before(:each) do
          existing_lab_hash_1 = {
            "new_lab_attributes" => 
              [
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"A new result"}
            ]
          }
          @new_lab_hash = @event_hash.merge(existing_lab_hash_1)
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should not create any participations" do
          lambda {@event.update_attributes(@new_lab_hash)}.should_not change {Participation.count}
        end

        it "should create one new lab result" do
          lambda {@event.update_attributes(@new_lab_hash)}.should change {LabResult.count}.by(1)
        end
      end
    end

    describe "Handling exisiting lab results" do

      describe "Receiving an edited lab result" do

        before(:each) do
          @existing_lab_hash_1 = {
            "existing_lab_attributes" => { "#{lab_results(:lab_guys_lab_result).id}" => {"lab_result_text"=>"Negative"}}
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should update the existing lab_result" do
          lambda {@event.update_attributes(@existing_lab_hash_1)}.should_not change {LabResult.count}
          @event.labs.first.lab_results.first.lab_result_text.should == "Negative"
        end
      end

      describe "Receiving no lab results" do

        before(:each) do
          @existing_lab_hash_1 = {
            "existing_lab_attributes" => {}
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should delete existing lab results and participation" do
          lambda {@event.update_attributes(@existing_lab_hash_1)}.should change {LabResult.count + Participation.count}.by(-2)
        end

      end

    end

    describe "Handling new hospitals" do

      describe "Receiving a hospital and hospitalization dates" do

        before(:each) do
          new_hospital_hash = {
            "new_hospital_attributes" => 
              [
              {"secondary_entity_id" => places(:AVH).id, "admission_date" => "2008-07-15", "discharge_date" => "2008-07-16", "medical_record_number" => "1234"}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_hospital_hash))
        end

        it "should create a new participation linked to the event" do
          lambda {@event.save}.should change {Participation.count}.by(2)
          @event.participations.find_by_role_id(codes(:participant_hospitalized_at).id).should_not be_nil
        end

        it "should add hospitalization dates and medical record number to hospitals_participation table " do
          lambda {@event.save}.should change {HospitalsParticipation.count}.by(1)
          @event.hospitalized_health_facilities.first.hospitals_participation.admission_date.should == Date.parse("2008-07-15")
          @event.hospitalized_health_facilities.first.hospitals_participation.discharge_date.should == Date.parse("2008-07-16")
          @event.hospitalized_health_facilities.first.hospitals_participation.medical_record_number.should == "1234"
        end
      end

      describe "Receiving a hospital with no hospitalization dates" do

        before(:each) do
          new_hospital_hash = {
            "new_hospital_attributes" => 
              [
              {"secondary_entity_id" => places(:AVH).id, "admission_date" => "", "discharge_date" => "", "medical_record_number" => ""}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_hospital_hash))
        end

        it "should be valid" do
          @event.should be_valid
        end

        it "should create a new participation linked to the event" do
          lambda {@event.save}.should change {Participation.count}.by(2)
          @event.participations.find_by_role_id(codes(:participant_hospitalized_at).id).should_not be_nil
        end

        it "should not add any rows to hospitals_participation table " do
          lambda {@event.save}.should_not change {HospitalsParticipation.count}
        end
      end

      describe "Receiving a hospital and out of order hospitalization dates" do

        before(:each) do
          new_hospital_hash = {
            "new_hospital_attributes" => 
              [
              {"secondary_entity_id" => places(:AVH).id, "admission_date" => "2008-07-16", "discharge_date" => "2008-07-15", "medical_record_number" => ""}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_hospital_hash))
        end

        it "should be invalid" do
          @event.should_not be_valid
        end

      end

      describe "Receiving hospitalization dates but no hospital" do

        before(:each) do
          new_hospital_hash = {
            "new_hospital_attributes" => 
              [
              {"secondary_entity_id" => "", "admission_date" => "2008-07-14", "discharge_date" => "2008-07-15", "medical_record_number" => "1234"}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_hospital_hash))
        end

        it "should make the participation invalid" do
          @event.hospitalized_health_facilities.first.should_not be_valid
          @event.hospitalized_health_facilities.first.should have(1).error_on(:base)
        end

      end

      describe "Receiving new, empty hospitalization data" do

        before(:each) do
          new_hospital_hash = {
            "new_hospital_attributes" =>
              [
              { "secondary_entity_id" => "", "admission_date" => "", "discharge_date" => "", "medical_record_number" => ""}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_hospital_hash))
        end

        it "should do nothing" do
          @event.should be_valid
          @event.hospitalized_health_facilities.should be_empty
        end

      end

    end

    describe "Receiving existing hospitalization data" do

      describe "Receiving edited hospitalization data" do
        before(:each) do
          @existing_hospital_hash = {
            "existing_hospital_attributes" => { "#{participations(:marks_hospitalized_at).id}" => {"secondary_entity_id" => "#{entities(:BRVH).id}", "admission_date" => "2008-07-14", "discharge_date" => "2008-07-15", "medical_record_number" => "1234"} }
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should update the existing hospital" do
          lambda {@event.update_attributes(@existing_hospital_hash)}.should_not change {Participation.count + HospitalsParticipation.count}
          @event.hospitalized_health_facilities.first.secondary_entity.current_place.name.should == "Bear River Valley Hospital"
          @event.hospitalized_health_facilities.first.hospitals_participation.admission_date.should == Date.parse("2008-07-14")
          @event.hospitalized_health_facilities.first.hospitals_participation.discharge_date.should == Date.parse("2008-07-15")
          @event.hospitalized_health_facilities.first.hospitals_participation.medical_record_number.should == "1234"
        end
      end

      describe "Receiving empty hospitalization data" do

        before(:each) do
          @existing_hospital_hash = {
            "existing_hospital_attributes" => {}
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should delete existing hospital participation and hospitalization dates" do
          lambda {@event.update_attributes(@existing_hospital_hash)}.should change {HospitalsParticipation.count + Participation.count}.by(-2)
        end

      end

    end

    describe "Handling diagnosing facilities" do

      describe "Receiving a new diagnosing facility" do

        before(:each) do
          new_diagnostic_hash = {
            "new_diagnostic_attributes" => 
              [
              {"secondary_entity_id" => places(:AVH).id}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_diagnostic_hash))
        end

        it "should create a new participation linked to the event" do
          lambda {@event.save}.should change {Participation.count}.by(2)
          @event.participations.find_by_role_id(codes(:participant_diagnosing_health_facility).id).should_not be_nil
        end

      end

      describe "Receiving an edited diagnosing facility" do
        before(:each) do
          @existing_diagnostic_hash = {
            "existing_diagnostic_attributes" => { "#{participations(:marks_diagnosed_at).id}" => {"secondary_entity_id" => "#{entities(:BRVH).id}"} }
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should update the existing diagnosing facility" do
          lambda {@event.update_attributes(@existing_diagnostic_hash)}.should_not change {Participation.count}
          @event.diagnosing_health_facilities.first.secondary_entity.current_place.name.should == "Bear River Valley Hospital"
        end
      end

      describe "Receiving empty diagnostic data" do

        before(:each) do
          @existing_diagnostic_hash = {
            "existing_diagnostic_attributes" => {}
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should delete existing diagnosing facility participation" do
          lambda {@event.update_attributes(@existing_diagnostic_hash)}.should change {Participation.count}.by(-1)
        end

      end

    end  

    describe "Handling new contacts" do

      describe "Receiving one new contact" do
        fixtures :entities, :participations, :people, :entities_locations, :locations, :telephones

        before(:each) do
          new_contact_hash = {
            "new_contact_attributes" => 
              [
              { :last_name => "Allen", :first_name => "Steve", :entity_location_type_id => external_codes(:location_home).id, :phone_number => "1234567"}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_contact_hash))
        end

        it "should create a new participation linked to the event" do
          lambda {@event.save}.should change {Participation.count}.by(2)
          @event.participations.find_by_role_id(codes(:participant_contact).id).should_not be_nil
        end

        it "should add a new contact" do
          lambda {@event.save}.should change {Person.count}.by(2)
          @event.contacts.first.secondary_entity.person_temp.last_name.should == "Allen"
          @event.contacts.first.secondary_entity.person_temp.first_name.should == "Steve"
        end

        it "should add a new phone number" do
          lambda {@event.save}.should change {EntitiesLocation.count + Location.count + Telephone.count}.by(3)
          @event.contacts.first.secondary_entity.telephone_entities_location.entity_location_type_id.should == external_codes(:location_home).id
          @event.contacts.first.secondary_entity.telephone.phone_number.should == "1234567"
        end

      end

      describe "Receiving multiple new contacts" do
        fixtures :entities, :participations, :people, :entities_locations, :locations, :telephones

        before(:each) do
          new_contact_hash = {
            "new_contact_attributes" => 
              [
              { :last_name => "Allen", :first_name => "Steve", :entity_location_type_id => external_codes(:location_home).id, :phone_number => "2345678"},
              { :last_name => "Burns", :first_name => "George"}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_contact_hash))
        end

        it "should create a new participation linked to the event" do
          lambda {@event.save}.should change {Participation.count}.by(3)
          @event.participations.find_by_role_id(codes(:participant_contact).id).should_not be_nil
        end

        it "should add two new contacts" do
          lambda {@event.save}.should change {Person.count}.by(3)
        end

        it "should add one new phone number" do
          lambda {@event.save}.should change {EntitiesLocation.count + Location.count + Telephone.count}.by(3)
        end

      end

      describe "Receiving a contact with a first name but no last name" do

        before(:each) do
          new_contact_hash = {
            "new_contact_attributes" => 
              [
              { :last_name => "", :first_name => "Steve"}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_contact_hash))
        end

        it "should be invalid" do
          @event.should_not be_valid
          @event.contacts.first.secondary_entity.person_temp.should have(1).error_on(:last_name)
        end
      end

      describe "Receiving one edited contact with new phone number, when event has two contacts" do
        fixtures :events, :participations, :entities, :people, :entities_locations, :locations, :telephones, :addresses
        before(:each) do
          @existing_contact_hash = {
            "existing_contact_attributes" => { "#{entities(:Groucho).id}" => {:last_name  => "Marx", :first_name  => "Chico", :contact_phone_id => "", :entity_location_type_id => external_codes(:location_home).id, :phone_number => "2345678"} }
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should update one contact and destroy the other" do
          first_names = @event.contacts.collect { |contact| contact.secondary_entity.person_temp.first_name }
          first_names.length.should == 2
          first_names.include?("Groucho").should be_true
          first_names.include?("Phil").should be_true
          lambda {@event.update_attributes(@existing_contact_hash)}.should change {Participation.count}.by(-1)
          first_names = @event.contacts.collect { |contact| contact.secondary_entity.person_temp.first_name }
          first_names.length.should == 1
          first_names.include?("Chico").should be_true
        end

        it "should add a new phone number" do
          lambda {@event.update_attributes(@existing_contact_hash)}.should change {EntitiesLocation.count + Location.count + Telephone.count}.by(3)
          @event.contacts.first.secondary_entity.telephone_entities_location.entity_location_type_id.should == external_codes(:location_home).id
          @event.contacts.first.secondary_entity.telephone.phone_number.should == "2345678"
        end
      end

      describe "Receiving two edited contacts, one with an existing phone number" do
        fixtures :events, :participations, :entities, :people, :entities_locations, :locations, :telephones, :addresses
        before(:each) do
          @existing_contact_hash = {
            "existing_contact_attributes" => {
              "#{people(:groucho_marx).id}" => {:last_name  => "Marx", :first_name  => "Chico", :contact_phone_id => "", :entity_location_type_id => external_codes(:location_home).id, :phone_number => "2345678"},
              "#{people(:phil_silvers_cur).id}" => {:last_name  => "Silvers", :first_name  => "Jack", :contact_phone_id => entities_locations(:silvers_joined_to_home_phone).id, :entity_location_type_id => external_codes(:location_home).id, :phone_number => "3456789"}
            }
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should update the existing contact" do
          first_names = @event.contacts.collect { |contact| contact.secondary_entity.person_temp.first_name }
          first_names.length.should == 2
          first_names.include?("Phil").should be_true
          first_names.include?("Groucho").should be_true

          lambda {@event.update_attributes(@existing_contact_hash)}.should_not change {Participation.count}

          first_names = @event.contacts.collect { |contact| contact.secondary_entity.person_temp.first_name }
          first_names.length.should == 2
          first_names.include?("Chico").should be_true
          first_names.include?("Jack").should be_true

          phone_numbers = []
          @event.contacts.each do |contact| 
            contact.secondary_entity.telephone_entities_locations.each do |t_el|
              phone_numbers << t_el.location.telephones.last.phone_number
            end
          end

          phone_numbers.length.should == 3
          phone_numbers.include?("2345678").should be_true
          phone_numbers.include?("3456789").should be_true
          phone_numbers.include?("5559999").should be_true
        end
      end
     
      describe "Receiving empty contact data" do

        before(:each) do
          @existing_contact_hash = {
            "existing_contact_attributes" => {}
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should delete existing contacts" do
          lambda {@event.update_attributes(@existing_contact_hash)}.should change {Participation.count}.by(-2)
        end

      end

    end

    describe "Place Exposures" do

      before(:each) do
        @event = MorbidityEvent.new(@event_hash)
      end
    
      describe "A new Morbidity event" do
        it "should have an empty list of exposures" do
          @event.place_exposures.should be_empty
        end
      end

      describe "Receiving a place exposure w/ no name" do
        before(:each) do
          new_place_exposure_hash = {
            "new_place_exposure_attributes" => 
              [
              {'name' => '', 'place_type_id' => codes(:place_type_other).id, 'date_of_exposure' => Time.now.strftime('%B %d, %Y')}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_place_exposure_hash))
        end

        it "should return invalid" do
          @event.should_not be_valid
          @event.place_exposures.first.secondary_entity.place_temp.should have(1).error_on(:name)
        end
      end

      describe "Receiving a new place exposure" do
        before(:each) do
          @date = 'August 10, 2008'
          new_place_exposure_hash = {
            "new_place_exposure_attributes" => 
              [
              {'name' => 'Davis Natatorium', 'place_type_id' => codes(:place_type_other).id, 'date_of_exposure' => @date}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_place_exposure_hash))
        end

        it "should create a new participation linked to the event" do
          lambda {@event.save!}.should change {Participation.count}.by(2)
          @event.participations.find_by_role_id(codes(:participant_place_exposure).id).should_not be_nil
        end

        it "should create a new place" do
          lambda {@event.save}.should change {Place.count}.by(1)
          @event.place_exposures.first.secondary_entity.place_temp.name.should == 'Davis Natatorium'
          place = @event.place_exposures.first.secondary_entity.place_temp
          place.place_type.code_description.should == 'Other'
          place.date_of_exposure.should == Date.parse(@date)
        end    
            
      end

      describe "Receiving multiple new place exposures" do
        before(:each) do
          place_exposures_hash = {
            'new_place_exposure_attributes' => 
              [
              {'name' => 'Davis Natatorium', 'place_type_id' => codes(:place_type_other).id},
              {'name' => 'Sonic', 'place_type_id' => codes(:place_type_other).id}
            ]
          }
          @event = MorbidityEvent.new(@event_hash.merge(place_exposures_hash))
        end

        it "should create new participations linked to event" do
          lambda {@event.save}.should change {Participation.count}.by(3)
          @event.participations.find_by_role_id(codes(:participant_place_exposure).id).should_not be_nil
        end

        it "should add two new places" do
          lambda {@event.save}.should change {Place.count}.by(2)
        end
      end

      describe 'Receiving an edited place exposure' do
        before(:each) do
          @date = 'August 8, 2008'
          @existing_place_exposure_hash = {
            "existing_place_exposure_attributes" => {"#{places(:Davis_Nat).id}" => {"name" => "Davis Hot Springs", 'place_type_id' => codes(:place_type_other).id, 'date_of_exposure' => @date}}
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it 'should update the existing place exposure' do
          @event.place_exposures.first.secondary_entity.place_temp.name.should == "Davis Natatorium"
          lambda {@event.update_attributes(@existing_place_exposure_hash)}.should_not change {Participation.count}
          place = @event.place_exposures.first.secondary_entity.place_temp
          place.name.should == "Davis Hot Springs"
          place.date_of_exposure.should == Date.parse(@date)
        end
      end

      describe 'Receiving an empty place exposure hash' do
        before(:each) do
          @existing_place_exposure_hash = {
            "existing_place_exposure_attributes" => {}
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it 'should remove existing place exposures' do
          lambda {@event.update_attributes(@existing_place_exposure_hash)}.should change {Participation.count}.by(-1)
        end
      end

    end

    describe "Simple sanity check on reporter / reporting agency." do
      describe "Receiving a new reporter/agency " do
        before(:each) do
          @date = 'August 10, 2008'
          new_reporter_hash = {
            "active_reporting_agency" => {:name => 'Agency 1', :last_name => "Starr", :first_name => "Brenda"}
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_reporter_hash))
        end

        it "should create a new reporter and reporting agency linked to the event" do
          lambda {@event.save!}.should change {Participation.count}.by(3)
          @event.participations.find_by_role_id(codes(:participant_reported_by).id).should_not be_nil
          @event.participations.find_by_role_id(codes(:participant_reporting_agency).id).should_not be_nil
        end

        it "should create a new place" do
          lambda {@event.save}.should change {Place.count}.by(1)
          @event.reporting_agency.secondary_entity.place_temp.name.should == 'Agency 1'
        end    

        it "should create a new person" do
          lambda {@event.save}.should change {Person.count}.by(2)
          @event.reporter.secondary_entity.person_temp.last_name.should == 'Starr'
        end    
      end
    end

    describe "Handling telephone numbers" do
      fixtures :events, :participations, :entities, :people, :entities_locations, :locations, :telephones, :addresses
    
      describe "Adding new telephone number" do
        before(:each) do
          @new_telephone_hash = { 
            :new_telephone_attributes =>  [ 
              { :entity_location_type_id => ExternalCode.telephone_location_type_ids[0].to_s, :area_code => '123', :phone_number => '4567890' } 
            ] 
          }
        end

        def create_event(event_hash)
          h = @new_telephone_hash 
          yield h if block_given?
          @event_hash["active_patient"][:new_telephone_attributes] = h[:new_telephone_attributes]
          @event = MorbidityEvent.new(@event_hash)
        end

        it "should be able to add a new phone number " do           
          create_event(@event_hash)
          lambda {@event.save}.should change {EntitiesLocation.count}.by(1)      
          el = @event.patient.primary_entity.telephone_entities_locations[0]
          el.entity_location_type.code_description == 'Unknown'
          @event.should be_valid
          el.location.telephones.last.should_not be_nil
          el.location.telephones.last.phone_number.should == '4567890'
        end      

        it "should not save invalid phone numbers" do
          create_event(@event_hash) { |h| h[:new_telephone_attributes][0][:area_code] = '32' }
          @event.should_not be_valid
        end
        
        it "should allow adding multiple new phone numbers" do
          create_event(@event_hash) do |h|
            h[:new_telephone_attributes] << { 
              :area_code => '330', 
              :phone_number => '322-1234', 
              :email_address => 'joe@bagadonuts.com', 
              :entity_location_type_id => ExternalCode.telephone_location_type_ids[1] }
            
          end
          lambda {@event.save}.should change {EntitiesLocation.count}.by(2)      
          el = @event.patient.primary_entity.telephone_entities_locations[1]
          @event.should be_valid
          el.entity_location_type.code_description == 'Home'
          el.area_code.should == '330'
          el.phone_number.should == '3221234'
          el.email_address.should == 'joe@bagadonuts.com'
          el.current_phone.simple_format.should == '(330) 322-1234'
        end

        it "should allow adding phone numbers when editing cmrs" do
          h = { :active_patient => @new_telephone_hash.merge(:existing_telephone_attributes => {}) }
          event = events(:marks_cmr)
          event.patient.should_not be_nil
          event.patient.primary_entity.should_not be_nil
          #        event.patient.primary_entity.entities_locations.size.should > 0
          event.update_attributes(h)
          event.should be_valid
        end

        it "should not add the phone number if no telephone attributes are specified" do
          create_event(@event_hash) do |h|
            h[:new_telephone_attributes] = 
              [ { :entity_location_type_id => ExternalCode.telephone_location_type_ids[0].to_s } ]
          end
          lambda {@event.save}.should_not change {EntitiesLocation.count}.by(1)      
          @event.patient.primary_entity.telephone_entities_locations.should be_empty
          @event.should be_valid
        end

        it "should add the phone number, even if an entity location type isn't selected" do
          create_event(@event_hash) do |h|
            h[:new_telephone_attributes] << {
              :area_code => '330',
              :phone_number => '432-1254',
              :email_address => 'happy@joy.com'}
          end
          lambda{@event.save}.should change{EntitiesLocation.count}.by(2)
          el = @event.patient.primary_entity.telephone_entities_locations[1]
          @event.should be_valid
          el.entity_location_type.should be_nil
          el.area_code.should == '330'
          el.phone_number.should == '4321254'
          el.email_address.should == 'happy@joy.com'        
        end

      end

    end

    describe "Handling notes" do
      fixtures :notes, :users

      describe "Receiving a new note" do

        before(:each) do
          @user = users(:default_user)
          User.stub!(:current_user).and_return(@user)
          new_note_hash = {
            "new_note_attributes" => {"note" => "This is a note"}
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_note_hash))
        end

        it "should create a new note linked to the event" do
          lambda {@event.save}.should change {Note.count}.by(1)
          @event.notes.first.note.should == "This is a note"
        end
      end

      describe "Receiving an empty note" do

        before(:each) do
          @user = users(:default_user)
          User.stub!(:current_user).and_return(@user)
          new_note_hash = {
            "new_note_attributes" => {}
          }
          @event = MorbidityEvent.new(@event_hash.merge(new_note_hash))
        end

        it "should do nothing" do
          lambda {@event.save}.should change {Note.count}.by(0)
        end
      end

      describe "Receiving two existing notes, one struck through one not." do
        fixtures :notes, :users, :events

        before(:each) do
          @user = users(:default_user)
          User.stub!(:current_user).and_return(@user)
          @existing_note_hash = {
            "existing_note_attributes"=>{ "#{notes(:marks_note_1).id}" => {:struckthrough => "0"}, 
              "#{notes(:marks_note_2).id}" => {:struckthrough => "1"} }
          }
          @event = MorbidityEvent.find(events(:marks_cmr).id)
        end

        it "should not change note 1 and should change note 2 to struckthrough" do
          notes(:marks_note_1).struckthrough.should be_false
          notes(:marks_note_2).struckthrough.should be_false
          lambda {@event.update_attributes(@existing_note_hash)}.should change {Note.count}.by(0)
          strikethroughs = @event.notes.collect { |note| note.struckthrough? }
          strikethroughs.include?(true).should be_true
          strikethroughs.include?(false).should be_true
        end
      end
    end
  end

  describe "Routing an event" do

    before(:each) do
      @event = MorbidityEvent.find(events(:marks_cmr).id)
    end

    describe "with legitimate parameters" do
      it "should not raise an exception" do
        lambda { @event.route_to_jurisdiction(entities(:Davis_County)) }.should_not raise_error()
      end

      it "should change the jurisdiction" do
        @event.active_jurisdiction.secondary_entity.current_place.name.should == places(:Southeastern_District).name
        @event.route_to_jurisdiction(entities(:Davis_County).id)
        @event.active_jurisdiction.secondary_entity.current_place.name.should == places(:Davis_County).name
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

    describe "with secondary jurisdicitonal assignment" do

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

    it "should not be under investigation in the default state" do
      event = MorbidityEvent.new
      event.should_not be_under_investigation
    end

    it "should not be under investigation if it is new" do
      event = MorbidityEvent.new(:event_status => "NEW")
      event.should_not be_under_investigation
    end


    it "should be under investigation if set to under investigation" do
      event = MorbidityEvent.new :event_status => "UI"
      event.should be_under_investigation
    end

    it "should be under investigation if reopened by manager" do
      event = MorbidityEvent.new :event_status => "RO-MGR"
      event.should be_under_investigation
    end

    it "should be under investigation if investigation is complete" do
      event = MorbidityEvent.new :event_status => "IC"
      event.should be_under_investigation
    end
  end

  describe "Saving an event" do
    it "should generate an event onset date set to today" do
      event = MorbidityEvent.new(@event_hash)
      event.save.should be_true
      event.event_onset_date.should == Date.today
    end
  end


  describe "The get_required_priv() class method" do
    it "should return :accept_event_for_lhd when the state is ACPTD-LHD or RJCT-LHD" do
      Event.get_required_privilege("ACPTD-LHD").should == :accept_event_for_lhd
      Event.get_required_privilege("RJCTD-LHD").should == :accept_event_for_lhd
    end
  end

  describe "The get_transition_states() class method" do
    it "should return ['ASGD-LHD', 'IC'] when the state is RO-MGR" do                   
      Event.get_transition_states("RO-MGR").should == ["ASGD-LHD", "IC"]
    end
  end

  describe "The get_action_phrases() class method" do
    it "should return an array of structs containing the right phrases and states" do
      s = Event.get_action_phrases(['RO-STATE', 'APP-LHD'])
      s.first.phrase.should == "Reopen"
      s.first.state.should == "RO-STATE"
      s.last.phrase.should == "Approve"
      s.last.state.should == "APP-LHD"
    end
  end

  describe "The legal_state_transition? instance method" do

    before(:each) do
      @event = Event.new
    end

    it "should return true when transitioning from ACPTD-LHD to ASGD-INV" do
      @event.event_status = "ACPTD-LHD"
      @event.legal_state_transition?("ASGD-INV").should be_true
    end

    it "should return false when transitioning from ACPTD-LHD to UI" do
      @event.event_status = "ACPTD-LHD"
      @event.legal_state_transition?("UI").should be_false
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
        "active_patient" => {
          "person" => {
            "last_name"=>"Biel",
            "birth_date" => Date.today.years_ago(14)
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
        "active_patient" => {
          "person" => {
            "last_name"=>"Biel",
            "birth_date" => Date.today.years_ago(14)
          }
        }
      }
    end

    it 'should not generate an age at onset if the birthdate is unknown' do
      @event_hash['active_patient']['person']['birth_date'] = nil
      with_event do |event|
        event.age_info.should_not be_nil
        event.age_info.age_type.code_description.should == 'unknown'
        event.age_info.age_at_onset.should be_nil
      end
    end
        

    it 'should generate an age at onset if the birthday is known' do
      with_event do |event|
        event.active_patient.primary_entity.person_temp.birth_date.should_not be_nil
        event.event_onset_date.should_not be_nil
        event.age_info.age_at_onset.should == 14
        event.age_info.age_type.code_description.should == 'years'
      end
    end

    describe 'generating age at onset from earliest encounter date' do

      it 'should use the date the disease was diagnosed' do
        date_diagnosed = Date.today.years_ago(3)
        @event_hash['disease'] = {'date_diagnosed' => date_diagnosed }
        with_event do |event|
          event.age_info.age_at_onset.should == 11
          event.age_info.age_type.code_description.should == 'years'
        end
      end

      it 'sould use the lab collection date' do
        @event_hash['new_lab_attributes'] = [{'name' => 'Quest', 'lab_result_text' => 'pos', 'collection_date' => Date.today.years_ago(1)}]
        with_event do |event|
          event.labs.count.should == 1
          event.age_info.age_at_onset.should == 13
        end
      end

      it 'should use the earliest lab collection date' do
        @event_hash['new_lab_attributes'] = [
          {'name' => 'Quest', 'lab_result_text' => 'pos', 'collection_date' => Date.today.years_ago(1)},
          {'name' => 'Merck', 'lab_result_text' => 'neg', 'collection_date' => Date.today.months_ago(18)}]
        with_event do |event|
          event.labs.count.should == 2
          event.age_info.age_at_onset.should == 12
        end
      end

      it 'should use the lab test date' do
        @event_hash['new_lab_attributes'] = [{'name' => 'Quest', 'lab_result_text' => 'pos', 'lab_test_date' => Date.today.years_ago(1)}]
        with_event do |event|
          event.labs.count.should == 1
          event.age_info.age_at_onset.should == 13
        end
      end

      it 'should use the earliet lab test date' do
        @event_hash['new_lab_attributes'] = [
          {'name' => 'Quest', 'lab_result_text' => 'pos', 'lab_test_date' => Date.today.years_ago(1)},
          {'name' => 'Merck', 'lab_result_text' => 'neg', 'lab_test_date' => Date.today.months_ago(18)}]
        with_event do |event|
          event.labs.count.should == 2
          event.age_info.age_at_onset.should == 12
        end
      end

      it 'should use the earliet of all lab dates' do
        @event_hash['new_lab_attributes'] = [
          {'name' => 'Quest', 'lab_result_text' => 'pos', 'lab_test_date' => Date.today.years_ago(1), 'collection_date' => Date.today.years_ago(1)},
          {'name' => 'Merck', 'lab_result_text' => 'neg', 'lab_test_date' => Date.today.months_ago(18), 'collection_date' => Date.today.years_ago(3)}]
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
      @event_hash = {
        "active_patient" => {
          "person" => {
            "last_name"=>"Biel"
          }
        }
      }
    end

    it 'should return true for a new record, not yet sent to cdc or ibis' do
      with_event do |event|
        event.should_not be_a_new_record
        event.should be_a_cdc_update
        event.should be_a_ibis_update
        event.should_not be_sent_to_cdc
        event.should_not be_sent_to_ibis
      end
    end

    it 'should need cdc and ibis update when first_reported_PH_date value changes' do
      with_event do |event|
        event.cdc_update = false
        event.first_reported_PH_date = Date.today
        event.save.should be_true
        event.should be_a_cdc_update
        event.should be_a_ibis_update
      end
    end
    
    it 'should need cdc update when udoh case status id changes' do
      with_event do |event|
        event.udoh_case_status = ExternalCode.find(:first, :conditions => "code_name = 'case'")
        event.save.should be_true
        event.should be_a_cdc_update
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
        MorbidityEvent.create( { "active_patient" => { "person" => { "last_name"=>"Ibis1", } },
                                 "event_name"     => "Ibis1"
                             } )
        # NON_IBIS: Not sent to IBIS, has disease, not confirmed
        MorbidityEvent.create( { "active_patient" => { "person" => { "last_name"=>"Ibis2", } }, 
                                 "disease"        => { "disease_id" => anthrax.id },
                                 "event_name"     => "Ibis2"
                             } )
        # NEW: Not sent to IBIS, has disease, confirmed
        MorbidityEvent.create( { "active_patient"      => { "person" => { "last_name"=>"Ibis3", } },
                                 "disease"             => { "disease_id" => anthrax.id },
                                 "udoh_case_status_id" => confirmed.id,
                                 "event_name"          => "Ibis3" 
                              } )
        # UPDATED: Sent to IBIS, has disease, confirmed
        MorbidityEvent.create( { "active_patient"      => { "person" => { "last_name"=>"Ibis4", } }, 
                                 "disease"             => { "disease_id" => anthrax.id },
                                 "udoh_case_status_id" => confirmed.id,
                                 "sent_to_ibis"        => true,
                                 "ibis_update"         => true,
                                 "event_name"          => "Ibis4"
                             } )
        # DELETED: Sent to IBIS, has disease, not confirmed
        MorbidityEvent.create( { "active_patient"      => { "person" => { "last_name"=>"Ibis4", } }, 
                                 "disease"             => { "disease_id" => anthrax.id },
                                 "udoh_case_status_id" => discarded.id,
                                 "sent_to_ibis"        => true,
                                 "ibis_update"         => true,
                                 "event_name"          => "Ibis5"
                             } )
      end

      it "should find new records" do
        events = Event.new_ibis_records
        events.size.should == 2   # 1 above and 1 in the fixtures
        events.collect! { |event| Event.find(event.event_id) }
        event_names = events.collect { |event| event.event_name }
        event_names.include?("Marks Chicken Pox").should be_true
        event_names.include?("Ibis3").should be_true
      end

      it "should find updated records" do
        events = Event.updated_ibis_records
        events.collect! { |event| Event.find(event.event_id) }
        events.size.should == 1
        events.first.event_name.should ==  "Ibis4"
      end

      it "should find deleted records" do
        events = Event.deleted_ibis_records
        events.collect! { |event| Event.find(event.event_id) }
        events.size.should == 1
        events.first.event_name.should ==  "Ibis5"
      end

      it "should find all IBIS exportable records" do
        events = Event.exportable_ibis_records
        events.collect! { |event| Event.find(event.event_id) }
        events.size.should == 4   # 3 above and 1 in the fixtures
        event_names = events.collect { |event| event.event_name }
        event_names.include?("Marks Chicken Pox").should be_true
        event_names.include?("Ibis3").should be_true
        event_names.include?("Ibis4").should be_true
        event_names.include?("Ibis5").should be_true
      end
    end
  end

  describe 'when executing a view-filtering search' do

    fixtures :users, :role_memberships, :roles, :entities, :privileges, :privileges_roles, :entitlements, :diseases, :disease_events

    before :each do
      
      jurisdiction_id = role_memberships(:default_user_admin_role_southeastern_district).jurisdiction_id
      
      @user = users(:default_user)
      @user.stub!(:jurisdiction_ids_for_privilege).and_return([jurisdiction_id])
      User.stub!(:current_user).and_return(@user)
      MorbidityEvent.stub!(:get_allowed_queues).and_return([[1], ["Speedy-BearRiver"]])
      
      @event_hash = {
        "active_patient" => {
          "person" => {
            "last_name"=>"Biel",
            "birth_date" => Date.today.years_ago(14)
          }
        },
        "active_jurisdiction" => {
          "secondary_entity_id" => jurisdiction_id
        },
        "event_status" => 'NEW'
      }
    end

    # The following specs add a couple more events in addition to what is in the fixtures. If the results are off,
    # take a look at the events bootstrapped here, and what is set up in the fixtures, paying attention too, to
    # the jurisdiction_id, which is included in the search criteria.
    
    it 'should filter by disease and the other attributes' do
      @event_hash['disease'] = {'disease_id' => 1 }
      MorbidityEvent.create(@event_hash)

      @event_hash['event_queue_id'] = 1
      MorbidityEvent.create(@event_hash)
      
      @event_hash['event_status'] = 'CLOSED'
      MorbidityEvent.create(@event_hash)

      MorbidityEvent.find_all_for_filtered_view.size.should == 5
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1]}).size.should == 4
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :queues => [1], :states => ['NEW']}).size.should == 1
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :queues => [1], :states => ['CLOSED']}).size.should == 1
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['CLOSED']}).size.should == 1
    end
    
    it 'should filter by state and the other attributes' do
      @event_hash['event_status'] = 'CLOSED'
      MorbidityEvent.create(@event_hash)
      
      @event_hash['disease'] = {'disease_id' => 1 }
      MorbidityEvent.create(@event_hash)

      @event_hash['event_queue_id'] = 1
      MorbidityEvent.create(@event_hash)
      
      MorbidityEvent.find_all_for_filtered_view.size.should == 5
      MorbidityEvent.find_all_for_filtered_view({:states => ['CLOSED']}).size.should == 3
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['CLOSED']}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:diseases => [1], :states => ['CLOSED'], :queues => [1]}).size.should == 1
    end
    
    it 'should filter by queue and the other attributes' do
      @event_hash['event_queue_id'] = 1
      MorbidityEvent.create(@event_hash)
      
      @event_hash['event_status'] = 'CLOSED'
      MorbidityEvent.create(@event_hash)
      
      @event_hash['disease'] = {'disease_id' => 1 }
      MorbidityEvent.create(@event_hash)
      
      MorbidityEvent.find_all_for_filtered_view.size.should == 5
      MorbidityEvent.find_all_for_filtered_view({:queues => [1]}).size.should == 3
      MorbidityEvent.find_all_for_filtered_view({:queues => [1], :states => ['CLOSED']}).size.should == 2
      MorbidityEvent.find_all_for_filtered_view({:queues => [1], :states => ['CLOSED'], :diseases => [1]}).size.should == 1
    end

    it 'should set the query string on the user if the view change is to be the default' do
      @event_hash['event_queue_id'] = 1
      MorbidityEvent.create(@event_hash)
            
      MorbidityEvent.find_all_for_filtered_view.size.should == 3
      @user.should_receive(:update_attribute)
      MorbidityEvent.find_all_for_filtered_view({:queues => [1], :set_as_default_view => "1"})
    end

  end

  describe 'form builder cdc export fields' do
    fixtures :diseases, :export_conversion_values

    before(:each) do      
      @question = Question.create(:data_type => 'radio_buttons', :question_text => 'Contact?' )
      @event = MorbidityEvent.create( { "active_patient" => { "person" => { "last_name"=>"CdcExportHep", } }, 
                               "disease"        => { "disease_id" => diseases(:hep_a).id },
                               "event_name"     => "CdcExportHepA",
                               "new_radio_buttons" => { @question.id.to_s => {:radio_button_answer => ['Yes'], :export_conversion_value_id => export_conversion_values(:jaundiced_unknown).id } }
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
                            
  end                       

  describe 'new event from patient' do
    fixtures :users
    
    def with_new_event_from_patient(patient)
      event = MorbidityEvent.new_event_from_patient(patient)
      yield event if block_given?
    end

    before(:each) do
      @patient = participations(:Patient_Without_Disease)
      User.stub!(:current_user).and_return(users(:default_user))
    end
      
    it 'should use the existing patient in the event tree' do
      with_new_event_from_patient(@patient.primary_entity) do |event|
        event.patient.primary_entity_id.should_not be_nil        
        lambda {event.save!}.should_not change(Entity, :count)
        event.active_patient.primary_entity.person.last_name.should == 'Labguy'
        event.active_patient.primary_entity.id.should == participations(:Patient_Without_Disease).primary_entity.id
        event.all_jurisdictions.size.should == 1
        event.jurisdiction.secondary_entity.place_temp.name.should == 'Unassigned'
        event.primary_jurisdiction.should_not be_nil
        event.primary_jurisdiction.entity_id.should_not be_nil
        event.primary_jurisdiction.name.should == 'Unassigned'
      end
         
    end 

  end
        

end
