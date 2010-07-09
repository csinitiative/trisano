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

require 'factory_girl'

Factory.define :expected_delivery_facility do |edf|
  edf.place_entity { create_delivery_facility!(:expected_delivery, "hospital name") }
end

Factory.define :actual_delivery_facility do |adf|
  adf.place_entity { create_delivery_facility!(:actual_delivery, "hospital name") }
  adf.actual_delivery_facilities_participation { Factory.build(:actual_delivery_facilities_participation) }
end

Factory.define :actual_delivery_facilities_participation do |adfp|
  adfp.actual_delivery_date Date.today + 15.days
end

Factory.define :health_care_provider do |hcp|
  hcp.person_entity :person_entity
  hcp.health_care_providers_participation { Factory.build(:health_care_providers_participation) }
end


Factory.define :health_care_providers_participation do |hcpp|
  # hcpp.speciality XXX
end
