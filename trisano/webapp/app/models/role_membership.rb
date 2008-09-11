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

class RoleMembership < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :role
  
  belongs_to :jurisdiction, :class_name => 'Entity', :foreign_key => :jurisdiction_id
  
  after_create :create_entitlements
  after_update :update_entitlements
  before_destroy :remove_entitlements
  
  # Debt? Currently limits to one role per jurisdiction. The scope at one point
  # included role_id as well. The hope in removing it is to eliminate some strange
  # behavior still to be investigated w/regard to updating role memberships.
  validates_uniqueness_of :user_id, :scope => [:role_id, :jurisdiction_id],
    :message => "This role for this jurisdiction is already assigned to this user"

  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def create_entitlements
    privileges_to_add = PrivilegesRole.find_all_by_role_id_and_jurisdiction_id(self.role_id, self.jurisdiction_id)
    
    privileges_to_add.each do |pr|
      # Seems to be as efficient as any other solution to preventing dups
      user.entitlements.find_or_create_by_privilege_id_and_jurisdiction_id(pr.privilege_id, self.jurisdiction_id)
    end
  end
  
  def update_entitlements
    # Debt: Should consider not allowing this, but it works
    # In addtion, see comment for remove_entitlements below

    Entitlement.delete_all("user_id = #{user_id}")
    role_memberships = user.role_memberships
    role_memberships.each { |role_membership| role_membership.create_entitlements }
  end
  
  def remove_entitlements
    # Removing entitlements means removing all entitlements a user has that are the same as the privileges associated with this role.  However,
    # since the user might have several roles with identical privileges in the same jurisdiction we can't do this as we may delete entitlements
    # granted via some other role. The only thing that can sensibly be done is to remove _all_ entitilements and recreate them for the remaining roles.

    Entitlement.delete_all("user_id = #{user_id}")
    role_memberships = user.role_memberships.select { |role_membership| role_membership.id != self.id }
    role_memberships.each { |role_membership| role_membership.create_entitlements }
  end
  
end
