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

class CreateDiseasesExportColumns < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    transaction do
      create_table :diseases_export_columns do |t|
        t.integer :disease_id
        t.integer :export_column_id
      end
      add_foreign_key(:diseases_export_columns, :disease_id, :diseases)
      add_foreign_key(:diseases_export_columns, :export_column_id, :export_columns)
    end
  end

  def self.down
    transaction do
      drop_table :diseases_export_columns
    end
  end
end
