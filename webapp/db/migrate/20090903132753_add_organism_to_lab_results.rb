class AddOrganismToLabResults < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :lab_results, :organism_id, :integer

    add_foreign_key :lab_results, :organism_id, :organisms
  end

  def self.down
  end
end
