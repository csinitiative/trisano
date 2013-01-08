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
# -*- coding: utf-8 -*-
Then /^I should see the following tasks:$/ do |expected_tasks|
  columns = lambda do |e|
    [
     e.css('th:nth-child(1) a', 'td:nth-child(1)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(2) a', 'td:nth-child(2)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(3) a', 'td:nth-child(3)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(4) a', 'td:nth-child(4)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(5) a', 'td:nth-child(5)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(6) a', 'td:nth-child(6)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(7) a', 'option[selected]').text.gsub("\302\240", ' ').strip
    ]
  end
  html = tableish("#task-list tr", columns)
  # need a better way to check for today
  html[1][0] = 'Today' if Date.parse(html[1][0]) == Date.today
  expected_tasks.diff! html
end

Then /^I should not see any tasks$/ do
  response.should_not have_xpath("//table[@id='task-list']")
end

Then /^I should not see a blank Status option$/ do
  response.should_not have_xpath("//select[@id='task_status']/option[text()='']")
end

Then /^I should see a Status option labeled "([^\"]*)"$/ do |label|
  response.should have_xpath("//select[@id='task_status']/option[text()='#{label}']")
end
