class CreateForms < ActiveRecord::Migration
  def self.up
    create_table :forms do |t|
      t.string :name
      t.string :description

      t.integer :disease_id
      t.integer :jurisdiction_id

      t.timestamps
    end
  end

  def self.down
    drop_table :forms
  end
end
