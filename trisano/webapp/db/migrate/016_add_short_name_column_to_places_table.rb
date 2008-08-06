class AddShortNameColumnToPlacesTable < ActiveRecord::Migration
  def self.up
    add_column :places, :short_name, :string
  end
  
  def self.down
    remove_column :places, :short_name
  end
end
