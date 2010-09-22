class AddHl7MessageToMessageBatches < ActiveRecord::Migration
  def self.up
    add_column :message_batches, :hl7_message, :string,
      :limit => 10485760, :null => false, :default => ''
  end

  def self.down
    remove_column :message_batches, :hl7_message
  end
end
