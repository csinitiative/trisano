class RemovePrimaryKeyFromPeopleRaces < ActiveRecord::Migration
  def self.up
    remove_column :people_races, :id
    remove_column :people, :race_id
  end

  def self.down
    add_column :people_races, :id, :integer
    add_column :people, :race_id, :integer
  end
end
