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

    begin
      execute "CREATE LANGUAGE plpgsql;"
    rescue
      # No-op, language probably already exists. If not, the next execution will fail.
    end
    
    execute "CREATE FUNCTION people_trigger() RETURNS trigger AS $$
                      begin
                        new.vector :=
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.first_name,'')), 'B') ||
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.last_name,'')), 'B') ||
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.first_name_soundex,'')), 'A') ||
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.last_name_soundex,'')), 'A');
                        return new;
                      end
                    $$ LANGUAGE plpgsql;"
    execute "CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON people
                    FOR EACH ROW EXECUTE PROCEDURE people_trigger();"
  end

  def self.down
    execute "DROP INDEX people_fts_vector_index;"
    execute "ALTER TABLE people DROP COLUMN vector;"
    execute "DROP TRIGGER tsvectorupdate ON people;"
    execute "DROP FUNCTION people_trigger();"
  end
end
