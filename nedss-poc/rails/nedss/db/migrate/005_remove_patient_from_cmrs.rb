class RemovePatientFromCmrs < ActiveRecord::Migration
  def self.up
    remove_column :cmrs, :last_name 
    remove_column :cmrs, :first_name 
    remove_column :cmrs, :date_of_birth 
    remove_column :cmrs, :age 
    remove_column :cmrs, :street_address 
    remove_column :cmrs, :city 
    remove_column :cmrs, :state 
    remove_column :cmrs, :zip_code 
    remove_column :cmrs, :country
    remove_column :cmrs, :county
    remove_column :cmrs, :phone_number
    remove_column :cmrs, :gender
    remove_column :cmrs, :race
    remove_column :cmrs, :ethnicity
  end

  def self.down
  end
end
