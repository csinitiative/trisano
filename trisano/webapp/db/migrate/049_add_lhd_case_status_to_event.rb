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

class AddLhdCaseStatusToEvent < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :events, :lhd_case_status_id, :integer
    add_foreign_key :events, :lhd_case_status_id, :external_codes
    add_index :events, :lhd_case_status_id

    remove_index (:events, :event_case_status_id)
    remove_foreign_key :events, :event_case_status_id
    rename_column :events, :event_case_status_id, :udoh_case_status_id
    add_foreign_key :events, :udoh_case_status_id, :external_codes
    add_index :events, :udoh_case_status_id
  end

  def self.down
    remove_column :events, :lhd_case_status_id

    remove_index (:events, :udoh_case_status_id)
    remove_foreign_key :events, :udoh_case_status_id
    rename_column :events, :udoh_case_status_id, :event_case_status_id
    add_foreign_key :events, :event_case_status_id, :external_codes
    add_index :events, :event_case_status_id
  end
end
