class AddTypeFieldToEntity < ActiveRecord::Migration

  def self.up
    add_column :entities, :entity_type, :string
  end

  def self.down
    remove_column :entities, :entity_type
  end
end

