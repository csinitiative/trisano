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

class AddTrigramSearch < ActiveRecord::Migration
  def self.up
    transaction do
      execute(IO.read(File.join(File.dirname(__FILE__), '..', 'pg_trgm.sql')))
      execute("CREATE INDEX last_name_trgm_idx ON people USING gist (last_name gist_trgm_ops);")
      execute("CREATE INDEX first_name_trgm_idx ON people USING gist (first_name gist_trgm_ops);")
    end
  end

  def self.down
    transaction do
      execute("DROP INDEX last_name_trgm_idx ON people;")
      execute("DROP INDEX first_name_trgm_idx ON people;")
    end
  end
end
