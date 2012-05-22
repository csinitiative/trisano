class AddPasswordLastUpdatedFieldToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :password_last_updated, :date
    User.update_all("password_last_updated = '#{Date.today.to_s(:db)}'", "password_last_updated IS NULL" )
  end

  def self.down
    remove_column :users, :password_last_updated
  end
end
