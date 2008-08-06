class MoveConditionToFormElements < ActiveRecord::Migration
  def self.up
    add_column :form_elements, :condition, :string
    remove_column :questions, :condition
  end

  def self.down
    add_column :questions, :condition, :string
    remove_column :form_elements, :condition
  end
end
