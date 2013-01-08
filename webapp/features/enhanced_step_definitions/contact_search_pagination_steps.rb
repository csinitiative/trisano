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

When /^I do a contact search for "([^\"]*)"$/ do |contact_name|
  @browser.type("contact_search_name", contact_name)
  @browser.click("contact_search")
  @browser.wait_for_ajax
end

Then /^I should see the contact pagination navigation$/ do
  @browser.is_element_present("//div[@id='contact_search_results']/div[@class='pagination']").should be_true
end

When /^I follow the next pagination navigation link$/ do
  @browser.click("link=Next »")
  sleep 5 # Wait for Ajax wasn't doing it here
end

When /^I follow the last pagination navigation link$/ do
  page_number = @browser.get_eval("selenium.browserbot.getCurrentWindow().$$('#contact_search_results a').last().previous().innerHTML")
  @browser.click("link=#{page_number}")
  sleep 5 # Wait for Ajax wasn't doing it here
end

Then /^"([^\"]*)" should not be present in the contact search results$/ do |name|
  @browser.is_element_present("//div[@id='contact_search_results']/table/tbody/tr/td[contains(text(), '#{name}')]").should be_false
end

Then /^"([^\"]*)" should be present in the contact search results$/ do |name|
  @browser.is_element_present("//div[@id='contact_search_results']/table/tbody/tr/td[contains(text(), '#{name}')]").should be_true
end
