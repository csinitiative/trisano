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

class AddTaskAssignmentPrivileges < ActiveRecord::Migration
  def self.up
    if RAILS_ENV =~ /production/
      transaction do

        say "Adding new assign-task privilege"
        unless Privilege.find_by_priv_name('assign_task_to_user')
          Privilege.create({ :priv_name => 'assign_task_to_user' })
        end

        assign_task_priv = Privilege.find_by_priv_name('assign_task_to_user')
        raise "Failed to find the assign-task privilege" if assign_task_priv.nil?

        say "Associating the new privilege with the managerial roles"
        managerial_roles = Role.find(
          :all,
          :conditions => ["role_name = ? OR role_name = ? OR role_name = ?", "State Manager", "LHD Manager", "Surveillance Manager"]
        )
        raise "Did not find the expected three managerial roles" if managerial_roles.size != 3

        managerial_roles.each do |role|
          PrivilegesRole.create({ :role => role, :privilege =>  assign_task_priv })
        end

        say "Adding entitlement to assign tasks to users with managerial roles, in every jurisdiction in which they are a manager"
        managerial_role_ids = managerial_roles.collect { |role| role.id }
        
        User.find(:all).each do |user|

          jurisdictions_handled = []

          user.role_memberships.each do |rm|
            if ( (managerial_role_ids.include?(rm.role.id)) && (!jurisdictions_handled.include?(rm.jurisdiction.id)) )
              Entitlement.create({ :user => user, :privilege => assign_task_priv, :jurisdiction_id => rm.jurisdiction.id })
              jurisdictions_handled << rm.jurisdiction.id
            end
          end
        end

      end
    end
  end

  def self.down
  end
end
