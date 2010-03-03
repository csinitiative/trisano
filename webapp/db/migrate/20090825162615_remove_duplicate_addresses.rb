class RemoveDuplicateAddresses < ActiveRecord::Migration
  def self.up
    puts 'h1. Address cleanup migration'

    duplicates = ActiveRecord::Base.connection.execute("select event_id, entity_id, count(*) from addresses group by event_id, entity_id having count(*) > 1;")
    duplicates.each do |duplicate|
      puts "h2. Duplicates for #{duplicate["event_id"]}/#{duplicate["entity_id"]}"
      addresses = Address.find_all_by_event_id_and_entity_id(duplicate["event_id"], duplicate["entity_id"])
      puts "Addresses:"
      p  addresses
      puts "Deleting the second address"
      addresses[1].destroy
    end
  end

  def self.down
  end
end
