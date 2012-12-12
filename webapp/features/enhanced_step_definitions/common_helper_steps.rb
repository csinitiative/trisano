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

Given(/^I am logged in as a super user$/) do
  switch_user(@browser, 'default_user')
  User.current_user = User.find_by_user_name('default_user')
end

Given(/^I am logged in as a lhd manager$/) do
  switch_user(@browser, 'lhd_manager')
  User.current_user = User.find_by_user_name('lhd_manager')
end

Given /^I am logged in as "(.+)"$/ do |user_name|
  visit(home_path)
  select(user_name, :from => "user_id")
end

When(/^I follow "(.+)"$/) do |link|
  When "I click the \"#{link}\" link"
end

When(/^I click the "(.+)" link$/) do |link|
  @browser.click("link=#{link}")
  @browser.wait_for_page_to_load($load_time)
end

When(/^I click the "(.+)" link and don't wait$/) do |link|
  @browser.click("link=#{link}")
end

When(/^I click the "(.+)" link and wait for ajax$/) do |link|
  @browser.click("link=#{link}")
  When "I wait for ajax"
end

When(/^I click the "(.+)" table header( (\d)+ times)?$/) do |th, ignore, times|
  (times || "1").to_i.times do
    @browser.click("xpath=//th[contains(text(), '#{th}')]")
  end
end

When(/^I click the "(.+)" link and wait to see "(.+)"$/) do |link, text|
  @browser.click "link=#{link}"
  @browser.wait_for_element "//*[contains(text(),'#{text}')]", :timeout_in_seconds => 3
end

When(/^I click the "(.+)" button$/) do |button|
  @browser.click("//input[contains(@value, '#{button}')]")
end

When(/^I click the "(.+)" button and wait for the page to load$/) do |button|
  @browser.click("//input[contains(@value, '#{button}')]")
  @browser.wait_for_page_to_load
end

When(/^I click and confirm the "(.+)" button$/) do |button|
  @browser.click("//input[contains(@value, '#{button}')]")
  @browser.get_confirmation()
  @browser.wait_for_page_to_load($load_time)
end

When(/^I click and confirm the "(.+)" button and don't wait$/) do |button|
  @browser.click("//input[contains(@value, '#{button}')]")
  @browser.get_confirmation()
end

When(/^I click and confirm the "(.+)" link$/) do |text|
  @browser.click("//a[contains(text(), '#{text}')]")
  @browser.get_confirmation()
  @browser.wait_for_page_to_load($load_time)
end

When /^I wait for the page to load$/i do
  @browser.wait_for_page_to_load
end

When /^I select "([^\"]*)" from "([^\"]*)"$/ do |value, select|
  @browser.select "//label[text()='#{select}']/following::select", value
end

When /^I fill in "([^\"]*)" with "([^\"]*)"$/ do |field, text|
  begin
    field_id = @browser.get_attribute "//label[text()='#{field}']@for"
  rescue
    field_id = field
  end

  @last_id = field_id
  @browser.type field_id, text
end

When /^I wait to see "([^\"]*)"$/ do |text|
  @browser.wait_for_element "//*[contains(text(),'#{text}')]", :timeout_in_seconds => 3
end

When /^I check "([^\"]*)"$/ do |field|
  field_id = @browser.get_attribute "//label[text()='#{field}']@for" || field
  @browser.check field_id
end

When /^I press "([^\"]*)"$/ do |button|
  @browser.click "//input[@value='#{button}']"
end

When /^I press "([^\"]*)" and wait to see "([^\"]*)"$/ do |button, text|
  @browser.click "//input[@value='#{button}']"
  @browser.wait_for_element "//*[contains(text(),'#{text}')]", :timeout_in_seconds => 3
end


When /^the following values are selected from "([^\"]*)":$/ do |select, values|
  values.raw.each do |value|
    @browser.add_selection "//label[text()='#{select}']/following::select", value
  end
end

Then(/^I should be presented with the error message \"(.+)\"$/) do |message|
  @browser.is_text_present(message).should be_true
end

Then(/^I should not be presented with an error message$/) do
  @browser.is_text_present("error prohibited").should be_false
end

Then /^I should see "([^\"]*)"$/ do |text|
  escaped_text = Regexp.escape(text)
  @browser.get_html_source.should =~ /#{escaped_text}/i
end

Then(/^I should see the following in order:$/) do |values|
  escaped_text = values.raw.join(".*")
  @browser.get_html_source.should =~ /#{escaped_text}/im
end

Then /^I should not see "([^\"]*)"$/ do |text|
  escaped_text = Regexp.escape(text)
  @browser.get_body_text.should_not =~ /#{escaped_text}/i
end

Then /^I wait for ajax$/ do
  @browser.wait_for_ajax
end

Before('@clean') do
  cleanable_classes.each(&:delete_all)
end

After('@clean') do
  cleanable_classes.each(&:delete_all)
end

def cleanable_classes
  [Attachment,
   CommonTestType,
   LabResult,
   Address,
   Note,
   HospitalsParticipation,
   ParticipationsTreatment,
   ParticipationsRiskFactor,
   Participation,
   DiseaseEvent,
   Task,
   Event,
   Form,
   FormElement,
   LoincCode,
   Organism]
end
