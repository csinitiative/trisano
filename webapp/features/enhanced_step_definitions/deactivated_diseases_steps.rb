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

Then /^the deactivated disease should be selected in the disease select list$/ do
  assert_match(@event.disease_event.disease.id.to_s, @browser.get_selected_value("xpath=//select[@id='morbidity_event_disease_event_attributes_disease_id']"))
end

Then /^the deactivated disease should still be set on the event$/ do
  @event.disease_event.disease.should_not be_nil
end
