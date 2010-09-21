class CreateMessageBatches < ActiveRecord::Migration
  def self.up
    create_table :message_batches do |t|
      t.references :staged_messages

      t.timestamps
    end

    add_column :staged_messages, :message_batch_id, :integer
  end

  def self.down
    remove_column :staged_messages, :message_batch_id

    drop_table :message_batches
  end
end
