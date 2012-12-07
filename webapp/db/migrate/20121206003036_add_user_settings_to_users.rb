class AddUserSettingsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :user_settings, :text
  end

  def self.down
    remove_column :users, :user_settings
  end
end
