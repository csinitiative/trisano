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
