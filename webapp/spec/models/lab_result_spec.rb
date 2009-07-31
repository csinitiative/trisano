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

  it "should not be valid with only test type" do
    @lab_result.should_not be_valid
  end

  it "should be valid with test type and an interpretation" do
    @lab_result.interpretation_id = 1
    @lab_result.should be_valid
  end

  it "should be valid with test type and lab result text" do
    @lab_result.lab_result_text = "Sick"
    @lab_result.should be_valid
  end

  it "should be valid with test type and both interpretation and lab result text" do
    @lab_result.interpretation_id = 1
    @lab_result.lab_result_text = "Sick"
  end

  it "should not be valid if test date precedes collection date" do
    @lab_result.lab_result_text = "Sick"
    @lab_result.collection_date = Date.parse("06/16/08")
    @lab_result.lab_test_date = Date.parse("06/15/08")
    @lab_result.should_not be_valid
  end
end
