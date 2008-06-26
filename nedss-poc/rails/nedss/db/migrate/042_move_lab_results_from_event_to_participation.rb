class MoveLabResultsFromEventToParticipation < ActiveRecord::Migration

  def self.up 
    remove_column :lab_results, :event_id 
    add_column    :lab_results, :participation_id, :integer

    execute "ALTER TABLE lab_results
             ADD CONSTRAINT fk_participation FOREIGN KEY (participation_id) REFERENCES participations(id)" 
  end

  def self.down
    execute "ALTER TABLE lab_results
             DROP CONSTRAINT fk_participation" 

    remove_column :lab_results, :participation_id 
    add_column    :lab_results, :event_id, :integer

    execute "ALTER TABLE lab_results
             ADD CONSTRAINT fk_event FOREIGN KEY (event_id) REFERENCES events(id)" 
  end

end 
