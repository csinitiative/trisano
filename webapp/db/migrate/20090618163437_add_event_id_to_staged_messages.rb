class AddEventIdToStagedMessages < ActiveRecord::Migration
   extend MigrationHelpers

 def self.up
    add_column :staged_messages, :event_id, :integer
    add_foreign_key :staged_messages, :event_id, :events
    add_index :staged_messages, :event_id
 end

  def self.down
    remove_column :staged_messaged, :event_id
  end
end
