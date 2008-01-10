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
    add_column :cmrs, :last_name, :string, :limit => 40
    add_column :cmrs, :first_name, :string, :limit => 40 
    add_column :cmrs, :date_of_birth, :date
    add_column :cmrs, :age, :integer, :limit => 4
    add_column :cmrs, :street_address, :string, :limit => 100 
    add_column :cmrs, :city, :string, :limit => 40 
    add_column :cmrs, :state, :string, :limit => 2 
    add_column :cmrs, :zip_code, :string, :limit => 5 
    add_column :cmrs, :country, :string, :limit => 40
    add_column :cmrs, :county, :string, :limit => 40
    add_column :cmrs, :phone_number, :string, :limit => 20
    add_column :cmrs, :gender, :string, :limit => 1
    add_column :cmrs, :race, :string, :limit => 20
    add_column :cmrs, :ethnicity, :string, :limit => 20
  end
end
