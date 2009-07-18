class AddStopTreatmentDate < ActiveRecord::Migration
  def self.up
    add_column :participations_treatments, :stop_treatment_date, :date
  end

  def self.down
    remove_column :participations_treatments, :stop_treatment_date
  end
end
