class InitLabs < ActiveRecord::Migration
  def self.up
#
# This migration adds the laboratory and test results capability to Release 1 Iteration 1. Disease plans
# and LIMS integration will add additional tables and columns to flesh out
# the data model.
#
    create_table  :laboratories do |t|
      t.integer	  :entity_id
      t.string	  :laboratory_name, :limit => 50

      t.timestamps
    end

  execute "ALTER TABLE laboratories
		ADD CONSTRAINT  fk_EntityId 
		FOREIGN KEY (entity_id) 
		REFERENCES entities(id)"

    create_table :lab_results do |t|
      t.integer    :event_id
      t.integer    :specimen_source_id
      t.timestamp  :collection_date
      t.timestamp  :lab_test_date
      t.integer	   :tested_at_uphl_yn_id
      t.string	   :lab_result_text, :limit => 20
    end

    execute "ALTER TABLE lab_results
		ADD CONSTRAINT  fk_EventId 
		FOREIGN KEY (event_id) 
		REFERENCES events(id)"
	
    execute "ALTER TABLE lab_results
		ADD CONSTRAINT  fk_SpecimenSourceId 
		FOREIGN KEY (specimen_source_id) 
		REFERENCES codes(id)"

    execute "ALTER TABLE lab_results
		ADD CONSTRAINT  fk_TestedAtUphlYnId
		FOREIGN KEY (tested_at_uphl_yn_id) 
		REFERENCES codes(id)"
  end	

  def self.down
    drop_table :laboratories
    drop_table :lab_results
  end
end
