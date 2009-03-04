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

module EncounterEventsHelper

  # Builds a list of users for use in the investigator drop down for encounter events. It
  # adds the current user to the front of the list if the current user isn't included in the
  # results pulled back based on permissions.
  def users_for_investigation_select
    users =  User.investigators_for_jurisdictions(User.current_user.jurisdictions_for_privilege(:update_event))
    users.unshift(User.current_user) unless users.include?(User.current_user)
    users
  end

end
