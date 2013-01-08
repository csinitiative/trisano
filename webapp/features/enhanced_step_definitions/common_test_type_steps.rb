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
Given /^no other common test types exist$/ do
  CommonTestType.all.each { |tt| tt.destroy unless tt == @lab_result.test_type }
end

When /^I navigate to show common test type$/ do
  @browser.click("link=ADMIN")
  @browser.wait_for_page_to_load
  @browser.click("link=Manage Common Test Types")
  @browser.wait_for_page_to_load
  @browser.click("link=Show")
  @browser.wait_for_page_to_load
end

Then /^I should see a link to "([^\"]*)"$/ do |link_name|
  @browser.get_xpath_count("//a[contains(text(), '#{link_name}')]").to_i.should == 1
  @browser.visible?("//a[contains(text(), '#{link_name}')]").should be_true
end

Then /^I should not see a link to "([^\"]*)"$/ do |link_name|
  links_found = @browser.get_xpath_count("//a[contains(text(), '#{link_name}')]").to_i
  if links_found == 0
    links_found.should be_equal(0)
  else
    # this let's us ignore invisible links
    # but not check for them if they don't exist
    @browser.visible?("//a[contains(text(), '#{link_name}')]")
  end
end

After('@clean_common_test_types') do
  CommonTestType.all.each(&:delete)
end

After('@clean_lab_results') do
  LabResult.all.each(&:delete)
end
