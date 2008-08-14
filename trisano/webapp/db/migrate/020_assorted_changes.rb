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
