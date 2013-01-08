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

Given /^I have (.+) access records in the system$/ do |record_count|
  record_count.to_i.times do
    Factory.create(:access_record)
  end
end

Then /^the system should have a record of access for the user and event with an access count of (.+)$/ do |access_count|
  AccessRecord.find_by_user_id_and_event_id(@current_user.id, @event.id).access_count.should == access_count.to_i
end

Then /^the record number of the event accessed should be visible$/ do
  @event.reload
  response.body.should =~ /#{@event.record_number}/m
end

When /^I access the event by clicking the record number$/ do
  @event.reload
  click_link("#{@event.record_number}")
end

