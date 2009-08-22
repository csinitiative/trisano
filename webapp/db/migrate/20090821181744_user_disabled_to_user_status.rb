class UserDisabledToUserStatus < ActiveRecord::Migration
  def self.up
    add_column :users, :status, :string
    execute "UPDATE users set status='Active'   where disabled IS NULL OR disabled = false"
    execute "UPDATE users set status='Disabled' where disabled = true"
    remove_column :users, :disabled
  end

  def self.down
    add_column :users, :disabled, :boolean
    execute "UPDATE users set disabled = NULL where status = 'Active'"
    execute "UPDATE users set disabled = true where status = 'Disabled'"
    remove_column :users, :status
  end
end
