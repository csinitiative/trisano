class AddAttachmentTextField < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :db_files, :data_text, :text
  end

  def self.down
    remove_column :db_files, :data_text, :binary
  end
end
