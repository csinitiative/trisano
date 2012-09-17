class AddIsRequiredToFormElements < ActiveRecord::Migration
  def self.up
    add_column :form_elements, :is_required, :boolean, :default => false
  end

  def self.down
    remove_column :form_elements, :is_required
  end
end
