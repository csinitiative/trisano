class AlterPhoneTable < ActiveRecord::Migration
  def self.up
    change_column :telephones, :country_code, :string, :limit => 3
    change_column :telephones, :area_code, :string, :limit => 3
    change_column :telephones, :extension, :string, :limit => 6
    change_column :telephones, :phone_number, :string, :limit => 7
    remove_column :telephones, :exchange
  end
  
  def self.down
    change_column :telephones, :country_code, :integer
    change_column :telephones, :area_code, :integer
    change_column :telephones, :extension, :integer
    change_column :telephones, :phone_number, :integer
    add_column :telephones, :exchange, :integer
  end
end
