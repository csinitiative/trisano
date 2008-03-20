class AssortedChanges < ActiveRecord::Migration
  def self.up
    change_column :diseases, :disease_name, :string, :limit => 100
    add_column :codes, :sort_order, :integer
    remove_column :events, :event_type_id
    remove_column :people, :current_gender_id
    remove_column :addresses, :district_id
  end

  def self.down
    change_column :diseases, :disease_name, :string, :limit => 50
    remove_column :codes, :sort_order
    add_column :events, :event_type_id, :integer
    add_column :people, :current_gender, :integer
    add_column :addresses, :district_id, :integer

    execute "ALTER TABLE events
             ADD CONSTRAINT  fk_event_type FOREIGN KEY (event_type_id) REFERENCES codes(id)"
    execute "ALTER TABLE people
             ADD CONSTRAINT  fk_current_gender FOREIGN KEY (current_gender_id) REFERENCES codes(id)"
    execute "ALTER TABLE addresses
             ADD CONSTRAINT  fk_district FOREIGN KEY (district_id) REFERENCES codes(id)"
    execute "ALTER TABLE addresses
             ADD CONSTRAINT  fk_city FOREIGN KEY (city_id) REFERENCES codes(id)"
  end
end
