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

describe Location do
  before(:each) do
    @location = Location.new
  end

  it "should not be valid without a phone or address component" do
    @location.should_not be_valid
  end

  describe "with associated address" do
    before(:each) do
      @address = Address.new
    end

    it "should be invalid to have an empty address" do
      @location.addresses << @address
      @location.should_not be_valid
    end

    it "should be valid to have a filled in address" do
      @address.street_name = "Spruce St."
      @location.addresses << @address
      @location.should be_valid
    end
  end
end
