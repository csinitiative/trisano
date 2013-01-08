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
Given /^I have (a|another) common test type named (.*)$/ do |a, common_name|
  @common_test_type = Factory.create(:common_test_type, :common_name => common_name)
end

When /^I debug$/ do
  debugger
end

Then /^I should (.+) a label "(.+)"$/ do |see_not_see, label_text|
  label_occurances = @browser.get_xpath_count("//label[text()='#{label_text}']").to_i

  if see_not_see == "see"
    label_occurances.should >(0)
  elsif see_not_see == "not see"
    label_occurances.should ==(0)
  else
    raise "Unexpected instruction: #{see_not_see}"
  end
end
