class AddIsActiveToFormElements < ActiveRecord::Migration
  def self.up
    add_column :form_elements, :is_active, :boolean, :default => true
  end

  def self.down
    remove_column :form_elements, :is_active
  end
end
