class AddIsConditionCodeToFormElements < ActiveRecord::Migration
  def self.up
     add_column :form_elements, :is_condition_code, :boolean
  end

  def self.down
     remove_column :form_elements, :is_condition_code
  end
end
