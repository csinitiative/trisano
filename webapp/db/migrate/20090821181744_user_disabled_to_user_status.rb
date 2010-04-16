class UserDisabledToUserStatus < ActiveRecord::Migration
  def self.up
    add_column :users, :status, :string
    remove_column :users, :disabled
  end

  def self.down
    add_column :users, :disabled, :boolean
    remove_column :users, :status
  end
end
