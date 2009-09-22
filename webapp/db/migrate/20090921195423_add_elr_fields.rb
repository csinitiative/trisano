class AddElrFields < ActiveRecord::Migration
  def self.up
    add_column :staged_messages, :patient_last_name,  :string
    add_column :staged_messages, :patient_first_name, :string
    add_column :staged_messages, :laboratory_name,    :string
    add_column :staged_messages, :collection_date,    :date
    create_table :staged_observations do |t|
      t.integer :staged_message_id
      t.string  :test_type
      t.timestamps
    end
    add_index :staged_observations, :staged_message_id
  end

  def self.down
    remove_column :staged_messages, :patient_last_name
    remove_column :staged_messages, :patient_first_name
    remove_column :staged_messages, :laboratory_name
    remove_column :staged_messages, :collection_date
    remove_index :staged_observations, :staged_message_id
    drop_table   :staged_observations
  end
end
