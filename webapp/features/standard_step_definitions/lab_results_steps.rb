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

# A dirty, filthy hack because succ! seems to be broken in JRuby on 64
# bit Java
String.class_eval do
  def loinc_succ
    (self.gsub('-', '').to_i + 1).to_s.insert(-2, '-')
  end
end


Given /^the following disease to common test types mapping exists$/ do |disease_test_maps|
  code = '10000-0'
  disease_test_maps.rows.each do |disease_test_map|
    d = Disease.find_or_create_by_disease_name(:disease_name => disease_test_map.first, :active => true)
    c = CommonTestType.find_or_create_by_common_name(disease_test_map.last)
    l = LoincCode.create! :loinc_code => code = code.loinc_succ, :scale => ExternalCode.loinc_scales.first, :common_test_type => c
    d.loinc_codes << l
  end
end

Given /^the lab result references the common test type$/ do
  @lab_result.test_type = @common_test_type
  @lab_result.save!
end

Then /^all common test types should be available for selection$/ do
  response.should have_tag("form[class *= '_event']") do |form|
    form.should have_tag("select[id *= 'test_type_id']") do |select|
      CommonTestType.all.each do |test_type|
        select.should have_option(:text => test_type.common_name)
      end
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
  fill_in "morbidity_event[labs_attributes][0][place_entity_attributes][place_attributes][name]", :with => lab_name
end

Given /^I select a test type of '(.+)'$/ do |test_type|
  @lab_values << test_type
  select test_type, :from => "morbidity_event[labs_attributes][0][lab_results_attributes][0][test_type_id]"
end

Given /^I select an organism of '(.+)'$/ do |organism|
  @lab_values << organism
  select organism, :from => "morbidity_event[labs_attributes][0][lab_results_attributes][0][organism_id]"
end

Given /^I select a test result of '([^\"]*)'$/ do |test_result|
  @lab_values << test_result
  select test_result, :from => "morbidity_event[labs_attributes][0][lab_results_attributes][0][test_result_id]"
end

Given /^I enter a result value of (.+)$/ do |result|
  @lab_values << result
  fill_in "morbidity_event[labs_attributes][0][lab_results_attributes][0][result_value]", :with => result
end

Given /^I enter a units of (.+)$/ do |unit|
  @lab_values << unit
  fill_in "morbidity_event[labs_attributes][0][lab_results_attributes][0][units]", :with => unit
end

Given /^I enter a reference range of (.+)$/ do |range|
  @lab_values << range
  fill_in "morbidity_event[labs_attributes][0][lab_results_attributes][0][reference_range]", :with => range
end

Given /^I enter a test status of (.+)$/ do |test_status|
  @lab_values << test_status
  select test_status, :from => "morbidity_event[labs_attributes][0][lab_results_attributes][0][test_status_id]"
end

Given /^I select a specimen source of '([^\"]*)'$/ do |specimen|
  @lab_values << specimen
  select specimen, :from => "morbidity_event[labs_attributes][0][lab_results_attributes][0][specimen_source_id]"
end

Given /^I select a sent to state lab value of '([^\"]*)'$/ do |state|
  @lab_values << state
  select state, :from => "morbidity_event[labs_attributes][0][lab_results_attributes][0][specimen_sent_to_state_id]"
end

Given /^I enter a comment of "([^\"]*)"$/ do |comment|
  @lab_values << comment
  fill_in "morbidity_event[labs_attributes][0][lab_results_attributes][0][comment]", :with => comment
end

When /^I save the new morbidity event form$/ do
  submit_form "new_morbidity_event"
end

When /^I save the new assessment event form$/ do
  submit_form "new_assessment_event"
end

When /^I save the edit event form$/ do
  submit_form "edit_#{@event.type.underscore}_#{@event.id}"
end

Then /^I should see the values entered above$/ do
  response.should have_xpath("//div[@id='labs']") do |labs|
    @lab_values.each { |value| labs.should contain(value) }
  end
end
