class DefaultLocales < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    transaction do
      create_table :default_locales do |t|
        t.string  :short_name, :null => false
        t.integer :user_id
        t.timestamps
      end
      add_foreign_key :default_locales, :user_id, :users
    end
  end

  def self.down
    drop_table :default_locales
  end
end
