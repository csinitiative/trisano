class DisplayCodesForCsv < ActiveRecord::Migration
  def self.up
    add_column  :csv_fields, :use_code,        :string
    add_column  :csv_fields, :use_description, :string
    add_column  :csv_fields, :export_group,    :string
    add_column  :csv_fields, :updated_at,      :timestamp
    add_column  :csv_fields, :created_at,      :timestamp
    remove_column :csv_fields, :short_name_max
    remove_column :csv_fields, :evaluation
    remove_column :csv_fields, :group

    if RAILS_ENV == 'production'
      eval(File.read("#{RAILS_ROOT}/script/load_csv_defaults.rb"))
    end

  end

  def self.down
    remove_column :csv_fields, :use_code
    remove_column :csv_fields, :use_description
    remove_column :csv_fields, :updated_at
    remove_column :csv_fields, :created_at
    remove_column :csv_fields, :export_group
    add_column  :csv_fields, :short_name_max, :integer
    add_column  :csv_fields, :evaluation,     :string
    add_column  :csv_fields, :group,          :string
  end
end
