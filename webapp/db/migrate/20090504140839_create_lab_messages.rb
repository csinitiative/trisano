class CreateLabMessages < ActiveRecord::Migration
  def self.up
    create_table :staged_messages do |t|
      t.string :hl7_message, :limit => 10485760, :null => false
      t.string :state, :null => false
      t.string :message_tpye
      t.text :error_detail
      t.text :note
      t.timestamps
    end
  end

  def self.down
    drop_table :staged_messages
  end
end
