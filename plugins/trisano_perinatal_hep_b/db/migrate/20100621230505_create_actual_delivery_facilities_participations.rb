# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class CreateActualDeliveryFacilitiesParticipations < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :actual_delivery_facilities_participations do |t|
      t.integer :participation_id
      t.date :actual_delivery_date

      t.timestamps
    end

    add_foreign_key :actual_delivery_facilities_participations, :participation_id, :participations
  end

  def self.down
    remove_foreign_key :actual_delivery_facilities_participations, :participation_id
    drop_table :actual_delivery_facilities_participations
  end
end
