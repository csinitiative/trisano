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

Given /^the question "([^\"]*)" in group "([^\"]*)" is in the library$/ do |question_text, group_name|
  @group_element = GroupElement.create! :name => group_name, :tree_id => FormElement.next_tree_id
  @question = Factory.create :question_single_line_text, :question_text => question_text
  @question_element = Factory.create :question_element, :question => @question, :tree_id => @group_element.id
end

Given /^a value set named "([^\"]*)" exists in the library with these values:$/ do |value_set_name, table|
  @value_set_element = ValueSetElement.create! :name => value_set_name, :tree_id => FormElement.next_tree_id
  table.rows.each do |row|
    @value_set_element.value_elements << ValueElement.create!(:name => row.first,
                                                              :code => row.last,
                                                              :tree_id => @value_set_element.tree_id)
  end
  @value_set_element.save!
end

When /^I delete the question element$/ do
  @browser.click "//a[@id='delete-question-#{@question_element.id}']"
end

When /^I delete the value set element$/ do
  @browser.click "//a[@id='delete-value-set-#{@value_set_element.id}']"
end

Then /^the text "(.+)" should disappear$/ do |text|
  @browser.wait_for_no_element "//*[contains(text(),'#{text}')]", :timeout_in_seconds => 3
end

After('@clean_forms') do
  Form.destroy_all
end

After('@clean_form_elements') do
  FormElement.destroy_all
end

