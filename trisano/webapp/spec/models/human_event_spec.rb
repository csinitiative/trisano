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

def with_human_event(event_hash=@event_hash, &block)    
  event = HumanEvent.new(event_hash)
  block.call(event) if block_given?
  event                        
end

describe HumanEvent, 'associations'  do
  it { should have_one(:interested_party) }
  it { should have_many(:labs) }
  it { should have_many(:hospitalization_facilities) }
  it { should have_many(:diagnostic_facilities) }
  it { should have_many(:clinicians) }

  describe "nested attributes are assigned" do
    it { should accept_nested_attributes_for(:interested_party) }
    it { should accept_nested_attributes_for(:labs) }
    it { should accept_nested_attributes_for(:hospitalization_facilities) }
    it { should accept_nested_attributes_for(:diagnostic_facilities) }
    it { should accept_nested_attributes_for(:clinicians) }
  
    describe "destruction is allowed properly" do
      fixtures :events

      before(:each) do
        @event = HumanEvent.new
      end

      it "Should not allow interested parties to be deleted via a nested attribute" do
        @event.build_interested_party.build_person_entity.build_person(:last_name => "whatever")
        @event.save
        @event.interested_party_attributes = { "_delete"=>"1" }
        @event.interested_party.should_not be_marked_for_destruction
      end

      it "Should allow labs to be deleted via a nested attribute" do
        @event.labs.build
        @event.save
        @event.labs_attributes = [ { "id" => "#{@event.labs[0].id}", "_delete"=>"1"} ]
        @event.labs[0].should be_marked_for_destruction
      end

      it "Should allow hospitalization facilities to be deleted via a nested attribute" do
        @event.hospitalization_facilities.build
        @event.save
        @event.hospitalization_facilities_attributes = [ { "id" => "#{@event.hospitalization_facilities[0].id}", "_delete"=>"1"} ]
        @event.hospitalization_facilities[0].should be_marked_for_destruction
      end

      it "Should allow diagnostic_facilities to be deleted via a nested attribute" do
        @event.diagnostic_facilities.build
        @event.save
        @event.diagnostic_facilities_attributes = [ { "id" => "#{@event.diagnostic_facilities[0].id}", "_delete"=>"1"} ]
        @event.diagnostic_facilities[0].should be_marked_for_destruction
      end

      it "Should allow clinicians to be deleted via a nested attribute" do
        @event.clinicians.build
        @event.save
        @event.clinicians_attributes = [ { "id" => "#{@event.clinicians[0].id}", "_delete"=>"1"} ]
        @event.clinicians[0].should be_marked_for_destruction
      end
    end

    describe "empty attributes are handled correctly" do
      fixtures :events, :entities, :places

      before(:each) do
        @event = HumanEvent.new
      end

      it "should reject hospitals with no entity ID and no settings" do
        @event.hospitalization_facilities_attributes = [ { "secondary_entity_id" => nil, "hospitals_participation_attributes" => {} } ]
        @event.hospitalization_facilities.should be_empty
      end

      it "should reject diagnostic facilities with no place" do
        @event.diagnostic_facilities_attributes = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "" } } } ]
        @event.diagnostic_facilities.should be_empty
      end

      it "should reject clinicians with no person" do
        @event.clinicians_attributes = [ { "person_entity_attributes" => { "person_attributes" => { "last_name" => "" } } } ]
        @event.clinicians.should be_empty
      end

      it "should reject labs with no lab entries" do
        @event.labs_attributes = [ { "place_entity_attributes" => { "place_attributes" => { "name" => "" } }, "lab_results_attributes" => {} } ]
        @event.labs.should be_empty
      end

      it "should reuse existing labs" do
        @event.labs_attributes = [ { "place_entity_attributes" => { "place_attributes" => { "name" => places(:Existing_Lab_One).name } }, "lab_results_attributes" => {} } ]
        @event.labs[0].secondary_entity_id.should == places(:Existing_Lab_One).entity_id
      end
    end
  end
end

describe HumanEvent, 'age at onset'  do

  before(:each) do
    @event_hash = {
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "person_attributes" => {
            "last_name"=>"Green"
          }
        },
      },
      :created_at => DateTime.now,
      :updated_at => DateTime.now
    }
  end

  it 'should not be saved if there is no birthday' do
    with_human_event do |event|
      event.send(:set_age_at_onset)
      event.age_info.age_at_onset.should be_nil
      event.age_info.age_type.code_description.should == 'unknown'
    end
  end
    
  it 'should be saved, along w/ an age type' do    
    with_human_event do |event|     
      event.safe_call_chain(:interested_party, :person_entity, :person).birth_date = 20.years.ago
      event.send(:set_age_at_onset)
      event.age_info.age_at_onset.should_not be_nil
      event.age_info.age_type.should_not be_nil
      event.errors.on(:age_at_onset).should be_nil
    end
  end

  it 'should not be valid if negative' do
    with_human_event do |event|
      event.safe_call_chain(:interested_party, :person_entity, :person).birth_date = DateTime.tomorrow
      event.send(:set_age_at_onset)
      event.save
      event.should_not be_valid
      event.errors.on(:age_at_onset).should_not be_nil
    end
  end 
end

describe HumanEvent, 'parent/guardian field' do

  it 'should exist' do
    with_human_event do |event|
      event.respond_to?(:parent_guardian).should be_true
    end
  end

  it 'should accept text longer then 50 chars' do
    with_human_event do |event|
      event.parent_guardian = 'r' * 51
      lambda{event.save!}.should_not raise_error
    end
  end

  it 'should be invalid for string longer then 255 (db limit)' do
    with_human_event do |event|
      event.parent_guardian = 'q' * 256
      event.should_not be_valid
    end
  end

  it 'should allow nil' do
    with_human_event do |event|
      event.parent_guardian = nil
      lambda{event.save!}.should_not raise_error
    end
  end

  it 'should allow blank data' do
    with_human_event do |event|
      event.parent_guardian = ''
      lambda{event.save!}.should_not raise_error
    end
  end

end

