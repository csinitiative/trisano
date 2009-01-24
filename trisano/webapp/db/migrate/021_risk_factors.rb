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

class RiskFactors < ActiveRecord::Migration
  def self.up 
    #create the participations_risk_factors table
    create_table :participations_risk_factors do |t|
      t.integer :participation_id
      t.integer :food_handler_id
      t.integer :healthcare_worker_id
      t.integer :group_living_id
      t.integer :day_care_association_id
      t.integer :pregnant_id 
      t.date    :pregnancy_due_date
      t.string  :risk_factors, :limit => 25 
      t.string  :risk_factors_notes, :limit => 100 
      t.timestamps 
    end 

    execute "ALTER TABLE participations_risk_factors
             ADD CONSTRAINT fk_foodhandler FOREIGN KEY (food_handler_id) REFERENCES codes(id)" 

    execute "ALTER TABLE participations_risk_factors
             ADD CONSTRAINT fk_healthcareworker FOREIGN KEY (healthcare_worker_id) REFERENCES codes(id)" 

    execute "ALTER TABLE participations_risk_factors
             ADD CONSTRAINT fk_groupliving FOREIGN KEY (group_living_id) REFERENCES codes(id)" 

    execute "ALTER TABLE participations_risk_factors
             ADD CONSTRAINT fk_daycareassoc FOREIGN KEY (day_care_association_id) REFERENCES codes(id)" 

    execute "ALTER TABLE participations_risk_factors
             ADD CONSTRAINT fk_pregnant FOREIGN KEY (pregnant_id) REFERENCES codes(id)" 

    execute "ALTER TABLE participations_risk_factors
             ADD CONSTRAINT fk_participation FOREIGN KEY (participation_id) REFERENCES participations(id)" 

    #execute "ALTER TABLE people DROP CONSTRAINT fk_foodhandler" 
    #execute "ALTER TABLE people DROP CONSTRAINT fk_healthcare" 
    #execute "ALTER TABLE people DROP CONSTRAINT fk_groupliving" 
    #execute "ALTER TABLE people DROP CONSTRAINT fk_daycareassoc" 
    #execute "ALTER TABLE people DROP CONSTRAINT fk_pregnant"

    remove_column :disease_events, :pregnancy_due_date 
    remove_column :disease_events, :pregnant_id 
    remove_column :people, :healthcare_worker_id 
    remove_column :people, :group_living_id 
    remove_column :people, :day_care_association_id 
    remove_column :people, :risk_factors 
    remove_column :people, :risk_factors_notes
  end 
    
  def self.down 
    execute "ALTER TABLE participations_risk_factors drop CONSTRAINT fk_foodhandler" 
    execute "ALTER TABLE participations_risk_factors drop CONSTRAINT fk_healthcareworker" 
    execute "ALTER TABLE participations_risk_factors drop CONSTRAINT fk_groupliving" 
    execute "ALTER TABLE participations_risk_factors drop CONSTRAINT fk_daycareassoc" 
    execute "ALTER TABLE participations_risk_factors drop CONSTRAINT fk_pregnant" 
    execute "ALTER TABLE participations_risk_factors drop CONSTRAINT fk_participation" 

    drop_table :participations_risk_factors

    add_column :disease_events, :pregnancy_due_date, :date 
    add_column :disease_events, :pregnant_id, :integer 
    add_column :people, :food_handler_id, :integer 
    add_column :people, :healthcare_worker_id, :integer 
    add_column :people, :group_living_id, :integer 
    add_column :people, :day_care_association_id, :integer 
    add_column :people, :risk_factors, :string, :limit => 25 
    add_column :people, :risk_factors_notes, :string, :limit => 100

    # execute "ALTER TABLE people ADD CONSTRAINT fk_foodhandler FOREIGN KEY (food_handler_id) REFERENCES codes(id)" 
    # execute "ALTER TABLE people ADD CONSTRAINT fk_healthcare FOREIGN KEY (healthcare_worker_id) REFERENCES codes(id)" 
    # execute "ALTER TABLE people ADD CONSTRAINT fk_groupliving FOREIGN KEY (group_living_id) REFERENCES codes(id)" 
    # execute "ALTER TABLE people ADD CONSTRAINT fk_daycareassoc FOREIGN KEY (day_care_association_id) REFERENCES codes(id)" 
    # execute "ALTER TABLE diseases_events ADD CONSTRAINT fk_pregnant FOREIGN KEY (pregnant_id) REFERENCES codes(id)"
  end 
end
