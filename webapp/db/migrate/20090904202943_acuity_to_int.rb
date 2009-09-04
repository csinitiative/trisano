class AcuityToInt < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE events ALTER acuity TYPE integer USING case when substring(acuity from '[[:digit:]]+') = '' then null else cast(substring(acuity from '[[:digit:]]+') as integer) end;")
  end

  def self.down
  end
end
