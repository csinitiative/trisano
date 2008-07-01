class AddLocationTypeToEntitiesLocations < ActiveRecord::Migration
  def self.up
    add_column(:entities_locations, :location_type_id, :integer)
  end

  def self.down
    remove_column(:entities_locations, :location_type_id)
  end
end
