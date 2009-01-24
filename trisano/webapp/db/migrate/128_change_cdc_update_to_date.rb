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
require 'migration_helpers'

class ChangeCdcUpdateToDate < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    transaction do
      begin
        execute('drop view v_export_cdc;')
      rescue
      end

      remove_column :events, :cdc_update
      remove_column :events, :ibis_update
      add_column :events, :cdc_updated_at, :date
      add_column :events, :ibis_updated_at, :date

      script_dir = File.join(File.dirname(__FILE__), '..', 'scripts', '128')
      execute(IO.read(File.join(script_dir,'thebigcdcsql.sql')))
    end
  end

  def self.down
    transaction do
      begin
        execute('drop view v_export_cdc;')
      rescue
      end

      add_column :events, :cdc_update, :boolean
      add_column :events, :ibis_update, :boolean
      remove_column :events, :cdc_updated_at
      remove_column :events, :ibis_updated_at

      script_dir = File.join(File.dirname(__FILE__), '..', 'scripts', '125')
      execute(IO.read(File.join(script_dir,'thebigcdcsql.sql')))
    end
  end

end
