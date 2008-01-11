class AddPatientForeignKeys < ActiveRecord::Migration
  def self.up
    add_column :cmrs, :patient_id, :integer
  end

  def self.down
    remove_column :cmrs, :patient_id
  end
end
