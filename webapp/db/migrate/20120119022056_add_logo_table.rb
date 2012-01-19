class AddLogoTable < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :logos do |t|
      t.integer :size
      t.string :content_type
      t.string :filename
      t.integer :height
      t.integer :width
      t.integer :db_file_id

      t.timestamps
    end

    add_foreign_key :logos, :db_file_id, :db_files

  end

  def self.down
    remove_foreign_key :logos, :db_file_id
    drop_table :logos
  end
end
