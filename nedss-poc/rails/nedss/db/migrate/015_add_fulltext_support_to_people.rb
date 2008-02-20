class AddFulltextSupportToPeople < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE people ADD COLUMN vector tsvector;"
    execute "CREATE INDEX people_fts_vector_index ON people USING gist(vector);"
    execute "vacuum full analyze;"
    execute "update pg_ts_cfg set locale = 'en_US' where ts_name = 'default';"
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
