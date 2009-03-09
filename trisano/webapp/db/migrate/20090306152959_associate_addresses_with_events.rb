class AssociateAddressesWithEvents < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :addresses_temp, :event_id, :integer
    add_foreign_key :addresses_temp, :event_id, :events
  end

  def self.down
    remove_foreign_key :addresses_temp, :event_id
    remove_column :addresses_temp, :event_id
  end
end
