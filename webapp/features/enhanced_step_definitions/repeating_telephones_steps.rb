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

  save_button_count = @browser.get_xpath_count("//a[@class='save-new-patient-telephone']").to_i
  save_button_count.should be_equal(expected_count), "Expected to see #{expected_count} save buttons, got #{save_button_count}."

  discard_button_count = @browser.get_xpath_count("//a[@class='discard-new-patient-telephone']").to_i
  discard_button_count.should be_equal(expected_count), "Expected to see #{expected_count} discard buttons, got #{discard_button_count}." 
end


Then /^I should see all of the repeater core field config questions for each telephone number$/ do
  @core_fields ||= CoreField.all(:conditions => ["event_type = ? AND fb_accessible = ? AND disease_specific = ? AND repeater = TRUE AND key LIKE '%[interested_party][person_entity][telephones]%'", @form.event_type, true, false])
  @core_fields.count.should_not be_equal(0), "Didn't find any patient telephone core fields."

  expected_count = @event.interested_party.person_entity.telephones.count.to_s
  @core_fields.each do |core_field|
    before_config_count = @browser.get_xpath_count("//label[contains(text(), '#{core_field.key} before?')]")
    (before_config_count==expected_count).should(be_true, "Expected '#{core_field.key} before?' label to appear #{expected_count} times. Got #{before_config_count}.")
    after_config_count = @browser.get_xpath_count("//label[contains(text(), '#{core_field.key} after?')]")
    (after_config_count==expected_count).should(be_true, "Expected '#{core_field.key} after?' label to appear #{expected_count} times. Got #{after_config_count}.")
  end
end

Given /^a (.+) event with with a form with repeating core fields and telephones$/ do |event_type|
  And "a #{event_type} event with with a form with repeating core fields"
  And   "I navigate to the #{event_type} event edit page"
  add_telephone(@browser, {:type => "Work", "area code" => "555", :number => "555-5555"})
  And   "I save the event"
end

Then /^I should see (\d+) blank telephone form$/ do |count|
  unsaved_telephones = @browser.get_xpath_count("//div[@class='phone']//span[@class='ajax-actions']")
  unsaved_telephones.to_i.should be_equal(count.to_i)
end

When /^I click the Telephone Save link$/ do
  @browser.click("//div[@class='phone']//a[@class='save-new-patient-telephone']")
  sleep(1)
end

When /^I discard the unsaved telephone$/ do
  @browser.click("//div[@class='phone']//a[@class='discard-new-patient-telephone']")
end
