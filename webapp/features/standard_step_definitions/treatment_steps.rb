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

When /^I click merge for "([^\"]*)"$/ do |treatment_name|
  treatment = Treatment.find_by_treatment_name(treatment_name)
  click_link("merge_#{treatment.id}")
end

When /^I select the merge check box for the treatment "([^\"]*)"$/ do |treatment_name|
  treatment = Treatment.find_by_treatment_name(treatment_name)
  check("to_merge_#{treatment.id}")
end

Then /^I should see "([^\"]*)" in the treatment merge section$/ do |treatment_name|
  response.should have_xpath("//div[@id='merge_treatment']//div[contains(text(), '#{treatment_name}')]")
end

Then /^I should see "([^\"]*)" in the treatment search results section$/ do |treatment_name|
  response.should have_xpath("//div[@id='treatment_list']//a[contains(text(), '#{treatment_name}')]")
end

Then /^I should not see "([^\"]*)" in the treatment search results section$/ do |treatment_name|
  response.should_not have_xpath("//div[@id='treatment_list']//a[contains(text(), '#{treatment_name}')]")
end

Then /^I search treatments for "([^\"]*)"$/ do |search_string|
  fill_in "Treatment", :with => search_string
  click_button "Search"
end

Then /^I choose the association check box for the treatment "([^\"]*)"$/ do |treatment_name|
  treatment = Treatment.find_by_treatment_name(treatment_name)
  check("treatment_#{treatment.id}")
end

Given /^the following treatments are assocaited with the disease "([^\"]*)":$/ do |disease_name, table|
  @disease = Disease.find_by_disease_name(disease_name)
  table.hashes.each do |conditions|
    treatment = Treatment.first(:conditions => conditions)
    @disease.treatments << treatment
  end
end

Then /^I should see "([^\"]*)" in the associated treatments section$/ do |treatment_name|
  response.should have_tag('#associated_treatments a', treatment_name)
end

Then /^I should not see "([^\"]*)" in the associated treatments section$/ do |treatment_name|
  response.should_not have_tag('#associated_treatments a', treatment_name)
end

