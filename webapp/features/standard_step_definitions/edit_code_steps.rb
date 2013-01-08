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

Given(/^a code name "(.+)" exists$/) do |name|
  @code_name = CodeName.find_by_code_name(name)
  raise('Code #{name} does not exist') unless @code_name
end

Given(/^a code name "(.+)" does not exist$/) do |name|
  @code_name = CodeName.find_by_code_name(name)
  raise('Code #{name} does exist') if @code_name
end

Given(/^a code in name "(.+)" with the code "(.+)" exists$/) do |name, the_code|
  @code = ExternalCode.find_by_code_name_and_the_code(name, the_code)
  raise('Code #{name}, #{the_code} does not exist') unless @code
end

Given(/^a code in name "(.+)" with the code "(.+)" does not exist$/) do |name, the_code|
  @code = ExternalCode.find_by_code_name_and_the_code(name, the_code)
  @code.delete if @code
  #raise('Code #{name}, #{the_code} already exists') if @code
end

When(/^a code in name "(.+)" with the code "(.+)" is soft deleted$/) do |name, the_code|
  @code = ExternalCode.find_by_code_name_and_the_code(name, the_code)
  raise('Code #{name}, #{the_code} does not exist') unless @code
  raise('Code #{name}, #{the_code} does not exist') unless @code.deleted?
end

When(/^a code in name "(.+)" with the code "(.+)" is not soft deleted$/) do |name, the_code|
  @code = ExternalCode.find_by_code_name_and_the_code(name, the_code)
  raise('Code #{name}, #{the_code} does not exist') unless @code
  raise('Code #{name}, #{the_code} does not exist') if @code.deleted?
end

When(/^I navigate to the code management tool$/) do
  visit codes_path
  response.should contain("Codes")
end

When /^I navigate to the code list for code name "(.+)"$/ do |name|
  visit index_code_path(name)
end

When /^I navigate to the code edit for code name "(.+)" and the code "(.+)"$/ do |name, the_code|
  visit edit_code_path(name, the_code)
end

