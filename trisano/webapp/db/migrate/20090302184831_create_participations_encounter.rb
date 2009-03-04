class CreateParticipationsEncounter < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up

    create_table :participations_encounters do |t|
      t.integer :user_id
      t.date :encounter_date
      t.text :description
      t.string :encounter_location_type, :limit => 40

      t.timestamps
    end

    add_column :events, :participations_encounter_id, :integer
    add_foreign_key :participations_encounters, :user_id, :users
    add_foreign_key :events, :participations_encounter_id, :participations_encounters
    
  end

  def self.down
    remove_column  :events, :participations_place_id
    remove_foreign_key :participations_encounters, :user_id
    remove_foreign_key :events, :participations_encounter_id
    drop_table :participations_encounters
  end
end
