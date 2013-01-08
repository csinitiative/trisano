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
Given /^these treatments exist:$/ do |table|
  table.hashes.each do |attr|
    unless Treatment.exists?(['treatment_name = ?', attr['treatment_name']])
      Factory.create(:treatment, attr)
    end
  end
end

Given /^the disease "([^\"]*)" has the following treatments:$/ do |disease_name, table|
  @disease = Disease.find_by_disease_name(disease_name)
  @disease.treatments.clear
  table.hashes.each do |attr|
    @disease.treatments << Treatment.find_by_treatment_name(attr['treatment_name'])
  end
end

Then /^I should see the following associated treatments:$/ do |table|
  table.hashes.each do |attr|
    treatment = Treatment.find_by_treatment_name(attr['treatment_name'])
    @browser.is_element_present(<<-CSS.strip).should be_true
      css=#associated_treatments a[href='/trisano/treatments/#{treatment.id}']
    CSS
  end
end

When /^I select treatment "([^\"]*)"$/ do |treatment_name|
  @browser.select "//div[@id='treatments']//li[@class='treatment'][last()]//select[contains(@name, 'treatment_id')]", treatment_name
end

When /^I add treatment "([^\"]*)"$/ do |treatment_name|
  @browser.click "link=Add a Treatment"
  When %{I select treatment "#{treatment_name}"}
end

When /^I remove treatment "([^\"]*)"$/ do |treatment_name|
  @browser.click "//select/option[@selected][text()='#{treatment_name}']/../../..//input[@type='checkbox'][contains(@name, '_destroy')]"
end
