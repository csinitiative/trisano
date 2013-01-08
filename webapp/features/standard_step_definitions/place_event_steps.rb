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

Then /^the place should have the jurisdiction of its parent event$/ do
  place_added_through_ui.jurisdiction.secondary_entity_id.should == @event.jurisdiction.secondary_entity_id
end

Then /^the place should have the disease of its parent event$/ do
  place_added_through_ui.disease_event.disease.id.should == @event.disease_event.disease.id
end

Then /^the place should have a canonical address$/ do
  place_added_through_ui.interested_place.place_entity.canonical_address.should_not be_nil
end

Then /^the place name and place type should not be editable$/ do
  response.should_not have_xpath("//input[@id='place_event_interested_place_attributes_place_entity_attributes_place_attributes_name']")
  response.should_not have_xpath("//input[@id='place_event_interested_place_attributes__place_entity_attributes__place_attributes_place_type_H']")
end

def place_added_through_ui
  @event.reload
  @place_event_added_through_ui ||= PlaceEvent.find(@event.place_child_events.reject { |pe| pe.id == @place_event.id }.first)
end
