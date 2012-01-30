class DbFilesByteaToText < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    change_column :db_files, :data, :text
  end

  def self.down
    change_column :db_files, :data, :binary
  end
end
