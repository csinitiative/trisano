# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

Given /^that the event has been sent to the state$/ do
  @event.workflow_state = 'closed'
  @event.save.should be_true
end

When /^I click "([^\"]*)"$/ do |arg1|
  pending
end

Then /^the Morbidity event is returned to the "([^\"]*)" state$/ do |arg1|
  pending
end

Given /^a morbidity event from my jurisdiction has already been approved by the state$/ do
  pending
end
