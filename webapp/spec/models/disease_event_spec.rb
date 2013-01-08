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

describe DiseaseEvent do

  before do
    @event = Factory.build :morbidity_event
    @event.attributes = {
      :disease_event_attributes => {
        :date_diagnosed => Date.yesterday
      }
    }
    @de = @event.disease_event
  end

  it "should not be associated w/ more then one event" do
    @event = Factory :morbidity_event_with_disease
    @disease_event = DiseaseEvent.new :event => @event
    @disease_event.should_not be_valid
  end

  describe "onset date" do
    it "is a valid date format" do
      @de.disease_onset_date = 'not a date string'
      @de.should_not be_valid
      @de.errors.on(:disease_onset_date).should_not be_nil
    end
  end

  describe "date diagnosed" do
    it "is valid if it is after the onset date" do
      @de.attributes = { :disease_onset_date => Date.yesterday, :date_diagnosed => Date.today }
      @de.should be_valid
      @de.errors.on(:date_diagnosed).should be_nil
    end

    it "is invalid if it is before the onset date" do
      @de.attributes = { :disease_onset_date => Date.today, :date_diagnosed => Date.yesterday }
      @de.should_not be_valid
      @de.errors.on(:date_diagnosed).should == "must be on or after " + Date.today.to_s
    end

    it "is valid if if occurs in the past" do
      @event.disease_event.should be_valid
    end

    it "is not valid if it occurs in the future" do
      @de.update_attributes(:date_diagnosed => Date.tomorrow)
      @de.errors.on(:date_diagnosed).should == "must be on or before " + Date.today.to_s
    end
  end

end
