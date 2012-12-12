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

Given /^a lab test type named "(.+)"$/ do |lab_test_type|
  CommonTestType.find_or_create_by_common_name(lab_test_type)
end

When /^I enter a second lab:$/ do |table|
  table.hashes.each do |attributes|
    add_lab_result(@browser, attributes, 2)
  end
end

When /^I enter the following lab results for the "(.+)" lab:$/ do |lab_name, table|
  i = 0
  table.hashes.each do |attributes|
    attributes.merge!(:lab_name => lab_name)
    i += 1
    add_lab_result(@browser, attributes, 1, i)
  end
end


Then /^I should see all of the repeater core field config questions for (.+) labs$/ do |expected_count|
  @core_fields ||= CoreField.all(:conditions => ["event_type = ? AND fb_accessible = ? AND disease_specific = ? AND repeater = TRUE AND key LIKE '%[lab_results]%'", @form.event_type, true, false])
  @core_fields.count.should_not be_equal(0), "Didn't find any lab core fields."

  @core_fields.each do |core_field|
    before_config_count = @browser.get_xpath_count("//label[contains(text(), '#{core_field.key} before?')]")
    (before_config_count==expected_count).should(be_true, "Expected '#{core_field.key} before?' label to appear #{expected_count} times. Got #{before_config_count}.")
    after_config_count = @browser.get_xpath_count("//label[contains(text(), '#{core_field.key} after?')]")
    (after_config_count==expected_count).should(be_true, "Expected '#{core_field.key} after?' label to appear #{expected_count} times. Got #{after_config_count}.")
  end
end


Given /^a (.+) event with with a form with repeating core fields and labs$/ do |event_type|
  Given "a #{event_type} event with with a form with repeating core fields"
  And "a lab named \"Labby\""
  And "a lab test type named \"TriCorder\""
  And   "I navigate to the #{event_type} event edit page"
  add_lab_result(@browser, {:lab_name => "Labby", :test_type => "TriCorder"})
  And   "I save and exit"
end
