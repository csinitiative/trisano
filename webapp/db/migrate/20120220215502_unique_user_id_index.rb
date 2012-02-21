class UniqueUserIdIndex < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE UNIQUE INDEX lower_uid_ix ON users (LOWER(uid));
    SQL
  end

  def self.down
    execute <<-SQL
      DROP INDEX lower_uid_ix;
    SQL
  end
end
