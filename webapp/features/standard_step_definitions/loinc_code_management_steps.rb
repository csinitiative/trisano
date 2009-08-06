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

Given /^I have a loinc code "(.*)" with test name "(.*)"$/ do |loinc_code, test_name|
  LoincCode.create!(:loinc_code => loinc_code, :test_name => test_name)
end

Given /^I have (\d+) sequential loinc codes, starting at (.*)$/ do |count, start_with|
  (1..count.to_i).inject(start_with) do |current_code, index|
    LoincCode.create!(:loinc_code => current_code)
    current_code.next
  end
end

Given /^I have the following LOINC codes in the the system:$/ do |table|
  table.raw.each do |record|
    LoincCode.create!(:loinc_code => record.first, :test_name => record.last)
  end
end

