class RemoveRepeaterParentKeyFromCoreField < ActiveRecord::Migration
  def self.up
    remove_column :core_field, :repeater_parent_key
  end

  def self.down
    add_column :core_fields, :repeater_parent_key, :string
  end
end
