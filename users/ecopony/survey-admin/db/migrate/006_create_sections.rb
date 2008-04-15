class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :name
      t.integer :form_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
