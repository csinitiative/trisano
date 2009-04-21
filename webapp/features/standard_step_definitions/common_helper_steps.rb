# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

#
# Log in helpers
#

Given(/^I am logged in as a super user$/) do
  log_in_as("default_user")
end

Given(/^I am logged in as a lhd manager$/) do
  log_in_as("lhd_manager")
end

When(/^I click the "(.+)" link$/) do |link|
  click_link link
end

When(/^I click the "(.+)" button$/) do |button|
  click_button button
end
