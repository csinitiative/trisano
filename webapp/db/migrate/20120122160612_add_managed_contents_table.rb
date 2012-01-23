class AddManagedContentsTable < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :managed_contents do |t|
      t.string :name
      t.string :content
      t.timestamps
    end

    ManagedContents.create :name => 'footer', :content => ''

  end

  def self.down
    drop_table :managed_content
  end
end
