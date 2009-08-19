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

Given /^the question "([^\"]*)" is in the library$/ do |question_text|
  @question = Factory.create :question_single_line_text, :question_text => question_text
  @question_element = Factory.create :question_element, :question => @question, :tree_id => FormElement.next_tree_id
end

When /^I delete the question element$/ do
  @browser.click "//a[@id='delete-question-#{@question_element.id}']"
end

Then /^the text "(.+)" should disappear$/ do |text|
  @browser.wait_for_no_element "//*[contains(text(),'#{text}')]"
end

