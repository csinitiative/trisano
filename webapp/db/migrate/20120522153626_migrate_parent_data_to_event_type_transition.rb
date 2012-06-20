class MigrateParentDataToEventTypeTransition < ActiveRecord::Migration
  def self.up
    EventTypeTransition.transaction do
      promoted_morbidity_events = Event.find(:all, :conditions => ["parent_id IS NOT NULL AND type = ?", "morbidity_event"])
      promoted_morbidity_events.each do |event|
        # Prior to EventTypeTransition, the only transition was ContactEvent > MorbidityEvent
        ett = EventTypeTransition.new(:event_id => event.id, :was => ContactEvent, :became => MorbidityEvent, :created_at => event.created_at)
        ett.save!
      end

      raise "Not all event transitions migrated" if promoted_morbidity_events.count != EventTypeTransition.count
    end
  end

  def self.down
    EventTypeTransition.destroy_all
  end
end
