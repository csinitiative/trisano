class DiseaseSpecificCore < ActiveRecord::Migration
  def self.up
    add_column(:core_fields, :disease_specific, :boolean, :default => false)
  end

  def self.down
    remove_column(:core_fields, :disease_specific)
  end
end
