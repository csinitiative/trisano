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

def with_human_event(event_hash=@event_hash, &block)    
  event = HumanEvent.new(event_hash)
  block.call(event) if block_given?
  event                        
end

describe HumanEvent, 'age at onset'  do

  before(:each) do
    @event_hash = {
      "active_patient" => {
        "person" => {
          "last_name"=>"Green"
        }
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
      event.safe_call_chain(:active_patient, :primary_entity, :person_temp).birth_date = 20.years.ago
      event.send(:set_age_at_onset)
      event.age_info.age_at_onset.should_not be_nil
      event.age_info.age_type.should_not be_nil
      event.errors.on(:age_at_onset).should be_nil
    end
  end

  it 'should not be valid if negative' do
    with_human_event do |event|
      event.safe_call_chain(:active_patient, :primary_entity, :person_temp).birth_date = DateTime.tomorrow
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

