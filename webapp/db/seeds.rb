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
%w( manage_entities
		merge_people
		merge_places
		manage_locales
		create_event
		view_event
		update_event
		route_event_to_any_lhd
		accept_event_for_lhd
		route_event_to_investigator
		accept_event_for_investigation
		investigate_event
		approve_event_at_lhd
		approve_event_at_state
		administer
		assign_task_to_user
		add_form_to_event
		remove_form_from_event
		access_avr
		manage_staged_message
		write_staged_message
    view_access_records
    access_sensitive_diseases
).each do |p|
  Privilege.create(:priv_name => p)
end
