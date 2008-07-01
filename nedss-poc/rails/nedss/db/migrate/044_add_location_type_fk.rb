require "migration_helpers"
class AddLocationTypeFk < ActiveRecord::Migration
    extend MigrationHelpers
  def self.up
    add_foreign_key(:entities_locations, :location_type_id, :codes)
  end

  def self.down
    remove_foreign_key(:entities_locations, :location_type_id)
  end
end
