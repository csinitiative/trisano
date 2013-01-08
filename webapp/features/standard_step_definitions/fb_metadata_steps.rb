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

When(/^I navigate to the form detail view$/) do
  visit form_path(@form)
  response.should contain("Detail View")
end

Then(/^I should be able to see how many elements there are on the master copy$/) do
  visit form_path(@form)
  response.should contain("6 elements")
end

Then(/^I should be able to see how many questions there are on the master copy$/) do
  visit form_path(@form)
  response.should contain("1 question")
end

Then(/^I should be able to see how many elements there are on the published version$/) do
  visit form_path(@form)
  response.should contain("5 elements")
end

Then(/^I should be able to see how many questions there are on the published version$/) do
  visit form_path(@form)
  response.should contain("0 question")
end
