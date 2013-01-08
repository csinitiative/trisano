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

class AddEggySearchFu < ActiveRecord::Migration
  def self.up
    transaction do
      remove_column :people, :first_name_soundex
      remove_column :people, :last_name_soundex
      remove_column :people, :vector
      execute("DROP INDEX IF EXISTS people_fts_vector_index;")
      execute("DROP FUNCTION people_trigger() CASCADE;")
      execute("DROP INDEX IF EXISTS last_name_trgm_idx;")
      execute("DROP INDEX IF EXISTS first_name_trgm_idx;")
      execute("DROP INDEX IF EXISTS people_on_first_name_soundex;")
      execute("DROP INDEX IF EXISTS people_on_last_name_soundex;")
      execute(IO.read(File.join(File.dirname(__FILE__), '..', 'fuzzystrmatch.sql')))
      execute(IO.read(File.join(File.dirname(__FILE__), '..', 'name_search.sql')))
    end
  end

  # ok, you caught me. I'm not removing the name search bits, but they
  # shouldn't get in the way
  def self.down
    transaction do
      add_column :people, :first_name_soundex, :string
      add_column :people, :last_name_soundex,  :string
      execute "ALTER TABLE people ADD COLUMN vector tsvector;"

      execute "CREATE INDEX people_fts_vector_index ON people USING gist(vector);"

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

      add_index (:people, :first_name_soundex)
      add_index (:people, :last_name_soundex)

      execute("CREATE INDEX last_name_trgm_idx ON people USING gist (last_name gist_trgm_ops);")
      execute("CREATE INDEX first_name_trgm_idx ON people USING gist (first_name gist_trgm_ops);")
    end
  end
end
