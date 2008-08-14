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

class AddFulltextSupportToPeople < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE people ADD COLUMN vector tsvector;"
    execute "CREATE INDEX people_fts_vector_index ON people USING gist(vector);"
    execute "vacuum full analyze;"
    # execute "update pg_ts_cfg set locale = 'en_US' where ts_name = 'default';"
    execute "CREATE TRIGGER tsvectorupdate BEFORE UPDATE OR INSERT ON people
              FOR EACH ROW EXECUTE PROCEDURE
              tsearch2(vector, first_name, last_name, first_name_soundex, last_name_soundex);"
    execute "update people set vector = setweight(
              to_tsvector('default', coalesce(first_name,'') || ' ' || 
              coalesce(last_name,'') || ' ' || 
              coalesce(first_name_soundex,'') || ' ' || 
              coalesce(last_name_soundex,'')),'A');"
  end

  def self.down
   execute "DROP INDEX people_fts_vector_index;"
   execute "ALTER TABLE people DROP COLUMN vector;"
   execute "DROP TRIGGER tsvectorupdate ON people;"
  end
end
