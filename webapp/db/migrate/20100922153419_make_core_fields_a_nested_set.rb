class MakeCoreFieldsANestedSet < ActiveRecord::Migration
  def self.up
    transaction do
      execute "create sequence core_field_tree_id_generator"
      add_column :core_fields, :tree_id, :integer
      add_column :core_fields, :rgt, :integer
      add_column :core_fields, :lft, :integer
      add_column :core_fields, :parent_id, :integer
    end
  end

  def self.down
    transaction do
      execute "drop sequence core_field_tree_id_generator"
      remove_column :core_fields, :tree_id
      remove_column :core_fields, :rgt
      remove_column :core_fields, :lft
      remove_column :core_fields, :parent_id
    end
  end
end
