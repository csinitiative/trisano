class RenameTreatmentToTreatmentName < ActiveRecord::Migration
  def self.up
    rename_column :participations_treatments, :treatment, :treatment_name
  end

  def self.down
    rename_column :participations_treatments, :treatment_name, :treatment
  end
end
