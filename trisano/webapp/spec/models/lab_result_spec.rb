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

describe LabResult do
  before(:each) do
    @lab_result = LabResult.new
    @lab_result.lab_result_text = "Positive"
  end

  it "should not be valid when empty" do
    @lab_result.lab_result_text = nil
    @lab_result.should_not be_valid
  end

  it "should be valid with only result text" do
    @lab_result.should be_valid
  end

  it "should be valid with just a collection date" do
    @lab_result.collection_date = Date.parse("06/15/08")
    @lab_result.should be_valid
  end

  it "should be valid with just a lab test date" do
    @lab_result.lab_test_date = Date.parse("06/15/08")
    @lab_result.should be_valid
  end

  it "should be valid with both a collection date and lab test date" do
    @lab_result.collection_date = Date.parse("06/15/08")
    @lab_result.lab_test_date = Date.parse("06/16/08")
    @lab_result.should be_valid
  end

  it "should not be valid if test date precedes collection date" do
    @lab_result.collection_date = Date.parse("06/16/08")
    @lab_result.lab_test_date = Date.parse("06/15/08")
    @lab_result.should_not be_valid
  end
end
