# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

require 'spec_helper'

describe ParticipationsEncounter do

  fixtures :users
  
  before(:each) do
    @pe = ParticipationsEncounter.create
  end

  it 'should be valid with a date, user, and location' do
    @pe.encounter_date = 1.day.ago
    @pe.user = users(:default_user)
    @pe.encounter_location_type = "clinic"
    @pe.should be_valid
  end
  
  it 'should not be valid without a date' do
    @pe.user = users(:default_user)
    @pe.encounter_location_type = "clinic"
    @pe.should_not be_valid
    @pe.errors.on(:encounter_date).should_not be_nil
  end

  it 'should not be valid without a user' do
    @pe.encounter_date = 1.day.ago
    @pe.encounter_location_type = "clinic"
    @pe.should_not be_valid
    @pe.errors.on(:user).should_not be_nil
  end

  it 'should not be valid without a location' do
    @pe.encounter_date = 1.day.ago
    @pe.user = users(:default_user)
    @pe.should_not be_valid
    @pe.errors.on(:encounter_location_type).should_not be_nil
  end

  it 'should not be valid with an invalid date' do
    @pe.encounter_date = "bad pie"
    @pe.user = users(:default_user)
    @pe.encounter_location_type = "clinic"
    @pe.should_not be_valid
    @pe.errors.on(:encounter_date).should == "is not a valid date"
  end

  it 'should not allow an update with an invalid location' do
    @pe.encounter_date = 1.day.ago
    @pe.user = users(:default_user)
    @pe.encounter_location_type = "bad pie"
    @pe.should_not be_valid
    @pe.errors.on(:encounter_location_type).should_not be_nil
  end

  it 'should allow updates with valid locations' do
    @pe.encounter_date = 1.day.ago
    @pe.user = users(:default_user)
    @pe.encounter_location_type = "clinic"
    @pe.save!
    ParticipationsEncounter.valid_location_types.each do |location|
      @pe.encounter_location_type = location
      @pe.save.should be_true
    end
  end

  it 'should not allow for an encounter date in the future' do
    @pe.update_attributes(:encounter_date => Date.tomorrow)
    @pe.errors.on(:encounter_date).should == "must be on or before " + Date.today.to_s
  end
end
