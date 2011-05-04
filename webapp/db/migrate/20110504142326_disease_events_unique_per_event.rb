class DiseaseEventsUniquePerEvent < ActiveRecord::Migration
  def self.up
    add_index :disease_events, :event_id, :unique => true
  end

  def self.down
    remove_index :disease_events, :event_id
  end
end
