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

class HandleNewPrivilegesForProduction < ActiveRecord::Migration
  def self.up

    if RAILS_ENV == "production"
      transaction do

      jurisdiction_type_id = Code.find_by_code_name_and_the_code("placetype", "J").id
      jurisdictions = Place.find_all_by_place_type_id(jurisdiction_type_id)
      roles = Role.find(:all)
      role_memberships = RoleMembership.find(:all)

      # Update privileges for which names are changing
      view_privilege = Privilege.find_by_priv_name("view")

      unless (view_privilege.nil?)
        view_privilege.priv_name = "view_event"
        view_privilege.save!
      end

      update_privilege = Privilege.find_by_priv_name("update")

      unless (update_privilege.nil?)
        update_privilege.priv_name = "update_event"
        update_privilege.save!
      end

      investigate_privilege = Privilege.find_by_priv_name("investigate")

      unless (investigate_privilege.nil?)
        investigate_privilege.priv_name = "investigate_event"
        investigate_privilege.save!
      end

      # Add new privileges
      new_privileges = []

      approve_event_at_lhd = Privilege.find_or_initialize_by_priv_name(:priv_name => "approve_event_at_lhd")
      approve_event_at_lhd.save! if approve_event_at_lhd.new_record?
      new_privileges << approve_event_at_lhd

      approve_event_at_state = Privilege.find_or_initialize_by_priv_name(:priv_name => "approve_event_at_state")
      approve_event_at_state.save! if approve_event_at_state.new_record?
      new_privileges << approve_event_at_state

      route_event_to_any_lhd = Privilege.find_or_initialize_by_priv_name(:priv_name => "route_event_to_any_lhd")
      route_event_to_any_lhd.save! if route_event_to_any_lhd.new_record?
      new_privileges << route_event_to_any_lhd

      accept_event_for_lhd = Privilege.find_or_initialize_by_priv_name(:priv_name => "accept_event_for_lhd")
      accept_event_for_lhd.save! if accept_event_for_lhd.new_record?
      new_privileges << accept_event_for_lhd

      route_event_to_investigator = Privilege.find_or_initialize_by_priv_name(:priv_name => "route_event_to_investigator")
      route_event_to_investigator.save! if route_event_to_investigator.new_record?
      new_privileges << route_event_to_investigator

      accept_event_for_investigation = Privilege.find_or_initialize_by_priv_name(:priv_name => "accept_event_for_investigation")
      accept_event_for_investigation.save! if accept_event_for_investigation.new_record?
      new_privileges << accept_event_for_investigation

      create_event = Privilege.find_or_initialize_by_priv_name(:priv_name => "create_event")
      create_event.save! if create_event.new_record?
      new_privileges << create_event

      # Map new priviliges to the investigate and administrate roles in each jurisdiction
      jurisdictions.each do |jurisdiction|
        roles.each do |role|
          new_privileges.each do |privilege|
            priv_role_mapping = PrivilegesRole.find_or_initialize_by_role_id_and_privilege_id_and_jurisdiction_id(
              :role_id => role.id,
              :privilege_id => privilege.id,
              :jurisdiction_id => jurisdiction.id)
            priv_role_mapping.save! if priv_role_mapping.new_record?
          end
        end
      end

      # Give users the new entitlements
      role_memberships.each do |role_membership|
        new_privileges.each do |privilege|
          new_entitlement = Entitlement.find_or_initialize_by_user_id_and_privilege_id_and_jurisdiction_id(
            :user_id => role_membership.user_id,
            :privilege_id => privilege.id,
            :jurisdiction_id => role_membership.jurisdiction_id)
          new_entitlement.save! if new_entitlement.new_record?
        end
      end
    end
    end
  end

  def self.down
  end
end
