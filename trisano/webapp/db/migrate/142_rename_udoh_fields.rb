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

require "migration_helpers"

class RenameUdohFields < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    remove_index (:events, :udoh_case_status_id)
    remove_foreign_key :events, :udoh_case_status_id
    rename_column :events, :udoh_case_status_id, :state_case_status_id
    add_foreign_key :events, :state_case_status_id, :external_codes
    add_index :events, :state_case_status_id

    rename_column :events, :review_completed_UDOH_date, :review_completed_by_state_date

    CoreField.update_all("key = 'morbidity_event[state_case_status_id]'", "key = 'morbidity_event[udoh_case_status_id]'")
    CoreField.update_all("key = 'morbidity_event[review_completed_by_state_date]'", "key = 'morbidity_event[review_completed_UDOH_date]'")
  end

  def self.down
    remove_index (:events, :state_case_status_id)
    remove_foreign_key :events, :state_case_status_id
    rename_column :events, :state_case_status_id, :udoh_case_status_id
    add_foreign_key :events, :udoh_case_status_id, :external_codes
    add_index :events, :udoh_case_status_id

    rename_column :events, :review_completed_by_state_date, :review_completed_UDOH_date
  end
end
