class CreateDiseases < ActiveRecord::Migration
  def self.up
    create_table :diseases do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :diseases
  end
end
