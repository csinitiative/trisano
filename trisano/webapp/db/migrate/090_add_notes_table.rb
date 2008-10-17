# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

require "migration_helpers"

class AddNotesTable < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    transaction do
      create_table :notes do |t|
        t.text :note
        t.boolean :struckthrough
        t.integer :user_id
        t.timestamps
        t.integer :event_id
      end
      add_foreign_key(:notes, :user_id, :users)
      add_foreign_key(:notes, :event_id, :events)
    end
  end

  def self.down
    transaction do
      drop_table :notes
    end
  end
end
