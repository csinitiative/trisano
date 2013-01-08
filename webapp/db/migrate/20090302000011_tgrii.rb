# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

class Tgrii < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    ActiveRecord::Base.transaction do

      # IMPORTANT NOTE: In almost all cases we want to use straight SQL as opposed to active record, because by
      # the time this code is run the model code is way out of sync with the way the database looks, and many
      # active record associations and events will not work.

      ##############################################################################################################################################
      #                                                 Handle unused participation types: contacts and place
      #
      add_column :events, :participations_contact_id, :integer
      add_column :events, :participations_place_id, :integer

      remove_column :participations, :participations_contact_id
      remove_column :participations, :participations_place_id
      remove_column :participations, :participating_event_id

      ##############################################################################################################################################
      #                                                 Make participations an STI-enabled table.
      #
      add_column :participations, :type, :string
      remove_column :participations, :role_id


      ##############################################################################################################################################
      #                                               Move telephones and emails around 
      #

      say "Updating telephones and email addresses"

      create_table :email_addresses do |t|
        t.string  :email_address
        t.integer :entity_id
        t.timestamps
      end

      add_column :telephones, :entity_id, :integer
      add_column :telephones, :entity_location_type_id, :integer

      ##############################################################################################################################################
      #                                                        Move addresses around 
      #

      say "Updating physical addresses"

      add_column :addresses, :entity_id, :integer
      add_column :addresses, :entity_location_type_id, :integer

      ##############################################################################################################################################
      #                                                              Cleaning up
      #

      say "Cleaning up tables and indexes"

      # Remove tables we no longer need
      execute("DROP TABLE entities_locations CASCADE")
      execute("DROP TABLE locations CASCADE")

      # Get rid of codes we don't need anymore
      execute("DELETE FROM codes WHERE code_name = 'participant'")
      execute("DELETE FROM codes WHERE code_name = 'locationtype'")

      # Add an index to all the 'type' fields used for STI
      add_index :events, :type
      add_index :participations, :type
      add_index :entities, :entity_type

      # Create foreign keys to link telephones and addresses to entities
      add_foreign_key :telephones, :entity_id, :entities
      add_foreign_key :addresses, :entity_id, :entities

      # Add indexes for our foreign keys
      add_index :telephones, :entity_id
      add_index :addresses, :entity_id

      # While we're at it let's get rid of all still-unused tables
      execute("DROP TABLE animals CASCADE")
      execute("DROP TABLE clinicals CASCADE")
      execute("DROP TABLE clusters CASCADE")
      execute("DROP TABLE entity_groups CASCADE")
      execute("DROP TABLE export_predicates CASCADE")
      execute("DROP TABLE materials CASCADE")
      execute("DROP TABLE observations CASCADE")
      execute("DROP TABLE referrals CASCADE")

    end
  end

  def self.down
  end
end
