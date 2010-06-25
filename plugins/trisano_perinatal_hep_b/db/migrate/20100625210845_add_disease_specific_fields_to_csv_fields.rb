class AddDiseaseSpecificFieldsToCsvFields < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    add_column(:csv_fields, :disease_specific, :boolean, :default => false)
    add_column(:csv_fields, :core_field_id, :integer)
    add_foreign_key(:csv_fields, :core_field_id, :core_fields)
  end

  def self.down
    remove_foreign_key(:csv_fields, :core_field_id)
    remove_column(:csv_fields, :disease_specific)
    remove_column(:csv_fields, :core_field_id)
  end
end
