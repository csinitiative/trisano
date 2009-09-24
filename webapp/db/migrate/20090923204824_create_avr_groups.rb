class CreateAvrGroups < ActiveRecord::Migration
  def self.up
    create_table :avr_groups do |t|
      t.string :name

      t.timestamps
    end

    create_table :avr_groups_diseases, :id => false do |t|
      t.integer :avr_group_id
      t.integer :disease_id
      
      t.timestamps
    end

    execute("ALTER TABLE avr_groups_diseases ADD PRIMARY KEY (avr_group_id, disease_id)")
  end

  def self.down
    execute("ALTER TABLE avr_groups_diseases DROP PRIMARY KEY (avr_group_id, disease_id)")

    drop_table :avr_groups
    drop_table :avr_groups_diseases
  end
end

