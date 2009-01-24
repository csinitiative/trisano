# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

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
