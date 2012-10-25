class AddEventDisplaySettingsColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :event_display_settings, :text
  end

  def self.down
    remove_column :users, :event_display_settings
  end
end
