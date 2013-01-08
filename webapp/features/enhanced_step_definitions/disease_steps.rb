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
When /^I go to the diseases admin page$/ do
  @browser.open "/trisano/diseases"
end

Given /^these diseases exist:$/ do |table|
  table.hashes.each do |attr|
    unless Disease.exists?(['disease_name = ?', attr['disease_name']])
      Factory.create(:disease, attr)
    end
  end
end

When /^I follow the "([^\"]*)" disease Core Fields link$/ do |disease_name|
  @disease = Disease.find_by_disease_name(disease_name)
  @browser.click("css=a[href='/trisano/diseases/#{@disease.id}/core_fields']")
  @browser.wait_for_page_to_load
end

When /^I follow the "([^\"]*)" disease Treatments link$/ do |disease_name|
  @disease = Disease.find_by_disease_name(disease_name)
  @browser.click("css=a[href='/trisano/diseases/#{@disease.id}/treatments']")
  @browser.wait_for_page_to_load
end
