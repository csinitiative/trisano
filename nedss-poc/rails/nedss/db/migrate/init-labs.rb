class init-labs.rb < ActiveRecord::Migration
  def self.up
#
# This migration adds the laborator and test results capability to the
# UT-NEDSS database for the CMR in Release 1 Iteration 1. Disease plans
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
      t.string	   :tested_at_UPHL,  :limit => 1
      t.string	   :lab_result_text, :limit => 20
    end

  execute "ALTER TABLE lab_results
		ADD CONSTRAINT  fk_EventId 
		FOREIGN KEY (event_id) 
		REFERENCES event(id)"
	
  execute "ALTER TABLE lab_results
		ADD CONSTRAINT  fk_SpecimenSourceId 
		FOREIGN KEY (specimen_source_id) 
		REFERENCES codes(id)"
	
  def self.down
      drop_table :laboratories
      drop_table :lab_results
  end
end
