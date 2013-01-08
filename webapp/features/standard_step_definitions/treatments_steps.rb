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

Then /^I should see a treatment select$/ do
  response.should have_tag('select[id$="treatment_id"]')
end

Then /^I should see the following treatment options:$/ do |table|
  table.hashes.each do |hash|
    response.should have_tag('select[id$="treatment_id"] option', hash['treatment_name'])
  end
end

Then /^I should not see the following treatment options:$/ do |table|
  table.hashes.each do |hash|
    response.should_not have_tag('select[id$="treatment_id"] option', hash['treatment_name'])
  end
end

Given /^the following treatments:$/ do |table|
  table.hashes.each do |attributes|
    Factory.create(:treatment, attributes)
  end
end

Given /^the following treatments associated with the disease "([^\"]*)":$/ do |disease_name, table|
  disease = Disease.find_by_disease_name(disease_name)
  table.hashes.each do |attributes|
    disease.treatments.create!(attributes)
  end
end
