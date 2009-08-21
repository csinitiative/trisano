class ChangeUserDisableToDisabled < ActiveRecord::Migration
  def self.up
    rename_column :users, :disable, :disabled
  end

  def self.down
    rename_column :users, :disabled, :disable
  end
end
