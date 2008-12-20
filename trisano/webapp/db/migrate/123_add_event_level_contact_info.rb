# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

require "migration_helpers"

class AddEventLevelContactInfo < ActiveRecord::Migration

  def self.up
    transaction do
      create_table :participations_contacts do |t|
        t.integer :disposition_id
        t.integer :contact_type_id
        t.timestamps
      end

      add_column :participations, :participations_contact_id, :integer
      remove_column :people, :disposition_id

      if RAILS_ENV == "production"
        contact_types = YAML::load_file "#{RAILS_ROOT}/db/defaults/contact_types.yml"
        contact_types.each do |contact_type|
          ExternalCode.create(:code_name => contact_type['code_name'], 
                              :the_code => contact_type['the_code'], 
                              :code_description => contact_type['code_description'], 
                              :sort_order => contact_type['sort_order'], 
                              :live => true)
        end
      end
    end
  end

  def self.down
    transaction do
      drop_table :participations_contacts
      remove_column :participations, :participations_contact_id
      add_column :people, :disposition_id, :integer
    end
  end
end
