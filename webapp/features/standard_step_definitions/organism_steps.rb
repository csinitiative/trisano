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
Then /^I should see the following organisms:$/ do |expected_table|
  selectors = lambda do |e|
    [
     e.css('th:nth-child(1)', 'td:nth-child(1)').text.strip,
     e.css('th:nth-child(2)', 'td:nth-child(2)').text.gsub("\302\240", ' ').gsub(/\W+/, ' ').strip
    ]
  end
  t = tableish('#organisms tr', selectors)
  expected_table.diff! t
end

Given /^disease "([^\"]*)" is linked to organism "([^\"]*)"$/ do |disease_name, organism_name|
  disease = Disease.find_or_create_by_disease_name :disease_name => disease_name, :active => true
  organism = Organism.find_by_organism_name organism_name
  organism.diseases << disease
  organism.save!
end
