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

When /^I enter a second telephone number:$/ do |table|
  table.hashes.each do |telephone_attributes|
    add_telephone(@browser, telephone_attributes, 2)
  end
end

When /^I enter the following telephone numbers:$/ do |table|
  i = 0
  table.hashes.each do |telephone_attributes|
    i += 1
    add_telephone(@browser, telephone_attributes, i)
  end
end

Given /^a (.+) event with with a form with repeating core fields and telephones$/ do |event_type|
  And "a #{event_type} event with with a form with repeating core fields"
  And   "I navigate to the #{event_type} event edit page"
  add_telephone(@browser, {:type => "Work", "area code" => "555", :number => "555-5555"})
  And   "I save and exit"
end
