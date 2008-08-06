class AddMedicalRecordNumToHospitalsParticipations < ActiveRecord::Migration
  def self.up
    add_column :hospitals_participations, :medical_record_number, :string
  end

  def self.down
    remove_column :hospitals_participations, :medical_record_number
  end
end
