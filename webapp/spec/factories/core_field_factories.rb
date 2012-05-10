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

Factory.define :core_field do |cf|
  cf.field_type 'single_line_text'
end

Factory.define :cmr_core_field, :parent => :core_field do |cf|
  cf.event_type :morbidity_event
  cf.sequence(:key){|n| "morbidity_event[parent_guardian][#{n}]" }
end

Factory.define :core_fields_disease do |o|
  o.disease { Factory.create(:disease) }
  o.core_field { Factory.create(:core_field) }
end

Factory.define :cmr_core_fields_disease, :parent => :core_fields_disease do |cf|
  cf.core_field { Factory.create(:cmr_core_field) }
end

Factory.define :cmr_section_core_field, :parent => :cmr_core_field do |cf|
  cf.sequence(:key){|n| "morbidity_event[interested_party][person_entity][name_section][#{n}]" }
  cf.tree_id { CoreField.next_tree_id }
  cf.field_type 'section'
end

Factory.define :cmr_tab_core_field, :parent => :cmr_core_field do |cf|
  cf.sequence(:key){|n| "morbidity_event[demographic_tab][#{n}]" }
  cf.tree_id { CoreField.next_tree_id }
  cf.field_type 'tab'
end

Factory.define :cmr_section_core_fields_disease, :parent => :cmr_core_fields_disease do |cfd|
  cfd.core_field { Factory.create(:cmr_section_core_field) }
end

