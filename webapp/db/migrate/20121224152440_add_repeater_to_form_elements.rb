class AddRepeaterToFormElements < ActiveRecord::Migration
  def self.up
    add_column :form_elements, :repeater, :boolean
  end

  def self.down
    drop_column :form_elements, :repeater
  end
end
