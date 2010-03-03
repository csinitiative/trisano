class FixParticipations < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      execute("DELETE FROM participations WHERE secondary_entity_id IS NULL AND (type != 'InterestedParty' AND type != 'InterestedPlace')")
    end
  end

  def self.down
  end
end
