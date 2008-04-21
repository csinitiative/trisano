class AddInitialVersioningFieldsToForms < ActiveRecord::Migration
  def self.up
    add_column :forms, :is_template, :boolean
    add_column :forms, :template_form_id, :integer
    add_column :forms, :form_status_id, :integer
  end

  def self.down
    remove_column :forms, :is_template
    remove_column :forms, :template_form_id
    remove_column :forms, :form_status_id
  end
end
