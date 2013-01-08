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

Given /^I have a lab result$/ do
  @lab_result = Factory.create(:lab_result)
end

Given /^the lab result references the common test type$/ do
  @lab_result.update_attribute(:test_type_id, @common_test_type.id)
end

Given /^the event had the following lab results:$/ do |table|
  lab = Factory.create(:lab, :lab_results => [])
  @event.labs << lab

  table.hashes.each do |attributes|
    common_test_type = CommonTestType.find_by_common_name(attributes['test_type']) || Factory.create(:common_test_type, :common_name => attributes['test_type'])

    lab_result = Factory.create(:lab_result, :test_type => common_test_type)
    lab.lab_results << lab_result
    @event.save!
  end
end

Given /^the following organisms exist$/ do |organisms|
  organisms.raw.each do |organism|
    Organism.create(:organism_name => organism.first)
  end
end
