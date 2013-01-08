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


Given /^I have the staged message "([^\"]*)"$/ do |msg_key|
  @staged_message = StagedMessage.create(:hl7_message => unique_message(hl7_messages[msg_key.downcase.to_sym]))
end

Given /^ELRs for the following patients:$/ do |table|
  table.rows.each do |patient_name|
    @staged_message = StagedMessage.create! :hl7_message => unique_message(hl7_messages[:arup_replace_name].call(patient_name.first))
  end
end

Given /^ELRs from the following labs:$/ do |table|
  table.rows.each do |lab_name|
    @staged_message = StagedMessage.create! :hl7_message => unique_message(hl7_messages[:arup_replace_lab].call(lab_name.first))
  end
end

Given /^ELRs with the following collection dates:$/ do |table|
  table.rows.each do |collection_date|
    @staged_message = StagedMessage.create! :hl7_message => unique_message(hl7_messages[:arup_replace_collection_date].call(collection_date.first))
  end
end

Given /^ELRs with the following test types:$/ do |table|
  table.rows.each do |test_type|
    @staged_message = StagedMessage.create! :hl7_message => unique_message(hl7_messages[:arup_replace_test_type].call(test_type.first))
  end
end

Given /^I select '(.+)' state$/ do |state|
  select state, :from => "message_state"
end

Given /^ELR in assigned state with no assigned event exists$/ do
  @staged_message = StagedMessage.create! :hl7_message => unique_message(hl7_messages[:arup_1])
  @staged_message.state = StagedMessage.states[:assigned]
  @staged_message.save!
end

When /^I visit the staged message new page$/ do
  visit new_staged_message_path
end

When /^I type the "([^\"]*)" message into "([^\"]*)"$/ do |msg, field|
  response.should(have_xpath("//textarea[@id='#{field}']"))
  fill_in field, :with => unique_message(hl7_messages[msg.downcase.to_sym]) || raise("no message #{msg}")
end

When /^I visit the staged message show page$/ do
  visit staged_message_path(@staged_message)
end

When /^I post the "([^\"]*)" message directly to "([^\"]*)"$/ do |msg, path|
  msg = unique_message(hl7_messages[msg.downcase.to_sym]) || msg
  http_accept("application/edi-hl7v2")
  visit path, :post, msg
end

When /^I create a new CMR from the message$/ do
  visit event_staged_message_path(@staged_message), :post
end

Then /^I should see value "([^\"]*)" in the message header$/ do |value|
  response.should have_xpath("//div[@class='staged-message']/div[@class='header']//*[contains(text(), '#{value}')]")
end

Then /^I should see value "([^\"]*)" in the message footer$/ do |value|
  response.should have_xpath("//div[@class='staged-message']/div[@class='footer']//*[contains(text(), '#{value}')]")
end

Then /^I should see value "([^\"]*)" in a message specimen$/ do |value|
  response.should have_xpath("//div[@class='staged-message']/div[@class='specimen']//*[contains(text(), '#{value}')]")
end

Then /^I should see value "([^\"]*)" under label "([^\"]*)"$/ do |value, label|
  response.should have_xpath("//th[text()='#{label}']/../../tr/td[contains(text(), '#{value}')]")
end

Then /^I should receive a 200 response$/ do
  response.should be_success
end

Then /^the "([^\"]*)" HTTP header should have a value of "([^\"]*)"$/ do |header, value|
  response[header].should == value
end

def unique_message(message)
    message = HL7::Message.new(message)
    message[:MSH].message_control_id = "#{rand(10000)}#{Time.now.to_i}"
    message.to_hl7
end
