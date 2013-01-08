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
Given /the event has an encounter$/ do
  @encounter = @event.encounter_child_events.create
end

Given /the encounter investigator is "(.*)"$/ do |uid|
  Given %{a user with uid "#{uid}"}
  if @encounter.participations_encounter
    @encounter.participations_encounter.update_attributes!(:user_id => @user.id)
  else
    @participations_encounter = ParticipationsEncounter.create!(:user_id => @user.id, :encounter_date => Date.yesterday, :encounter_location_type => ParticipationsEncounter.valid_location_types.first)
    @encounter.update_attributes!(:participations_encounter => @participations_encounter)
  end
end
