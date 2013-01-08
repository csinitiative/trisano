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

class AddElrFields < ActiveRecord::Migration
  def self.up
    add_column :staged_messages, :patient_last_name,  :string
    add_column :staged_messages, :patient_first_name, :string
    add_column :staged_messages, :laboratory_name,    :string
    add_column :staged_messages, :collection_date,    :date
    create_table :staged_observations do |t|
      t.integer :staged_message_id
      t.string  :test_type
      t.timestamps
    end
    add_index :staged_observations, :staged_message_id
  end

  def self.down
    remove_column :staged_messages, :patient_last_name
    remove_column :staged_messages, :patient_first_name
    remove_column :staged_messages, :laboratory_name
    remove_column :staged_messages, :collection_date
    remove_index :staged_observations, :staged_message_id
    drop_table   :staged_observations
  end
end
