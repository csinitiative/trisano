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

Then /^I should see all of the core view config questions$/ do
  html_source = @browser.get_html_source
  eval(@form.event_type.camelcase).core_views.each do |core_view|
    assert_tab_contains_question(@browser, core_view[0], "#{core_view[0]} question?", html_source).should be_true
  end
end

When /^I answer all core view config questions$/ do
  html_source = @browser.get_html_source
  eval(@form.event_type.camelcase).core_views.each do |core_view|
    answer_investigator_question(@browser, "#{core_view[0]} question", "#{core_view[0]} answer", html_source).should be_true
  end
end

Then /^I should see all core view config answers$/ do
  html_source = @browser.get_html_source
  eval(@form.event_type.camelcase).core_views.each do |core_view|
    raise "Could not find the answer for #{core_view[0]}" if html_source.include?("#{core_view[0]} answer") == false
  end
end
