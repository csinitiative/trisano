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

require 'spec_helper'

describe Person, "in the Perinatal Hep B plugin" do

  it "should return Health Care Provider in the valid search types" do
    Person.valid_search_types.include?(["Health Care Provider", "HealthCareProvider"]).should be_true
  end

  it "all types returned should be names of sub-classes of Participation" do
    Person.valid_search_types.each do |type|
      obj = eval(type[1]).new
      obj.is_a?(Participation).should be_true
      obj.respond_to?(:person_entity).should be_true
      obj.respond_to?(:place_entity).should be_false
    end
  end
end
