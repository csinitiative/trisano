class InitializeDatabase < ActiveRecord::Migration
  def self.up
    create_table :codes do |t|
      t.string :code_name, :limit => 50
      t.string :the_code, :limit => 20
      t.string :code_description, :limit => 100
    end
    
    create_table :entities do |t|
      t.string :record_number, :limit => 20
      t.string :entity_url_number, :limit => 200
      
      t.timestamps
    end
    
    create_table :organizations do |t|
      t.integer   :entity_id
      t.integer   :organization_type_id
      t.integer   :organization_status_id
      t.string    :organization_name, :limit => 50
      t.timestamp :duration_start_date
      t.timestamp :duration_end_date
      
      t.timestamps
    end
    
    create_table :people do |t|
      t.integer   :entity_id
      t.integer   :race_id
      t.integer   :birth_gender_id
      t.integer   :current_gender_id
      t.integer   :ethnicity_id
      t.integer   :primary_language_id
      t.string    :first_name, :limit => 25
      t.string    :middle_name, :limit => 25
      t.string    :last_name, :limit => 25
      t.date      :birth_date
      t.date      :date_of_death
      
      t.timestamps
    end
    
    create_table :materials do |t|
      t.integer :entity_id
      
      t.timestamps
    end
    
    create_table :places do |t|
      t.integer :entity_id
      
      t.timestamps
    end
    
    create_table :animals do |t|
      t.integer :entity_id
      
      t.timestamps
    end
    
    create_table :entity_groups do |t|
      t.integer :entity_group_type_id
      t.integer :primary_entity_id
      t.integer :secondary_entity_id
      t.string  :entity_group_name, :limit => 50
      
      t.timestamps
    end
    
    create_table :locations do |t|
      t.string :location_url_number, :limit => 200
    end
    
    create_table :entities_locations do |t|
      t.integer   :location_id
      t.integer   :entity_id
      t.integer   :entity_location_type_id
      t.integer   :primary_yn_id
      t.string    :comment, :limit => 500
      
      t.timestamps
    end
    
    create_table :telephones do |t|
      t.integer :location_id
      t.integer :country_code
      t.integer :area_code
      t.integer :exchange
      t.integer :phone_number
      t.integer :extension
      
      t.timestamps
    end
    
    create_table :addresses do |t|
      t.integer :location_id
      t.integer :city_id
      t.integer :county_id
      t.integer :district_id
      t.integer :state_id
      t.string  :street_number, :limit => 10
      t.string  :street_name, :limit => 50
      t.string  :unit_number, :limit => 10
      t.string  :postal_code, :limit => 10
      
      t.timestamps
    end
    
    create_table :events do |t|
      t.integer :event_type_id
      t.integer :event_status_id
      t.integer :imported_from_id
      t.integer :event_case_status_id
      t.string  :event_name, :limit => 100
      t.date    :event_onset_date
      
      t.timestamps
    end
    
    create_table :participations do |t|
      t.integer :primary_event_id
      t.integer :secondary_event_id
      t.integer :role_id
      t.integer :participation_status_id
      t.string  :comment, :limit => 500
      
      t.timestamps
    end
    
    create_table :treatments do |t|
      t.integer :treatment_type_id
      t.string  :treatment_name, :limit => 100
    end
    
    create_table :participations_treatments do |t|
      t.integer :participation_id
      t.integer :treatment_id
      t.integer :treatment_given_yn_id
      t.date    :treatment_date
      
      t.timestamps
    end
    
    create_table :participation_hospitals do |t|
      t.integer :participation_id
      t.string  :hospital_record_number, :limit => 100
      t.date    :admission_date
      t.date    :discharge_date
      
      t.timestamps
    end
    
    create_table :encounters do |t|
      t.integer :event_id
      
      t.timestamps
    end
    
    create_table :observations do |t|
      t.integer :event_id
      
      t.timestamps
    end
    
    create_table :referrals do |t|
      t.integer :event_id
      
      t.timestamps
    end
    
    create_table :event_cases do |t|
      t.integer :event_id
      
      t.timestamps
    end
    
    create_table :clinicals do |t|
      t.integer :event_id
      t.integer :test_public_health_lab_id
      
      t.timestamps
    end
    
    create_table :diseases do |t|
      t.string :disease_name, :limit => 50
    end
    
    create_table :disease_events do |t|
      t.integer :event_id
      t.integer :disease_id
      t.integer :hospitalized_id
      t.integer :died_id
      t.integer :pregnant_id
      t.date    :disease_onset_date
      t.date    :date_diagnosed
      t.date    :pregnancy_due_date
      
      t.timestamps
    end
    
    create_table :clusters do |t|
      t.integer :primary_event_id
      t.integer :secondary_event_id
      t.integer :cluster_status_id
      t.string  :comment, :limit => 500
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :addresses
    drop_table :animals
    drop_table :clinicals
    drop_table :clusters
    drop_table :codes
    drop_table :diseases
    drop_table :encounters
    drop_table :entities
    drop_table :entity_groups
    drop_table :entities_locations
    drop_table :event_cases
    drop_table :disease_events
    drop_table :events
    drop_table :locations
    drop_table :materials
    drop_table :observations
    drop_table :organizations
    drop_table :participation_hospitals
    drop_table :participations
    drop_table :participations_treatments
    drop_table :people
    drop_table :places
    drop_table :referrals
    drop_table :telephones
    drop_table :treatments
  end
end
