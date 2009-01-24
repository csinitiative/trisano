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

class MigrateRoleMemberships < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == "production"
      transaction do

        # Delete old role memberships.  This will leave entitlements intact so people can work and admins can admin.
        # But the user admin screen will show "no roles."  When roles are reassigned old entitlements will go away
        # And the new entitlements will be applied.
        execute("DELETE FROM role_memberships")

        # Delete old roles and their privilege mapping
        execute("DELETE FROM privileges_roles")
        execute("DELETE FROM roles")
        
        # Create new roles and privilege mappings
        # Roles are represented as a hash. The keys are role names and the values are arrays of privs
        roles = YAML::load_file "#{RAILS_ROOT}/db/defaults/roles.yml"

        # Note: Technically privileges have associated jurisdictions, we are ignoring that for the time being.
        roles.each_pair do |role_name, privs|
          r = Role.new(:role_name => role_name)
          privs.each do |priv|
            p = Privilege.find_by_priv_name(priv)
            r.privileges_roles.build('privilege_id' => p.id)
          end
          r.save!
        end

      end
    end
  end

  def self.down
  end
end
