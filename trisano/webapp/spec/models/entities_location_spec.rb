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

describe EntitiesLocation do
  before(:each) do
    @entity_location = EntitiesLocation.new
  end

  it "should be valid" do
    @entity_location.should be_valid
  end

  describe "with fixtures loaded" do
    fixtures :entities_locations

    it "should have three records" do
      EntitiesLocation.should have(3).records
    end

    it "A Phil Silvers record should point to Phil Silvers" do
      entities_locations(:silvers_joined_to_home_address).entity_id.should eql(2)
    end

    it "A home join location should point to home location" do
      entities_locations(:silvers_joined_to_home_address).location_id.should eql(1)
    end

  end
end
