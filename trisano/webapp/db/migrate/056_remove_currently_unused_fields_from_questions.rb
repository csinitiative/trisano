class RemoveCurrentlyUnusedFieldsFromQuestions < ActiveRecord::Migration
  def self.up
    remove_column :questions, :is_on_short_form
    remove_column :questions, :is_exportable
    remove_column :questions, :is_template
    remove_column :questions, :template_id
  end

  def self.down
    add_column :questions, :is_on_short_form, :boolean
    add_column :questions, :is_exportable, :boolean
    add_column :questions, :is_template, :boolean
    add_column :questions, :template_id, :integer
  end
end
