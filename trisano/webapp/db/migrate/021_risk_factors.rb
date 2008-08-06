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
