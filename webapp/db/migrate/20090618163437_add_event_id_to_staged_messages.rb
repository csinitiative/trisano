# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

class AddEventIdToStagedMessages < ActiveRecord::Migration
   extend MigrationHelpers

 def self.up
    add_column :staged_messages, :event_id, :integer
    add_foreign_key :staged_messages, :event_id, :events
    add_index :staged_messages, :event_id
 end

  def self.down
    remove_column :staged_messaged, :event_id
  end
end
