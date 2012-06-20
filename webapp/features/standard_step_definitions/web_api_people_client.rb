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

Given /^I have a known person entity$/ do
  @person_entity = Factory.build(:person_entity)
  @person_entity.person.first_name = 'Robert'
  @person_entity.person.middle_name = 'Michael'
  @person_entity.person.last_name = 'Smith-Johnson'
  @person_entity.person.birth_date = '11-10-1980'
  @person_entity.person.birth_gender_id = ExternalCode.find_by_code_description('Male').id
  @person_entity.person.primary_language_id = ExternalCode.find_by_code_description('English').id
  @person_entity.person.ethnicity_id = ExternalCode.find_by_code_description('Hispanic or Latino').id
  @person_entity.races = [ExternalCode.find_by_code_description('White')]
  @person_entity.build_canonical_address
  @person_entity.canonical_address.street_number = '123'
  @person_entity.canonical_address.street_name = 'George Mason Dr.'
  @person_entity.canonical_address.unit_number = '448'
  @person_entity.canonical_address.city = 'Arlington'
  @person_entity.canonical_address.state_id = ExternalCode.find_by_code_description('Utah').id
  @person_entity.canonical_address.county_id = ExternalCode.find_by_code_description('Beaver').id
  @person_entity.email_addresses.build :email_address => 'foo@bar.com'
  @person_entity.telephones << Telephone.new(:area_code => '555', :phone_number => '555-5555')
  @person_entity.person.save!
  @person_entity.save!
end

Given(/^that known person entity has been deleted$/) do
  @person_entity.deleted_at = Time.now
  @person_entity.save!
end

When /^I visit the person show page$/ do
  visit(person_path(@person_entity))
end

When /^I visit the people index page$/ do
  visit people_path
end

When /^I visit the people new page$/ do
  visit new_person_path
end

When /^I visit the people edit page$/ do
  visit(edit_person_path(@person_entity))
end

When /^I search people by "(.+?)" with "(.+?)"$/ do |key, value|
  visit people_path
  fill_in key, :with => value
  click_button "Search"
end

Then /^I should find the value "(.+?)" in "(.+?)"$/ do |value, key|
  response.should have_xpath(".//span[@class='#{key}'][text()='#{value}']")
end

Then /^I should not find the value "(.+?)" in "(.+?)"$/ do |value, key|
  response.should_not have_xpath(".//span[@class='#{key}'][text()='#{value}']")
end

Then /^I fill out the form field "(.+?)" with "(.+?)"$/ do |key, value|
  fill_in key, :with => value
end

Then /^I set the pregnancy due date for the (.+?) to some future date$/ do |value|
  fill_in "#{value}[interested_party_attributes][risk_factor_attributes][pregnancy_due_date]",
          :with => 1.month.from_now.strftime('%m-%d-%Y')
end
