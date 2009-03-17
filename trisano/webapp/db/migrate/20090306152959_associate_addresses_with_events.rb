class AssociateAddressesWithEvents < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :addresses, :event_id, :integer
    add_foreign_key :addresses, :event_id, :events
  end

  def self.down
    remove_foreign_key :addresses, :event_id
    remove_column :addresses, :event_id
  end
end
