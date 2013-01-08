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
When /^I copy the question to the library root$/ do
  visit("/forms/to_library",
        :post,
        :reference_element_id => @question_element.id,
        :group_element_id => 'root')
end

Then /^the question should appear under no group in the library$/i do
  response.should have_selector('li') do |li|
    li.should contain(@question_element.question.question_text)
  end
end

Given /^I have a library group named "([^\"]*)"$/ do |name|
  @group_element = Factory.build(:group_element, :name => name)
  @group_element.save_and_add_to_form
end

When /^I copy the question to the library group "([^\"]*)"$/ do |group_name|
  @group_element = GroupElement.find_by_name(group_name)
  visit("/forms/to_library",
        :post,
        :reference_element_id => @question_element.id,
        :group_element_id => @group_element.id)
end

Then /^the question is in the library group$/ do
  @group_element.reload
  @group_element.children.any? do |c|
    c.question.try(:question_text) == @question_element.question.question_text
  end.should(be_true)
end

When /^I copy the question to an invalid library group$/ do
  @group_element = Factory.create(:group_element)
  visit("/forms/to_library",
        :post,
        :reference_element_id => @question_element.id,
        :group_element_id => @group_element.id)
end
