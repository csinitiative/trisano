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
require 'migration_helpers'

class RemoveCdcSqlView < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    execute("drop view v_export_cdc")
  end

  def self.down
    transaction do
      script_dir = File.join(File.dirname(__FILE__), '..', 'scripts', '138')
      execute(IO.read(File.join(script_dir,'thebigcdcsql.sql')))
    end
  end

end
