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

#
# Log in helpers
#

Given(/^I am logged in as a super user$/) do
  log_in_as("default_user")
end

Given(/^I am logged in as a manager$/) do
  log_in_as("lhd_manager")
end

Given(/^I am logged in as a state manager$/) do
  log_in_as("state_manager")
end

Given(/^I am logged in as a lhd manager$/) do
  log_in_as("lhd_manager")
end

Given(/^I am logged in as an investigator$/) do
  log_in_as("investigator")
end

Given(/^I am logged in as a data entry tech/) do
  log_in_as("data_entry_tech")
end

Given /^I am logged in as "(.*)"$/ do |uid|
  log_in_as(uid)
end

Given /^I have the "([^"]*)" role in jurisdiction "([^"]*)"$/ do |role_name, jurisdiction_name|
  jurisdiction_id = lookup_jurisdiction(jurisdiction_name).entity_id
  role_id = Role.find_by_role_name(role_name).id
  @current_user.role_memberships << Factory(:role_membership, :role_id => role_id, :jurisdiction_id => jurisdiction_id)
end

#
# Basic moving around helpers
#

When(/^I navigate to the person management tool$/) do
  visit people_path
  response.should contain("People")
end

When(/^I click the "(.+)" link$/) do |link|
  click_link link
end

When(/^I click the "(.+)" button$/) do |button|
  click_button button
end

When /^I save the event$/i do
  if @contact_event
    submit_form "edit_contact_event_#{@contact_event.id}"
  else
    submit_form "edit_morbidity_event_#{@event.id}"
  end
end

When /^I save the contact event$/i do
  contact_event_id = @contact_event.nil? ? @event.contact_child_events.last.id : @contact_event.id
  submit_form "edit_contact_event_#{contact_event_id}"
end

When /^I save the encounter event$/ do
  submit_form "edit_encounter_event_#{@encounter.id}"
end

When /^I save the new (.+) event$/i do |event_type|
  submit_form "new_#{event_type}_event"
end

#
# Error message helpers
#

Then(/^I should be presented with the error message \"(.+)\"$/) do |message|
  response.should contain(message)
end

#
# HTTP helpers
#

Then /^I should get a (.+) response$/ do |code|
  response.code.should == code.to_s
end

Then /^I follow "(.*)" expecting a failure$/ do |link|
  lambda{ click_link(link) }.should raise_error(Webrat::PageLoadError)
end

#
# Verification Helpers
#

Then /^I should see a link to "([^\"]*)"$/ do |link_text|
  response.should have_xpath("//a[text()='#{link_text}']")
end

Then /^I should not see a link to "([^\"]*)"$/ do |link_text|
  response.should_not have_xpath("//a[text()='#{link_text}']")
end

#
# Other stuff
#

When(/^I search for the place entity "([^\"]*)"$/) do |name|
  fill_in "name", :with => name
  click_button "Search"
end

When(/^I search for the person entity "([^\"]*)"$/) do |name|
  if name.split(" ").size == 2
    fill_in "first_name", :with => name.split(" ")[0]
    fill_in "last_name", :with => name.split(" ")[1]
  else
    fill_in "last_name", :with => name
  end

  click_button "Search"
end

#
# HTML widget helpers
#
Then /^selecting "([^\"]*)" is disabled$/ do |locator|
  field = field_labeled locator
  field.should be_disabled
end

Then /^"([^\"]*)" should be selected for "([^\"]*)"$/ do |value, field|
  field_labeled(field).element.search(".//option[@selected = 'selected']").inner_html.should =~ /#{value}/
end

Then /^I should see (an|a) "([^\"]*)" tab$/ do |a, tab|
  response.should have_xpath("//ul[@class='yui-nav']/li/a/em[text()='#{tab}']")
end

Then /^I should see these select options:$/ do |select_options|
  select_options.hashes.each do |option|
    assert_tag(:tag => 'option',
      :content => option['text'],
      :parent => { :tag => 'select' })
  end
end

Then /^I should not see these select options:$/ do |select_options|
  select_options.hashes.each do |option|
    assert_no_tag(:tag => 'option',
      :content => option['text'],
      :parent => { :tag => 'select' })
  end
end

Then /^I should see only these (.+) select options:$/ do |select_id, options|
  id_regex = Regexp.new(select_id.downcase.gsub(/ +/, '_'))
  options.hashes.each_cons(2) do |this_tag, next_tag|
    assert_tag 'option', {
      :parent => {
        :tag => 'select',
        :attributes => {
          :id => id_regex
        }
      },
      :before => { :tag => 'option' }.merge(next_tag)
    }.merge(this_tag)
  end
  assert_tag 'select', {
    :attributes => { :id => id_regex },
    :children => { :count => options.rows.size }
  }
end

Then /^I should see the following:$/ do |values|
  values.hashes.each do |hash|
    assert_contain(hash[:text])
  end
end

Then /^I should see "([^\"]*)" in the (.+) table$/ do |text, table|
    response.should have_xpath("//*[@id='#{table}']//td[contains(text(),'#{text}')]")
end

Then /^I should not see "([^\"]*)" in the (.+) table$/ do |text, table|
    response.should_not have_xpath("//*[@id='#{table}']//td[contains(text(),'#{text}')]")
end

Then /^I should not see errors on the "([^\"]*)" field$/ do |text|
  response.should have_tag('label', text)
  response.should_not have_tag('div.fieldWithErrors label', text)
end

When /^I submit "(.+)" form$/ do |form|
  submit_form form
end

#
# define tag behavior
#
Before('@ignore_plugin_renderers') do
  ApplicationController.ignore_plugin_renderers = true
end

After('@ignore_plugin_renderers') do
  ApplicationController.ignore_plugin_renderers = false
end
