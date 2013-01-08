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

class CreateParticipationsEncounter < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up

    create_table :participations_encounters do |t|
      t.integer :user_id
      t.date :encounter_date
      t.text :description
      t.string :encounter_location_type, :limit => 40

      t.timestamps
    end

    add_column :events, :participations_encounter_id, :integer
    add_foreign_key :participations_encounters, :user_id, :users
    add_foreign_key :events, :participations_encounter_id, :participations_encounters
    
  end

  def self.down
    remove_column  :events, :participations_place_id
    remove_foreign_key :participations_encounters, :user_id
    remove_foreign_key :events, :participations_encounter_id
    drop_table :participations_encounters
  end
end
