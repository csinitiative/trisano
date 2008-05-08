class AddVersioningToForms < ActiveRecord::Migration
  def self.up
    add_column :forms, :is_template, :boolean
    add_column :forms, :template_id, :integer
    add_column :forms, :version, :integer
    add_column :forms, :status, :string
  end

  def self.down
    remove_column :forms, :is_template
    remove_column :forms, :template_id
    remove_column :forms, :version
    remove_column :forms, :status
  end
end
