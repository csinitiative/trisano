class AddRequiredFieldsToCoreFields < ActiveRecord::Migration
  def self.up
    add_column :core_fields, :required_for_event, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :core_fields, :required_for_event
  end
end
