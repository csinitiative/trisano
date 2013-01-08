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

class CreateAccessRecords < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :access_records do |t|
      t.integer :user_id, :null => false
      t.integer :event_id, :null => false
      t.text :reason
      t.integer :access_count, :default => 0, :null => false

      t.timestamps
    end
    
    add_index :access_records, [:user_id, :event_id], :unique => true, :name => :users_and_events_unique
    add_foreign_key :access_records, :user_id, :users
    add_foreign_key :access_records, :event_id, :events
  end

  def self.down
    remove_index :access_records, :name => :users_and_events_unique
    remove_foreign_key :access_records, :user_id
    remove_foreign_key :access_records, :event_id
    drop_table :access_records
  end
end
