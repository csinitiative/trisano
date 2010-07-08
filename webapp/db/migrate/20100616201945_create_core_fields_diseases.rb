class CreateCoreFieldsDiseases < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :core_fields_diseases do |t|
      t.integer :core_field_id, :null => false
      t.integer :disease_id, :null => false
      t.boolean :rendered, :default => true
      t.timestamps
    end
    add_foreign_key :core_fields_diseases, :core_field_id, :core_fields
    add_foreign_key :core_fields_diseases, :disease_id, :diseases
    add_index :core_fields_diseases, [:disease_id, :core_field_id], :unique => true
  end

  def self.down
    drop_table :core_fields_diseases
  end
end
