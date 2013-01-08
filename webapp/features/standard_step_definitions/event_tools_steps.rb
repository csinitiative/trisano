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

Then /^I should see the full set of tools in the right place$/ do
  response.should have_xpath("//div[@id='title_area']//a[contains(text(), 'Show')]")
  response.should have_xpath("//div[@id='title_area']//a[contains(text(), 'Print')]")
  response.should have_xpath("//div[@id='title_area']//a[contains(text(), 'Delete')]")
  response.should have_xpath("//div[@id='title_area']//a[contains(text(), 'Add Task')]")
  response.should have_xpath("//div[@id='title_area']//a[contains(text(), 'Add Attachment')]")
  response.should have_xpath("//div[@id='title_area']//a[contains(text(), 'Export to CSV')]")
  response.should have_xpath("//div[@id='title_area']//a[contains(text(), 'Create a new event from this one')]")
  response.should have_xpath("//div[@id='title_area']//a[contains(text(), 'Events')]")
  response.should have_xpath("//div[@id='title_area']//a[contains(text(), 'Route to Local Health Depts.')]")
end
