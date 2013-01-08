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

class CreateAvrGroups < ActiveRecord::Migration
  def self.up
    create_table :avr_groups do |t|
      t.string :name

      t.timestamps
    end

    create_table :avr_groups_diseases, :id => false do |t|
      t.integer :avr_group_id
      t.integer :disease_id
      
      t.timestamps
    end

    execute("ALTER TABLE avr_groups_diseases ADD PRIMARY KEY (avr_group_id, disease_id)")
  end

  def self.down
    execute("ALTER TABLE avr_groups_diseases DROP PRIMARY KEY (avr_group_id, disease_id)")

    drop_table :avr_groups
    drop_table :avr_groups_diseases
  end
end

