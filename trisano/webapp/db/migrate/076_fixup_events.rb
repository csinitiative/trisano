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

class FixupEvents < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == "production"
      transaction do
        # Though this shouldn't be necessary, guarantee all events have a proper event_status.  Set suspect ones to "NEW"
        execute("SELECT id, event_status from events").each do |event_state|
          execute("UPDATE events SET event_status='NEW' WHERE events.id = #{event_state[0]}") unless Event.get_state_keys.include?(event_state[1])
        end
      end
    end
  end

  def self.down
  end
end
