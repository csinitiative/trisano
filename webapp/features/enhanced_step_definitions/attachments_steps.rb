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

Given /^a file attachment named "([^\"]*)"$/ do |file_name|
  @attachment = Attachment.new(:uploaded_data => {
                                 'size' => 23,                                 
                                 'filename' => 'test-attachment',
                                 'tempfile' => open(File.join(RAILS_ROOT, 'spec', 'fixtures', 'files', file_name))},
                               :event_id => (@event).id,
                               :category => '')
  @attachment.save!
end

When /^I navigate to the add attachments page$/ do
  @browser.open "/trisano/events/#{(@event).id}/attachments/new"
  @browser.wait_for_page_to_load
end

When(/^I click and confirm the attachment "(.+)" link$/) do |text|
  @browser.click("//tr[@id='attachment_#{@attachment.id}']//a[contains(text(), 'Delete')]")
  #@browser.get_confirmation()
end

When(/^I wait a few seconds$/) do
  sleep(3)
end

Then /^I should not see "([^\"]*)" listed as an attachment$/ do |file_name|
  @browser.get_html_source.should_not =~ /#{file_name}/
end




