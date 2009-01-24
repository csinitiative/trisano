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

class InstallCdcExportData < ActiveRecord::Migration

  extend MigrationHelpers

  def self.up
    begin; execute('DROP FUNCTION fnTrisanoExport(integer)'); rescue;end
    begin; execute('DROP FUNCTION  fnTrisanoExportNonGenericCdc (iexport_id integer, iexport_name varchar(50))'); rescue;end

    transaction do
      execute("alter table export_predicates alter column comparison_value TYPE varchar(2000)")
      script_dir = File.join(File.dirname(__FILE__), '..', 'scripts', '094')
      # Insert SQL removed when a load script was implemented
      # %w(fnTrisanoBuildPredicate.sql fnTrisanoExport.sql insert_export_cols.sql thebigcdcsql.sql).each do |file|
      %w(fnTrisanoBuildPredicate.sql fnTrisanoExport.sql thebigcdcsql.sql).each do |file|
        execute(IO.read(File.join(script_dir,file)))
      end
    end
  end

  def self.down
    transaction do
      execute("drop view v_export_cdc")
      execute("truncate table export_predicates cascade")
      execute("truncate table export_columns cascade")
      execute("truncate table export_conversion_values cascade")
    end
  end
  
end
