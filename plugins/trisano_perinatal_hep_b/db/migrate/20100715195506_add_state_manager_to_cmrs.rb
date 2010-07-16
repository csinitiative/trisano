class AddStateManagerToCmrs < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :events, :state_manager_id, :integer
    add_foreign_key :events, :state_manager_id, :users
  end

  def self.down
    remove_foreign_key :events, :state_manager_id
    remove_column :events, :state_manager_id
  end
end
