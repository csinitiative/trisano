class AddNameColumnToPlacesTable < ActiveRecord::Migration
  def self.up
    add_column :places, :name, :string
  end
  
  def self.down
    remove_column :places, :name
  end
end
