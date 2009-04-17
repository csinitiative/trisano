class CsvConfigTable < ActiveRecord::Migration
  def self.up
    create_table :csv_fields do |t|
      t.string  :long_name
      t.string  :short_name
      t.integer :short_name_max
      t.string  :evaluation
      t.string  :group
      t.string  :event_type
      t.integer :sort_order
    end      
  end

  def self.down
    drop_table :csv_fields
  end
end
