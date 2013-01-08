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

require File.dirname(__FILE__) + '/../spec_helper'

describe ParticipationsTreatment do
  before(:each) do
    @pt = ParticipationsTreatment.new
  end

  it "should be valid with nothing populated" do
    @pt.should be_valid
  end
  
  it "should be valid with received y/n" do
    @pt.treatment_given_yn_id = 1401
    @pt.should be_valid
  end

  it "should validate the treatment date" do
    @pt.treatment_date = 'not a date'
    @pt.should_not be_valid
  end

  it "should validate the stop treatment date" do
    @pt.stop_treatment_date = 'not a date'
    @pt.should_not be_valid
  end

  it "should be valid for treatment dates in the past" do
    @pt.update_attributes(:treatment_date => Date.yesterday)
    @pt.should be_valid
    @pt.errors.on(:treatment_date).should be_nil
  end

  it "should not allow date of treatment in the future" do
    @pt.update_attributes(:treatment_date => Date.tomorrow)
    @pt.errors.on(:treatment_date).should == "must be on or before #{Date.today}"
  end
  
  it "should be valid for stop treatment dates in the past" do
    @pt.update_attributes(:stop_treatment_date => Date.yesterday)
    @pt.should be_valid
    @pt.errors.on(:stop_treatment_date).should be_nil
  end

  it "should not allow for a stop treatment date in the future" do
    @pt.update_attributes(:stop_treatment_date => Date.tomorrow)
    @pt.errors.on(:stop_treatment_date).should == "must be on or before #{Date.today}"
  end
  
  it "should not allow a stop treatment date prior to the treatment date" do
    @pt.update_attributes(:treatment_date => Date.today)
    @pt.update_attributes(:stop_treatment_date => Date.yesterday)
    @pt.errors.on(:stop_treatment_date).should == "must be on or after #{Date.today}"
  end
end
