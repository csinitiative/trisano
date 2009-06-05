class LabMessagesToStagedMessages < ActiveRecord::Migration
  def self.up
    # Though the lab_messages table is already in production, the ELR functionality is not baked.
    # Therefore, this table should be unused and safe to trash.
    drop_table :lab_messages

    create_table :staged_messages do |t|
      t.string :hl7_message, :limit => 10485760, :null => false
      t.string :state, :null => false
      t.string :message_type
      t.text :note
      t.timestamps
    end
  end

  def self.down
    drop_table :staged_messages

    create_table :lab_messages do |t|
      t.string :hl7_message, :limit => 10485760, :null => false
      t.timestamps
    end
  end
end
