class FixUdohDatabase < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == "production"
      transaction do
        execute("UPDATE participations SET secondary_entity_id = 69 WHERE id = 1044")
      end
    end
  end

  def self.down
  end
end
