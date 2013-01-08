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

describe HospitalsParticipation do
  before(:each) do
    @hp = HospitalsParticipation.create
  end

  it "should be valid for an admission date before an admission date" do
    @hp.update_attributes(:admission_date => Date.yesterday)
    @hp.update_attributes(:discharge_date => Date.today)
    @hp.should be_valid
    @hp.errors.on(:discharge_date).should be_nil 
  end

  it "should not allow a discharge date before an admission date" do
    @hp.update_attributes(:admission_date => Date.today)
    @hp.update_attributes(:discharge_date => Date.yesterday)
    @hp.errors.on(:discharge_date).should == "must be on or after " + Date.today.to_s
  end
  
  it "should be valid for an admission date in the past" do
    @hp.update_attributes(:admission_date => Date.yesterday)
    @hp.should be_valid
    @hp.errors.on(:admission_date).should be_nil 
  end
  
  it "should not allow an addmission date in the future" do
    @hp.update_attributes(:admission_date => Date.tomorrow)
    @hp.errors.on(:admission_date).should == "must be on or before " + Date.today.to_s
  end

  it "should be valid for a discharge date in the past" do
    @hp.update_attributes(:discharge_date => Date.yesterday)
    @hp.should be_valid
    @hp.errors.on(:discharge_date).should be_nil 
  end

  it "should not allow an discharge date in the future" do
    @hp.update_attributes(:discharge_date=> Date.tomorrow)
    @hp.errors.on(:discharge_date).should == "must be on or before " + Date.today.to_s
  end
  
end
