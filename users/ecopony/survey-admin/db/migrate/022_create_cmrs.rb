class CreateCmrs < ActiveRecord::Migration
  def self.up
    create_table :cmrs do |t|
      t.string :name
      t.integer :disease_id
      t.integer :jurisdiction_id

      t.timestamps
    end
  end

  def self.down
    drop_table :cmrs
  end
end
