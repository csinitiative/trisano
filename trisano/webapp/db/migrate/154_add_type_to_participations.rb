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

class AddTypeToParticipations < ActiveRecord::Migration

  def self.up
    ActiveRecord::Base.transaction do
      add_column :participations, :type, :string

      create_table :telephones_temp do |t|
        t.string  :country_code, :limit => 3
        t.string  :area_code, :limit => 3
        t.string  :extension, :limit => 6
        t.string  :phone_number, :limit => 7
        t.integer :entity_id
        t.integer :entity_location_type_id

        t.timestamps
      end

      create_table :addresses_temp do |t|
        t.string  :street_number, :limit => 10
        t.string  :street_name, :limit => 50
        t.string  :unit_number, :limit => 10
        t.string  :postal_code, :limit => 10
        t.string  :city, :limit => 255
        t.integer :county_id
        t.integer :state_id
        t.integer :entity_id
        t.integer :entity_location_type_id

        t.timestamps
      end

      create_table :email_addresses do |t|
        t.string  :email_address
        t.integer :entity_id

        t.timestamps
      end

      add_column :events, :participations_contact_id, :integer
      add_column :events, :participations_place_id, :integer
      remove_column :participations, :participations_contact_id
      remove_column :participations, :participations_place_id
      remove_column :participations, :participating_event_id

      ### REMOVE ROLE_ID COLUMN ###
      ### ADD DATA MIGRATION TO ASSIGN ALL EXISTING PARTICIPATIONS THE CORRECT TYPE ###
      ### ADD DATA MIGRATION TO ASSIGN ALL EXISTING ENTITIES THE CORRECT TYPE (ie. change place to place_entity etc.) ###
      ### Move telephones around adjust indexes
      ### Move addresses around adjust indexes
      ### Add data migration to associate particpations_contact with event.
      #
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :participations, :type
    end
  end
end
