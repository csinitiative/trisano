class AddTreatmentToParticipationsTreatments < ActiveRecord::Migration
  def self.up
    add_column :participations_treatments, :treatment, :string
  end
  
  def self.down
    remove_column :participations_treatments, :treatment
  end
end
