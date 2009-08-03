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

Then /^all common test types should be available for selection$/ do
  response.should have_xpath("//form[contains(@class, '_event')]//select[contains(@id, 'test_type_id')]") do |options|
    CommonTestType.all.each do |test_type|
      options.should contain test_type.common_name
    end
  end
end

Then /^the following common test types should be available for selection$/ do |common_names|
  response.should have_xpath("//form[contains(@class, '_event')]//select[contains(@id, 'test_type_id')]") do |options|
    common_names.raw.each do |common_name|
      options.should contain common_name.first
    end
  end
end

Then /^the following common test types should not be available for selection$/ do |common_names|
  response.should have_xpath("//form[contains(@class, '_event')]//select[contains(@id, 'test_type_id')]") do |options|
    common_names.raw.each do |common_name|
      options.should_not contain common_name.first
    end
  end
end
