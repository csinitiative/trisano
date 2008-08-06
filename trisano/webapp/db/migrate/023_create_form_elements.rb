class CreateFormElements < ActiveRecord::Migration
  def self.up
    create_table :form_elements do |t|
      t.integer :form_id
      t.string :type
      t.string :name
      t.string :description
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt

      t.timestamps
    end
  end

  def self.down
    drop_table :form_elements
  end
end
