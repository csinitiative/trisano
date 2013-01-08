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
Given /^disease "([^\"]*)" exists$/ do |name|
  @disease = Factory.create(:disease, :disease_name => name)
end

Given /^the disease "([^\"]*)" with the cdc code "([^\"]*)"$/ do |disease_name, cdc_code|
  @disease = Disease.find_or_create_by_disease_name(:disease_name => disease_name, :cdc_code => cdc_code, :active => true)
end

Given /^the disease "([^\"]*)" exports to CDC when state is "([^\"]*)"$/ do |disease_name, case_description|
  disease = Disease.find_by_disease_name disease_name
  disease.cdc_disease_export_statuses << ExternalCode.case.find_by_code_description(case_description)
end

Given /^I have an active disease named "([^\"]*)"$/ do |disease_name|
  @disease = Factory.create(:disease, :disease_name => disease_name, :active => true)
end

Given /^the following active diseases:$/ do |table|
  table.map_headers! 'Disease name' => :disease_name
  table.hashes.each do |attr|
    Disease.create! attr.merge(:active => true)
  end
end

Given /^the disease "([^\"]*)" is exported when "([^\"]*)"$/ do |disease_name, status|
  disease = Disease.find_by_disease_name disease_name
  disease.cdc_disease_export_statuses << ExternalCode.case.find_by_code_description(status)
  disease.save!
end

Given /^the following organisms are associated with the disease "([^\"]*)":$/ do |disease_name, table|
  base_loinc = '1000-0'
  scale = ExternalCode.loinc_scales.find_by_the_code('Ord')
  disease = Disease.find_or_create_by_disease_name disease_name

  table.map_headers! 'Organism name' => :organism_name
  table.hashes.each do |attr|
    organism = Organism.create! attr
    loinc = LoincCode.create! :loinc_code => base_loinc = base_loinc.loinc_succ, :scale => scale, :organism => organism
    disease.loinc_codes << loinc
  end

  disease.save!
end

Given /^the following loinc codes are associated with the disease "([^\"]*)":$/ do |disease_name, table|
  disease = Disease.find_or_create_by_disease_name disease_name
  table.map_headers! 'Loinc code' => :loinc_code, 'Scale' => :scale
  table.hashes.each do |hash|
    attr = hash.dup
    attr[:scale] = ExternalCode.loinc_scales.find_by_the_code attr[:scale]
    loinc = LoincCode.find_or_create_by_loinc_code attr
    disease.loinc_codes << loinc
  end
  disease.save!
end

Given /^a morbidity event exists with a deactivated disease$/ do
  @deactivated_disease = Factory.create(:disease, :active => false)
  @event = create_basic_event("morbidity", get_unique_name(1), @deactivated_disease.disease_name)
end

