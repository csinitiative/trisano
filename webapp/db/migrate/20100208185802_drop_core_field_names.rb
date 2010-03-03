class DropCoreFieldNames < ActiveRecord::Migration
  def self.up
    remove_column :core_fields, :name
  end

  def self.down
    add_column :core_fields, :name, :text
  end
end
