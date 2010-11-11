class CreateDiseaseSpecificTreatments < ActiveRecord::Migration
  def self.up
    transaction do
      create_table :disease_specific_treatments do |t|
        t.integer :disease_id,   :null => false
        t.integer :treatment_id, :null => false

        t.timestamps
      end
      add_index :disease_specific_treatments, [:disease_id, :treatment_id], :unique => true, :name => :diseases_and_treatments_unique
    end
  end

  def self.down
    transaction do
      remove_index :disease_specific_treatments, :name => :diseases_and_treatments_unique
      drop_table :disease_specific_treatments
    end
  end
end
