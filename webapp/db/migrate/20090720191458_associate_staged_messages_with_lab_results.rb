class AssociateStagedMessagesWithLabResults < ActiveRecord::Migration

  def self.up
    add_column :lab_results, :staged_message_id, :integer
    remove_column :staged_messages, :event_id
    add_index :lab_results, :staged_message_id, :name => "lab_results_staged_message"
  end

  def self.down
    remove_index :lab_results, :name => "lab_results_staged_message"
    remove_column :lab_results, :staged_message_id
    add_column :staged_messages, :event_id, :integer
  end
end
