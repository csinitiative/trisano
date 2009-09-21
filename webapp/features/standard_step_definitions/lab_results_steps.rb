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


Given /^the following disease to common test types mapping exists$/ do |disease_test_maps|
  disease_test_maps.rows.each do |disease_test_map|
    d = Disease.find_by_disease_name(disease_test_map.first)
    d.common_test_types << CommonTestType.find_or_create_by_common_name(disease_test_map.last)
  end
end

Given /^the following organisms exist$/ do |organisms|
  organisms.raw.each do |organism|
    Organism.create(:organism_name => organism.first)
  end
end


Given /^I have a lab result$/ do
  @lab_result = Factory.create(:lab_result)
end

Given /^the lab result references the common test type$/ do
  @lab_result.test_type = @common_test_type
  @lab_result.save!
end

Then /^all common test types should be available for selection$/ do
  response.should have_xpath("//form[contains(@class, '_event')]//select[contains(@id, 'test_type_id')]") do |options|
    CommonTestType.all.each do |test_type|
      options.should contain(test_type.common_name)
    end
  end
end

Then /^the following common test types should be available for selection$/ do |common_names|
  response.should have_xpath("//form[contains(@class, '_event')]//select[contains(@id, 'test_type_id')]") do |options|
    common_names.raw.each do |common_name|
      options.should contain(common_name.first)
    end
  end
end

Then /^the following common test types should not be available for selection$/ do |common_names|
  response.should have_xpath("//form[contains(@class, '_event')]//select[contains(@id, 'test_type_id')]") do |options|
    common_names.raw.each do |common_name|
      options.should_not contain(common_name.first)
    end
  end
end

# Cheating
Given /^I click on the lab tab$/ do
  @lab_values = []
end

Given /^I enter a lab name of '([^\"]*)'$/ do |lab_name|
  @lab_values << lab_name
  fill_in "morbidity_event[labs_attributes][3][place_entity_attributes][place_attributes][name]", :with => lab_name
end

Given /^I select a test type of '(.+)'$/ do |test_type|
  @lab_values << test_type
  select test_type, :from => "morbidity_event[labs_attributes][3][lab_results_attributes][0][test_type_id]"
end

Given /^I select an organism of '(.+)'$/ do |organism|
  @lab_values << organism
  select organism, :from => "morbidity_event[labs_attributes][3][lab_results_attributes][0][organism_id]"
end

Given /^I select a test result of '([^\"]*)'$/ do |test_result|
  @lab_values << test_result
  select test_result, :from => "morbidity_event[labs_attributes][3][lab_results_attributes][0][test_result_id]"
end

Given /^I enter a result value of (.+)$/ do |result|
  @lab_values << result
  fill_in "morbidity_event[labs_attributes][3][lab_results_attributes][0][result_value]", :with => result
end

Given /^I enter a units of (.+)$/ do |unit|
  @lab_values << unit
  fill_in "morbidity_event[labs_attributes][3][lab_results_attributes][0][units]", :with => unit
end

Given /^I enter a reference range of (.+)$/ do |range|
  @lab_values << range
  fill_in "morbidity_event[labs_attributes][3][lab_results_attributes][0][reference_range]", :with => range
end

Given /^I enter a test status of (.+)$/ do |test_status|
  @lab_values << test_status
  select test_status, :from => "morbidity_event[labs_attributes][3][lab_results_attributes][0][test_status_id]"
end

Given /^I select a specimen source of '([^\"]*)'$/ do |specimen|
  @lab_values << specimen
  select specimen, :from => "morbidity_event[labs_attributes][3][lab_results_attributes][0][specimen_source_id]"
end

Given /^I select a sent to state lab value of '([^\"]*)'$/ do |state|
  @lab_values << state
  select state, :from => "morbidity_event[labs_attributes][3][lab_results_attributes][0][specimen_sent_to_state_id]"
end

Given /^I enter a comment of "([^\"]*)"$/ do |comment|
  @lab_values << comment
  fill_in "morbidity_event[labs_attributes][3][lab_results_attributes][0][comment]", :with => comment
end

When /^I save the new event form$/ do
  submit_form "new_morbidity_event"
end

Then /^I should see the values entered above$/ do
  response.should have_xpath("//div[@id='labs']") do |labs|
    @lab_values.each { |value| labs.should contain(value) }
  end
end
