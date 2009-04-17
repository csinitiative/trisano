class FormShortName < ActiveRecord::Migration
  def self.up
    add_column :forms, :short_name, :string
  end

  def self.down
    remove_column :forms, :short_name
  end
end
