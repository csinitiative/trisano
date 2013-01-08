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

describe LabResult do
  fixtures :common_test_types

  before(:each) do
    @lab_result = LabResult.new
    @lab_result.test_type = common_test_types(:blood_test)
  end

  it "should not be valid when empty" do
    @lab_result.test_type = nil
    @lab_result.should_not be_valid
  end

  it "should be valid with only test type" do
    @lab_result.should be_valid
  end
  
  it "should be valid if test date precedes collection date" do
    params = {:collection_date => Date.yesterday,
              :lab_test_date => Date.today}

    @lab_result.update_attributes(params)
    @lab_result.should be_valid
    @lab_result.errors.on(:lab_test_date).should be_nil
  end

  it "should not be valid if test date precedes collection date" do
    params = {:collection_date => Date.today,
              :lab_test_date => Date.yesterday}

    @lab_result.update_attributes(params)
    @lab_result.errors.on(:lab_test_date).should == "must be on or after " + Date.today.to_s
  end
  
  it "should be valid for collection dates in the past" do
    @lab_result.update_attributes(:collection_date => Date.yesterday)
    @lab_result.should be_valid
    @lab_result.errors.on(:collection_date).should be_nil
  end

  it "should not allow collection dates in the future" do
    @lab_result.update_attributes(:collection_date => Date.tomorrow)
    @lab_result.errors.on(:collection_date).should == "must be on or before " + Date.today.to_s
  end
  
  it "should be valid for lab test dates in the past" do
    @lab_result.update_attributes(:lab_test_date => Date.yesterday)
    @lab_result.should be_valid
    @lab_result.errors.on(:lab_test_date).should be_nil
  end
  
  it "should not allow lab test dates in the future" do
    @lab_result.update_attributes(:lab_test_date => Date.tomorrow)
    @lab_result.errors.on(:lab_test_date).should == "must be on or before " + Date.today.to_s
  end
end
