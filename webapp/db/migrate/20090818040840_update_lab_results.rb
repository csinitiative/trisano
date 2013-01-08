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

class UpdateLabResults < ActiveRecord::Migration
 extend MigrationHelpers

  def self.up
    add_column :lab_results, :loinc_code, :string, :limit => 10
    add_column :lab_results, :test_type_id, :integer
    add_column :lab_results, :test_result_id, :integer
    add_column :lab_results, :result_value, :string
    add_column :lab_results, :units, :string, :limit => 50
    rename_column :lab_results, :specimen_sent_to_uphl_yn_id, :specimen_sent_to_state_id
    add_column :lab_results, :test_status_id, :integer
    add_column :lab_results, :comment, :text

    # Put this back when we have bootstrapped the data
    # add_foreign_key :lab_results, :test_type_id, :common_test_types
  end

  def self.down
    remove_column :lab_results, :test_type_id
    remove_column :lab_results, :interpretation_id
    remove_column :lab_results, :result_value
    remove_column :lab_results, :units
    rename_column :lab_results, :specimen_sent_to_state_id, :specimen_sent_to_uphl_yn_id
    remove_column :lab_results, :test_status_id
    remove_column :lab_results, :comment
  end
end
