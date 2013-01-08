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
Given /^an organism named "([^\"]*)"$/ do |name|
  Organism.create! :organism_name => name
end

Given /^the following organisms:$/ do |table|
  table.map_headers! 'Organism Name' => :organism_name
  table.hashes.each do |attributes|
    Organism.create! attributes
  end
end

After('@clean_organisms') do
  Organism.all.each(&:delete)
end

