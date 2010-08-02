class DiseaseSpecificSelections < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    transaction do
      create_table :disease_specific_selections do |t|
        t.integer :disease_id, :null => false
        t.integer :external_code_id, :null => false
        t.boolean :rendered, :null => false
        t.timestamps
      end
      add_foreign_key :disease_specific_selections, :disease_id, :diseases
      add_foreign_key :disease_specific_selections, :external_code_id, :external_codes

      add_column :external_codes, :disease_specific, :boolean
    end
  end

  def self.down
    transaction do
      drop_table :disease_specific_selections
      remove_column :external_codes, :disease_specific
    end
  end
end
