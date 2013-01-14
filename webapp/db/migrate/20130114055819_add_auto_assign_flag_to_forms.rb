class AddAutoAssignFlagToForms < ActiveRecord::Migration
  def self.up
    add_column :forms, :disable_auto_assign, :boolean
  end

  def self.down
    remove_column :forms, :disable_auto_assign
  end
end
