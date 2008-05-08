class AddReusabilityToFormElements < ActiveRecord::Migration
  def self.up
    add_column :form_elements, :is_template, :boolean
    add_column :form_elements, :template_id, :integer
  end

  def self.down
    remove_column :form_elements, :is_template
    remove_column :form_elements, :template_id
  end
end

