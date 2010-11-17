class DiseaseSpecificTreatments < ActiveRecord::Migration
  def self.up
    transaction do
      execute "ALTER TABLE treatments ADD COLUMN \"default\" boolean;"
      execute "ALTER TABLE treatments ALTER COLUMN \"default\" SET DEFAULT false;"
      execute "UPDATE treatments SET \"default\" = false;"
      execute "ALTER TABLE treatments ALTER COLUMN \"default\" SET NOT NULL;"
    end
  end

  def self.down
    remove_column :treatments, :default
  end
end
