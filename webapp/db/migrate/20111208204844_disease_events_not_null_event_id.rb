class DiseaseEventsNotNullEventId < ActiveRecord::Migration
  def self.up
    # this delete is safe because these records are useless anyway
    execute 'DELETE FROM disease_events WHERE event_id IS NULL'
    change_column :disease_events, :event_id, :int, :null => false
  end

  def self.down
    change_column :disease_events, :event_id, :int, :null => true
  end
end
