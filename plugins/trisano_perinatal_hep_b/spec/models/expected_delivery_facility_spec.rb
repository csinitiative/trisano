# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

require File.expand_path(File.dirname(__FILE__) +  '/../../../../../spec/spec_helper')

describe ExpectedDeliveryFacility do

  it "should have an expected_delivery_facilities_participation association" do
    expected_delivery_facility = ExpectedDeliveryFacility.new
    expected_delivery_facility.expected_delivery_facilities_participation = ExpectedDeliveryFacilitiesParticipation.new
    expected_delivery_facility.expected_delivery_facilities_participation.should_not be_nil
  end

end
