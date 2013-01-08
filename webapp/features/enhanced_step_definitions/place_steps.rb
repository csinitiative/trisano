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
Given /^the following place types:$/ do |table|
  table.hashes.each do |hash|
    unless Code.placetypes.count(:conditions => { :code_description => hash['type'] }) > 0
      Factory.create(:place_type, :code_description => hash['type'])
    end
  end
end

Given /^the following places:$/ do |table|
  table.hashes.each do |hash|
    place = Place.find_by_name(hash['name'])
    unless place
      place_entity = Factory.create(:place_entity)
      place = place_entity.place
      place.update_attributes(:name => hash['name'])
    end
    type = Code.placetypes.find_by_code_description(hash['type'])
    unless place.place_types.exists?(type)
      place.place_types << type
    end
  end
end

Given /^places have these addresses:$/ do |table|
  table.hashes.each do |hash|
    place = Place.find_by_name(hash['place'])
    unless place.entity.canonical_address
      place.entity.create_canonical_address(:street_number => hash['number'], :street_name => hash['street'])
    end
  end
end
