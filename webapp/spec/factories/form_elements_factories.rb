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

Factory.define :question_element do |qe|
  qe.question { |q| q.association(:question_single_line_text) }
end

Factory.define :core_field_element do |cfe|
  cfe.core_path { Factory.next(:core_path) }
  cfe.name      { Factory.next(:core_field_element_name) }
end

Factory.define(:follow_up_element) do |fue|
  fue.condition { "Yes" }
end

Factory.define :form_element do |fe|
end

Factory.define :value_element do |ve|
  ve.name { Factory.next(:value_element_name) }
  ve.code { Factory.next(:value_element_code) }
end

Factory.define :value_set_element do |vse|
  vse.name { Factory.next(:value_set_name) }
end

Factory.define :core_view_element do |cve|
  cve.name { Factory.new(:core_view_element_name) }
end

Factory.define(:group_element) do |ge|
  ge.name { Factory.next(:group_element_name) }
end

Factory.define(:view_element) do |ve|
  ve.name { Factory.next(:view_element) }
end

Factory.define(:before_core_field_element) do |b|
end

Factory.define(:after_core_field_element) do |a|
end

# sequnces

Factory.sequence :core_field_element_name do |n|
  "#{Faker::Lorem.words(3)} #{n}"
end

Factory.sequence :value_set_name do |n|
  "#{Faker::Lorem.words(3)} #{n}"
end

Factory.sequence :core_path do |n|
  "morbidity_event[test_path#{n}]"
end

Factory.sequence(:group_element_name) do |n|
  "group_element_#{n}"
end

Factory.sequence(:value_element_name) do |n|
  "value_element_name_#{n}"
end

Factory.sequence(:value_element_code) do |n|
  "#{n}"
end

Factory.sequence(:core_view_element_name) do |n|
  "core_view_element_#{n}"
end

Factory.sequence(:view_element) do |n|
  "view_element_#{n}"
end
