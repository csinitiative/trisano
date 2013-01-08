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

class FixUpPlaceTypes < ActiveRecord::Migration
  def self.up
      create_table :places_types, :id => false do |t|
        t.integer :place_id
        t.integer :type_id
      end
      
      execute("ALTER TABLE places_types ADD PRIMARY KEY (place_id, type_id)")

      say "Removing old columns and tables"
      remove_column :places, :place_type_id
      drop_table :reporting_agency_types
  end

  def self.down
    drop_table :places_types
    add_column :places, :place_type_id, :integer
    create_table :reporting_agency_types do |t|
      t.integer :place_id
      t.integer :code_id
      t.timestamps
    end
  end
end
