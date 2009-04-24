class AssociateAddressesWithEvents < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :addresses, :event_id, :integer
    add_foreign_key :addresses, :event_id, :events
    add_index :addresses, :event_id

    if RAILS_ENV == 'production'
      eval(File.read("#{RAILS_ROOT}/script/associate_addresses_to_events.rb"))
    end

  end

  def self.down
    remove_foreign_key :addresses, :event_id
    remove_column :addresses, :event_id
  end
end
