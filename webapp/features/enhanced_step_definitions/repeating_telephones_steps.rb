# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

When /^I enter the following telephone numbers:$/ do |table|
  i = 0
  table.hashes.each do |telephone_attributes|
    i += 1
    add_telephone(@browser, telephone_attributes, i)
  end
end

Then /^I should (.+) telephone save and discard buttons$/ do |see_not_see|
  if see_not_see == "see"
    expected_count = 1
  elsif see_not_see == "not see"
    expected_count = 0
  else
    raise "Unexpected statement."
  end

  save_button_count = @browser.get_xpath_count("//a[@class='save-new-telephone']").to_i
  save_button_count.should be_equal(expected_count), "Expected to see #{expected_count} save buttons, got #{save_button_count}."

  discard_button_count = @browser.get_xpath_count("//a[@class='discard-new-telephone']").to_i
  discard_button_count.should be_equal(expected_count), "Expected to see #{expected_count} discard buttons, got #{discard_button_count}." 
end

