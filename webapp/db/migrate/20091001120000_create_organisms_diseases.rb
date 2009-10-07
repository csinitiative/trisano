class CreateOrganismsDiseases < ActiveRecord::Migration
  def self.up
    create_table :diseases_organisms do |t|
      t.integer :disease_id,  :null => false
      t.integer :organism_id, :null => false

      t.timestamps
    end
    add_index :diseases_organisms, :disease_id
    add_index :diseases_organisms, :organism_id
  end

  def self.down
    remove_index :diseases_organisms, :disease_id
    remove_index :diseases_organisms, :organism_id
    drop_table :diseases_organisms
  end
end
