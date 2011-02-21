# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

describe Place, "in the Perinatal Hep B plugin" do

  it "should return expected delivery facility place types" do
    Place.expected_delivery_type_codes.size.should == 3
    ["H", "C", "O"].each do |place_type_code|
      Place.expected_delivery_type_codes.include?(place_type_code).should be_true
    end
  end

  it "should return actual delivery facility place types" do
    Place.actual_delivery_type_codes.size.should == 3
    ["H", "C", "O"].each do |place_type_code|
      Place.actual_delivery_type_codes.include?(place_type_code).should be_true
    end
  end

  it "should return active, expected delivery facilities" do
    good = create_place_entity!('Hillcrest', 'expected_delivery')
    Place.expected_delivery_facilities.include?(good.place).should be_true
    deleted = create_place_entity!('Gonecrest', 'expected_delivery')
    deleted.update_attributes!(:deleted_at => DateTime.now)
    Place.expected_delivery_facilities.include?(deleted.place).should be_false
    wrong = create_place_entity!('Wrongcrest', 'lab')
    Place.expected_delivery_facilities.include?(wrong.place).should be_false
  end

end
