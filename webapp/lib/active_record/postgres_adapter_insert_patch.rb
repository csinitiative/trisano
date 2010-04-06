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

# Between 2.0.2 and 2.0.5, insert stopped returning the id of the inserted
# row. This patch gets the last inserted row included again. This patch can
# go away when TriSano upgrades beyond the Rails 2.0
#
# See: http://rails.lighthouseapp.com/projects/8994/tickets/384-connection-insert-no-longer-returns-last-inserted-id
# and
# http://github.com/rails/rails/commit/a065144afb9e8b4666a5097e3e81de80251e86e6

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  
  # Executes an INSERT query and returns the new record's ID
  def insert(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
    if insert_id = super
      insert_id
    else
      # Extract the table from the insert sql. Yuck.
      table = sql.split(" ", 4)[2].gsub('"', '')

      # If neither pk nor sequence name is given, look them up.
      unless pk || sequence_name
        pk, sequence_name = *pk_and_sequence_for(table)
      end

      # If a pk is given, fallback to default sequence name.
      # Don't fetch last insert id for a table without a pk.
      if pk && sequence_name ||= default_sequence_name(table, pk)
        last_insert_id(table, sequence_name)
      end
    end
  end
end
