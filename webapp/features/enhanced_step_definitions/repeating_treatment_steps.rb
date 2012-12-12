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

Given /^a treatment named "(.+)"$/ do |treatment_name|
  treatment = Treatment.find_or_create_by_treatment_name(treatment_name)
  Disease.all.each { |disease| disease.treatments << treatment unless disease.treatments.include?(treatment) }
end

When /^I enter a second treatment:$/ do |table|
  table.hashes.each do |attributes|
    add_treatment(@browser, attributes, 2)
  end
end

When /^I enter the following treatments:$/ do |table|
  i = 0
  table.hashes.each do |attributes|
    i += 1
    add_treatment(@browser, attributes, i)
  end
end

Given /^a (.+) event with with a form with repeating core fields and treatments$/ do |event_type|
  Given "a #{event_type} event with with a form with repeating core fields"
  And "a treatment named \"leeching\""
  And   "I navigate to the #{event_type} event edit page"
  add_treatment(@browser, {:treatment_name => "leeching"})
  And   "I save and exit"
end
