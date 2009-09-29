class AddOrganisms < ActiveRecord::Migration
  def self.up
    create_table :organisms do |t|
      t.column :organism_name, :string, :limit => 255, :null => false
      t.column :snomed_name,   :string
      t.column :snomed_code,   :string, :limit => 50
      t.column :snomed_id,     :string, :limit => 50

      t.timestamps
    end
  end

  def self.down
    drop_table :organisms
  end
end
