class AddDeletedAtToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :deleted_at, :timestamp
  end

  def self.down
    remove_column  :events, :deleted_at
  end
end
