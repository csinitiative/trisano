class AddArrayAccum < ActiveRecord::Migration
  def self.up
    begin
      execute <<-SQL
        CREATE AGGREGATE array_accum (anyelement)
        (
           sfunc = array_append,
           stype = anyarray,
           initcond = '{}'
        );
        SQL
    rescue
      say "array_accum already exists. Moving on..."
    end
  end

  def self.down
  end
end
