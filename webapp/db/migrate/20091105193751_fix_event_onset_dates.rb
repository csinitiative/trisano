class FixEventOnsetDates < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      proc = Proc.new { |events| events.each{ |e| e.send(:set_onset_date); e.save(false) } }
      Event.transaction do
        MorbidityEvent.find_in_batches({ :batch_size => 500 }, &proc)
        ContactEvent.find_in_batches(  { :batch_size => 500 }, &proc)
      end
    end
  end

  def self.down
    if RAILS_ENV == 'production'
      Event.transaction do
        MorbidityEvent.update_all 'event_onset_date = created_at'
        ContactEvent.update_all 'event_onset_date = created_at'
      end
    end
  end
end
