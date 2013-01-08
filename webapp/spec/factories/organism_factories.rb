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

Factory.define(:loinc_code) do |lc|
  lc.loinc_code "13954-3"
end

Factory.define(:organism) do |o|
  o.organism_name { Factory.next(:organism_name) }
end

Factory.define(:scale_code, :class => 'external_code') do |sc|
  sc.code_name "loinc_scale"
  sc.the_code "Ord"
  sc.code_description "Ordinal"
end

Factory.define :campylobacter_jejuni, :class => Organism do |organism|
  organism.organism_name 'Campylobacter jejuni'
end

Factory.define :shigella, :class => Organism do |organism|
  organism.organism_name 'Shigella'
end

Factory.define :bordetella_pertussis, :class => Organism do |organism|
  organism.organism_name 'Bordetella pertussis'
end

#
# Sequences
#

Factory.sequence(:organism_name) do |n|
  "organism_name_#{n}"
end

