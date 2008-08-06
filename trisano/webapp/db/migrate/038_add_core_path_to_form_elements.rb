class AddCorePathToFormElements < ActiveRecord::Migration
  def self.up
    add_column :form_elements, :core_path, :string
  end

  def self.down
    remove_column :form_elements, :core_path
  end
end
