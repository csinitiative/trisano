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
When /^I navigate to the loinc code "([^\"]*)" edit page$/ do |loinc_code|
  @browser.click "link=ADMIN"
  @browser.wait_for_page_to_load
  @browser.click "link=Manage LOINC Codes"
  @browser.wait_for_page_to_load
  @browser.click "link=#{loinc_code}"
  @browser.wait_for_page_to_load
  @browser.click "link=Edit"
  @browser.wait_for_page_to_load
end

Then /^the Organism field should be disabled$/ do
  @browser.is_editable('css=#loinc_code_organism_id').should be_false
end

Then /^the Organism field should be enabled$/ do
  @browser.is_editable('css=#loinc_code_organism_id').should be_true
end

