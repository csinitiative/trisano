class UniqueEventQueueNames < ActiveRecord::Migration
  def self.up
    execute "CREATE UNIQUE INDEX by_queue_name_and_jurisdiction ON event_queues(lower(queue_name), jurisdiction_id)"
  end

  def self.down
    remove_index :event_queues, :name => "by_queue_name_and_jurisdiction"
  end
end
