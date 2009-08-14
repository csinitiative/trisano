class SoftDeleteCodes < ActiveRecord::Migration
  def self.up
    add_column :codes, :deleted_at, :timestamp
    add_column :external_codes, :deleted_at, :timestamp
  end

  def self.down
    remove_column :codes, :deleted_at
    remove_column :external_codes, :deleted_at
  end
end
