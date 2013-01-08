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

Given /^the loinc code has test name "(.*)"$/ do |test_name|
  @loinc_code.update_attributes! :test_name => test_name
end

Given /^I have (\d+) sequential loinc codes, starting at (.*)$/ do |count, start_with|
  @scale = CodeName.loinc_scale.external_codes.find_by_code_description('Ordinal')
  (1..count.to_i).inject(start_with) do |current_code, index|
    LoincCode.create!(:loinc_code => current_code, :scale_id => @scale.id)
    current_code.next
  end
end

Given /^I have the following LOINC codes in the system:$/ do |table|
  @scale = CodeName.loinc_scale.external_codes.find_by_code_description('Ordinal')
  table.rows.each do |record|
    LoincCode.create!(:loinc_code => record.first, :test_name => record.last, :scale_id => @scale.id)
  end
end

Given /^LOINC code "([^\"]*)"$/ do |code|
  LoincCode.create! :loinc_code => code, :scale => ExternalCode.loinc_scale_by_the_code('Ord')
end

Given /^disease "([^\"]*)" is associated with LOINC code "([^\"]*)"$/ do |disease_name, loinc_code|
  loinc = LoincCode.find_by_loinc_code loinc_code
  loinc.diseases << Disease.find_by_disease_name(disease_name)
  loinc.save!
end

Then /^the "(.*)" value from Scale should be selected$/ do |value|
  response.should have_xpath("//select[@id='loinc_code_scale_id']//option[@selected='selected' and text()='#{value}']")
end
