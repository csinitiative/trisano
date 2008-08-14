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

class AlterTestedAtUphl < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up

    remove_index :lab_results, :tested_at_uphl_yn_id
    remove_foreign_key :lab_results, :tested_at_uphl_yn_id
    rename_column :lab_results, :tested_at_uphl_yn_id, :specimen_sent_to_uphl_yn_id
    add_foreign_key :lab_results, :specimen_sent_to_uphl_yn_id, :external_codes
    add_index :lab_results, :specimen_sent_to_uphl_yn_id
  end

  def self.down
    remove_index :lab_results, :specimen_sent_to_uphl_yn_id
    remove_foreign_key :lab_results, :specimen_sent_to_uphl_yn_id
    rename_column :lab_results, :specimen_sent_to_uphl_yn_id, :tested_at_uphl_yn_id
    add_foreign_key :lab_results, :tested_at_uphl_yn_id, :external_codes
    add_index :lab_results, :tested_at_uphl_yn_id
  end
end
