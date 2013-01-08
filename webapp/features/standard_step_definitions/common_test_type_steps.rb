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

Given /^the following common test types are in the system$/ do |test_types|
  test_types.raw.each do |common_name|
    CommonTestType.create(:common_name => common_name.first)
  end
end

Given /^loinc code "([^\"]*)" is associated with the common test type$/ do |loinc_code|
  loinc_code = LoincCode.find_by_loinc_code(loinc_code)
  @common_test_type.update_loinc_code_ids :add => [loinc_code.id]
end

Given /^common test type "([^\"]*)"$/ do |test_name|
  CommonTestType.create! :common_name => test_name
end

When /^I try to delete the common test type$/ do
  delete common_test_type_path(@common_test_type)
end

When /^the lab result is associated with the common test type$/ do
  @lab_result.test_type = @common_test_type
  @lab_result.save!
end

Then /^the search results should not have "([^\"]*)"$/ do |text|
  response.should_not have_xpath("//div[@class = 'search-results']//span[contains(text(), '#{text}')]")
end

Then /^the search results should have "([^\"]*)"$/ do |text|
  response.should have_xpath("//div[@class = 'search-results']//span[contains(text(),'#{text}')]")
end

Then /^the search results should show that "([^\"]*)" is already associated$/ do |common_name|
  response.should have_xpath("//div[@class = 'search-results']//span[@class='associated-common-test']//a[contains(text(),'#{common_name}')]")
end

Then /^I should not see "([^\"]*)" associated with the test type$/ do |test_name|
  response.should_not have_xpath("//div[@id='associated-loincs']//span[@class='test_name' and contains(text(),'#{test_name}')]")
end

Given /^common test type "([^\"]*)" is linked to the following diseases:$/ do |test_name, table|
  ctt = CommonTestType.find_by_common_name test_name
  table.map_headers! 'Disease name' => :disease_name
  table.hashes.each do |attr|
    ctt.diseases << Disease.first(:conditions => attr)
  end
  ctt.save!
end
