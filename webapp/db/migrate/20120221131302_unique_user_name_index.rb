class UniqueUserNameIndex < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE UNIQUE INDEX lower_username ON users (LOWER(user_name));
    SQL
  end

  def self.down
    execute <<-SQL
      DROP INDEX lower_username_ix;
    SQL
  end
end
