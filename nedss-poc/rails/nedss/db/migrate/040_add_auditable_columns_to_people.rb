class AddAuditableColumnsToPeople < ActiveRecord::Migration
  def self.up
      add_column(:people,:live,:boolean,:default => TRUE)
      add_column(:people,:next_ver,:integer)
      add_column(:people,:previous_ver,:integer)
  end

  def self.down
      remove_column(:people,:live)
      remove_column(:people,:next_ver)
      remove_column(:people,:previous_ver)
  end
end
