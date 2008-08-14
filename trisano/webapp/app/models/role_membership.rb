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
  before_update :update_entitlements
  before_destroy :remove_entitlements
  
  # Debt? Currently limits to one role per jurisdiction. The scope at one point
  # included role_id as well. The hope in removing it is to eliminate some strange
  # behavior still to be investigated w/regard to updating role memberships.
  validates_uniqueness_of :user_id, :scope => [:jurisdiction_id],
    :message => "only one role per jurisdiction is currently permitted", :on => :create
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def create_entitlements
    privileges_to_add = PrivilegesRole.find_all_by_role_id_and_jurisdiction_id(self.role_id, self.jurisdiction_id)
    
    privileges_to_add.each do |pr|
      user.entitlements << Entitlement.new(:privilege_id => pr.privilege_id, :jurisdiction_id => self.jurisdiction_id)
    end
  end
  
  def update_entitlements
    
    # Debt. This is ugly and inefficient. Needs a work-around. Maybe even from the UI standpoint 
    # like, you can only add and remove roles, not update.
    current_role = RoleMembership.find(self.id)
    
    privileges_to_remove = PrivilegesRole.find_all_by_role_id_and_jurisdiction_id(current_role.role_id, self.jurisdiction_id)
    
    # If this does end up staying, the following could be dried up, as it repeats the remove_entitlement stuff below
    privileges_to_remove.each do |pr|  
      entitlement_to_remove = user.entitlements.detect do |ent|
        ent.privilege_id == pr.privilege_id && ent.jurisdiction_id == pr.jurisdiction_id
      end
       entitlement_to_remove.destroy unless entitlement_to_remove.nil?
    end

      create_entitlements
    end
  
    def remove_entitlements
      privileges_to_remove = PrivilegesRole.find_all_by_role_id_and_jurisdiction_id(self.role_id, self.jurisdiction_id)
        
      privileges_to_remove.each do |pr|  
        entitlement_to_remove = user.entitlements.detect do |ent|
          ent.privilege_id == pr.privilege_id && ent.jurisdiction_id == pr.jurisdiction_id
        end
        entitlement_to_remove.destroy unless entitlement_to_remove.nil?
      end
    end
  
  end