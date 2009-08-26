class AddConstraintToAddresses < ActiveRecord::Migration
  def self.up
    execute("CREATE UNIQUE INDEX address_event_entity_unique_ix ON addresses (event_id, entity_id);")
  end

  def self.down
    execute("DROP INDEX address_event_entity_unique_ix;")
  end
end
