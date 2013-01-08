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

require 'factory_girl'
require 'faker'

Factory.define :lab do |l|
  l.secondary_entity { Factory(:lab_place_entity) }
  l.lab_results { |lr| [lr.association(:lab_result)] }
end

Factory.define :lab_place_entity, :class => :place_entity do |lpe|
  lpe.place { Factory.build(:lab_place) }
end

Factory.define :lab_place, :class => :place do |lp|
  lp.place_types { [lab_place_type] }
  lp.name { Factory.next(:place_name) }
end

Factory.define :lab_result do |lr|
  lr.test_type { |ctt| ctt.association(:common_test_type) }
end

Factory.define(:common_test_type) do |ctt|
  ctt.common_name { Factory.next(:common_name) }
end

#
# Sequences
#

Factory.sequence(:common_name) do |n|
  "common_name_#{n}"
end

def lab_place_type
  Code.find_or_create_by_the_code_and_code_name({
                                                  :the_code => 'L',
                                                  :code_name => 'placetype',
                                                  :code_description => 'Laboratory'
                                                })
end

