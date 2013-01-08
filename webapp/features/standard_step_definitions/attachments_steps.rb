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

When /^I upload the "(.*)" file$/ do |file_name|
  attach_file 'attachment_uploaded_data', File.join(RAILS_ROOT, 'spec', 'fixtures', 'files', file_name)
end

Then /^I should not see "([^\"]*)" listed as an attachment$/ do |file_name|
  response.should be_success
  response.should_not have_xpath("//span[@class=\"filename\" and contains(text(), \"#{file_name}\")]")
end

Then /^I should see "(.*)" listed as an attachment$/ do |file_name|
  response.should have_xpath("//span[@class=\"filename\" and contains(text(), \"#{file_name}\")]")
end
