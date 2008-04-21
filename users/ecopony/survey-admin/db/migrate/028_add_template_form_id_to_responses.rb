class AddTemplateFormIdToResponses < ActiveRecord::Migration
  def self.up
    add_column :responses, :template_form_id, :integer
  end

  def self.down
    remove_column :responses, :template_form_id
  end
end
