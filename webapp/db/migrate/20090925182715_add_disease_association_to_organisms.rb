class AddDiseaseAssociationToOrganisms < ActiveRecord::Migration
  def self.up
    add_column :organisms, :disease_id, :integer
    add_index  :organisms, :disease_id
  end

  def self.down
    remove_index  :organisms, :disease_id
    remove_column :organisms, :disease_id
  end
end
