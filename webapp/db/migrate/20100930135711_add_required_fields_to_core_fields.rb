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

class AddRequiredFieldsToCoreFields < ActiveRecord::Migration
  def self.up
    # using SQL because AR=JDBC can't seem to get this right
    transaction do
      execute "ALTER TABLE core_fields ADD COLUMN required_for_event boolean;"
      execute "ALTER TABLE core_fields ALTER COLUMN required_for_event SET DEFAULT false;"
      execute "UPDATE core_fields SET required_for_event = false;"
      execute "ALTER TABLE core_fields ALTER COLUMN required_for_event SET NOT NULL;"
    end
  end

  def self.down
    remove_column :core_fields, :required_for_event
  end
end
