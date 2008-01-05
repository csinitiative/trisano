class MoveDiseaseToRelationship < ActiveRecord::Migration
  def self.up
    rename_column(:cmrs, :disease, :disease_id) 
    change_column(:cmrs, :disease_id, :integer)
  end

  def self.down
  end
end
