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

class CreateUnassignedJurisdiction < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == "production"
      transaction do
        # Unassigned jurisdiction was never created.
        execute("INSERT INTO entities (entity_type) VALUES ('place')")
        e_id = execute("SELECT currval('entities_id_seq')")
        p_id = execute("SELECT id FROM codes WHERE code_name = 'placetype' AND the_code = 'J'")

        execute("INSERT INTO places (name, short_name, entity_id, place_type_id, created_at, updated_at) VALUES ('Unassigned', 'Unassigned', #{e_id.result[0][0]}, #{p_id.result[0][0]}, '#{Date.today.to_s}', '#{Date.today.to_s}')")

        # Need to give all users, all entitlements, as there's no good way to know what we really need.
        users = execute("SELECT id FROM users")
        privs = execute("SELECT id FROM privileges")
        jurisdictions = execute("SELECT entity_id FROM places WHERE place_type_id IN (SELECT id FROM codes WHERE code_name = 'placetype' AND the_code = 'J')")

        users.result.each do |user|
          jurisdictions.result.each do |juri|
            privs.result.each do |priv|
              execute("INSERT INTO entitlements (user_id, jurisdiction_id, privilege_id) VALUES (#{user[0]}, #{juri[0]}, #{priv[0]})") 
            end
          end
        end

      end
    end
  end

  def self.down
  end
end
