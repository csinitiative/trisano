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

describe PlaceEntity do

  fixtures :places, :places_types

  def with_event(event_hash=@event_hash)
    event = MorbidityEvent.new(event_hash)
    event.save!
    event.reload
    yield event if block_given?
  end
  
  before(:each) do
    User.current_user = nil 
    @place_entity = PlaceEntity.new
  end

  describe "finding exising places" do
    fixtures :codes, :places, :places_types, :entities

    before(:each) do
      @event_hash = {
        "interested_party_attributes" => {
          "person_entity_attributes" => {
            "person_attributes" => {
              "last_name"=>"Placer"
            }
          }
        },
        "hospitalization_facilities_attributes" => {
          "0"=>{
            "secondary_entity_id"=> places(:Davis_Nat).entity.id,
            "hospitals_participation_attributes"=>{
              "admission_date"=>"", "discharge_date"=>"", "medical_record_number"=>""
            }
          }
        },
        "diagnostic_facilities_attributes"=>{
          "2"=>{
            "place_entity_attributes"=>{
              "place_attributes"=>{
                "name"=>"Diagnostic Facility"
              }
            }
          }
        },
        "labs_attributes"=>{
          "3"=>{
            "place_entity_attributes"=>{
              "place_attributes"=>{
                "name"=>"Labby Lab"
              }
            },
            "lab_results_attributes"=>{
              "0"=>{
                "test_type"=>"Culture", "test_detail"=>"Did it", "lab_result_text"=>"Done", "reference_range"=>"", "interpretation_id"=>"",
                "specimen_source_id"=>"", "collection_date"=>"", "lab_test_date"=>"", "specimen_sent_to_uphl_yn_id"=>""
              }
            }
          }
        },
        "place_child_events_attributes"=>{
          "5"=>{
            "interested_place_attributes"=>{
              "place_entity_attributes"=>{
                "place_attributes"=>{
                  "name"=>"FallMart"
                }
              }
            },
            "participations_place_attributes"=>{
              "date_of_exposure"=>""
            }
          }
        },
        "reporting_agency_attributes"=>{
          "place_entity_attributes"=>{
            "place_attributes"=>{
              "name"=>"Reporters Inc."
            },
            "telephones_attributes"=>{
              "0"=>{
                "area_code"=>"", "phone_number"=>"", "extension"=>""
              }
            }
          }
        }
      }
    end

    it "should find places that have been utilized as hospitalization facilities if a matching name is used" do
      PlaceEntity.all_by_name_and_participation_type({:name => "Davis", :participation_type => "HospitalizationFacility"}).size.should == 0

      with_event(@event_hash) do |event|
        PlaceEntity.all_by_name_and_participation_type({:name => "Davis", :participation_type => "HospitalizationFacility"}).size.should == 1
      end
    end

    it "should not find places that have been utilized as hospitalization facilities if a matching name is not used" do
      PlaceEntity.all_by_name_and_participation_type({:name => "xxx", :participation_type => "HospitalizationFacility"}).size.should == 0

      with_event(@event_hash) do
        PlaceEntity.all_by_name_and_participation_type({:name => "xxx", :participation_type => "HospitalizationFacility"}).size.should == 0
      end
    end

    it "should find places that have been utilized as diagnostic facilities if a matching name is used" do
      PlaceEntity.all_by_name_and_participation_type({:name => "Diagnostic Facility", :participation_type => "DiagnosticFacility"}).size.should == 0

      with_event(@event_hash) do
        PlaceEntity.all_by_name_and_participation_type({:name => "Diagnostic Facility", :participation_type => "DiagnosticFacility"}).size.should == 1
      end
    end

    it "should not find places that have been utilized as diagnostic facilities if a matching name is not used" do
      PlaceEntity.all_by_name_and_participation_type({:name => "xxx", :participation_type => "DiagnosticFacility"}).size.should == 0

      with_event(@event_hash) do
        PlaceEntity.all_by_name_and_participation_type({:name => "xxx", :participation_type => "DiagnosticFacility"}).size.should == 0
      end
    end

    it "should find places that have been utilized as labs if a matching name is used" do
      PlaceEntity.all_by_name_and_participation_type({:name => "Labby Lab", :participation_type => "Lab"}).size.should == 0

      with_event(@event_hash) do
        PlaceEntity.all_by_name_and_participation_type({:name => "Labby Lab", :participation_type => "Lab"}).size.should == 1
      end
    end

    it "should not find places that have been utilized as labs if a matching name is not used" do
      PlaceEntity.all_by_name_and_participation_type({:name => "xxx", :participation_type => "Lab"}).size.should == 0

      with_event(@event_hash) do
        PlaceEntity.all_by_name_and_participation_type({:name => "xxx", :participation_type => "Lab"}).size.should == 0
      end
    end

    it "should find places that have been utilized as place exposures if a matching name is used" do
      PlaceEntity.all_by_name_and_participation_type({:name => "FallMart", :participation_type => "InterestedPlace"}).size.should == 0

      with_event(@event_hash) do
        PlaceEntity.all_by_name_and_participation_type({:name => "FallMart", :participation_type => "InterestedPlace"}).size.should == 1
      end
    end

    it "should not find places that have been utilized as place exposures if a matching name is not used" do
      PlaceEntity.all_by_name_and_participation_type({:name => "xxx", :participation_type => "InterestedPlace"}).size.should == 0

      with_event(@event_hash) do
        PlaceEntity.all_by_name_and_participation_type({:name => "xxx", :participation_type => "InterestedPlace"}).size.should == 0
      end
    end

    it "should find places that have been utilized as labs if a matching name is used" do
      PlaceEntity.all_by_name_and_participation_type({:name => "Reporters Inc.", :participation_type => "ReportingAgency"}).size.should == 0

      with_event(@event_hash) do
        PlaceEntity.all_by_name_and_participation_type({:name => "Reporters Inc.", :participation_type => "ReportingAgency"}).size.should == 1
      end
    end

    it "should not find places that have been utilized as labs if a matching name is not used" do
      PlaceEntity.all_by_name_and_participation_type({:name => "xxx", :participation_type => "ReportingAgency"}).size.should == 0

      with_event(@event_hash) do
        PlaceEntity.all_by_name_and_participation_type({:name => "xxx", :participation_type => "ReportingAgency"}).size.should == 0
      end
    end

  end

end

