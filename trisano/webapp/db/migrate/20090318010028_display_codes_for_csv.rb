class DisplayCodesForCsv < ActiveRecord::Migration
  def self.up
    add_column  :csv_fields, :code_field, :boolean
    add_column  :csv_fields, :updated_at, :timestamp
    add_column  :csv_fields, :created_at, :timestamp
    remove_column :csv_fields, :short_name_max
  end

  def self.down
    remove_column :csv_fields, :code_field
    remove_column :csv_fields, :updated_at
    remove_column :csv_fields, :created_at
    add_column  :csv_fields, :short_name_max, :integer
  end
end
