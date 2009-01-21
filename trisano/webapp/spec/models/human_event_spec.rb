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

describe HumanEvent, 'setting the age at onset'  do

  def with_human_event(event_hash=@event_hash, &block)    
    event = HumanEvent.new(event_hash)
    block.call(event) if block_given?
    event                        
  end

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

  it 'should not store an age at onset if there is no birthday' do
    with_human_event do |event|
      event.send(:set_age_at_onset)
      event.age_info.age_at_onset.should be_nil
      event.age_info.age_type.code_description.should == 'unknown'
    end
  end
    
  it 'should store the age at onset and age type' do    
    with_human_event do |event|     
      event.safe_call_chain(:active_patient, :primary_entity, :person_temp).birth_date = 20.years.ago
      event.send(:set_age_at_onset)
      event.age_info.age_at_onset.should_not be_nil
      event.age_info.age_type.should_not be_nil
      event.errors.on(:age_at_onset).should be_nil
    end
  end

  it 'should not be valid if age at onset is negative' do
    with_human_event do |event|
      event.safe_call_chain(:active_patient, :primary_entity, :person_temp).birth_date = DateTime.tomorrow
      event.send(:set_age_at_onset)
      event.save
      event.should_not be_valid
      event.errors.on(:age_at_onset).should_not be_nil
    end
  end 
end
