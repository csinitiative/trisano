class CreateLabMessages < ActiveRecord::Migration
  def self.up
    create_table :lab_messages do |t|
      t.string :hl7_message, :limit => 10485760, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :lab_messages
  end
end
