class DiseaseSpecificTreatments < ActiveRecord::Migration
  def self.up
    add_column :treatments, :default, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :treatments, :default
  end
end
