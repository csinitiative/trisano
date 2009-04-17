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

class User < ActiveRecord::Base
  include TaskFilter

  # Debt? Mess with these includes, see if they are helping or hurting
  has_many :role_memberships, :include => [:role, :jurisdiction], :dependent => :delete_all
  has_many :roles, :through => :role_memberships, :uniq => true
  
  has_many :entitlements, :include => [:privilege, :jurisdiction], :dependent => :delete_all
  has_many :privileges, :through => :entitlements

  has_many :tasks, :order => 'due_date ASC'
  
  validates_associated :role_memberships
  validates_presence_of :uid, :user_name
  validates_uniqueness_of :uid, :user_name
  validates_length_of :uid, :maximum => 50
  validates_length_of :given_name, :maximum => 127, :allow_blank => true
  validates_length_of :first_name, :maximum => 32, :allow_blank => true
  validates_length_of :last_name, :maximum => 64, :allow_blank => true
  validates_length_of :initials, :maximum => 8, :allow_blank => true
  validates_length_of :user_name, :maximum => 20, :allow_blank => true
  validates_length_of :generational_qualifer, :maximum => 8, :allow_blank => true

  serialize :event_view_settings, Hash
  serialize :task_view_settings, Hash

  after_validation :clear_base_error
  
  def best_name
    return given_name unless self.given_name.blank?
    return "#{first_name} #{last_name}".strip unless self.last_name.blank?
    return user_name unless self.user_name.blank?
    return uid
  end

  def is_admin?
    # Right now, if you're an admin anywhere, you're an admin everywhere.  We need to change this.
    is_entitled_to?(:administer)
  end
  
  def is_entitled_to_in?(privilege, jurisdiction_ids)
    j_ids = Array(jurisdiction_ids).map!{ |j_id| j_id.to_i }
    entitlements.detect { |ent| ent.privilege.priv_name.to_sym == privilege && j_ids.include?(ent.jurisdiction_id) }.nil? ? false : true
  end
  
  def is_entitled_to?(privilege)
    entitlements.detect { |ent| ent.privilege.priv_name.to_sym == privilege }.nil? ? false : true
  end

  def jurisdictions_for_privilege(privilege)
    Place.jurisdictions_for_privilege_by_user_id(id, privilege)
  end

  def jurisdiction_ids_for_privilege(privilege)
    entitlements.collect { |ent| ent.jurisdiction_id if ent.privilege.priv_name.to_sym == privilege }.compact
  end
  
  def admin_jurisdiction_ids
    @admin_jurisdiction_ids ||= entitlements.collect { |e| e.jurisdiction_id if e.privilege.priv_name.to_sym == :administer}.compact
  end
  
  # A necessary simplifying assumption: treat all modifications to a user's role as if they were new.
  def role_membership_attributes=(rm_attributes)

    # Zap existing entitlements and role memberships
    entitlements.clear
    role_memberships.clear

    # Temporary holding places for new entitlements and role memberships
    _entitlements = {}
    _role_memberships = []

    # Build an array of uniqe entitlements for this role and jurisdiction
    rm_attributes.each do |attributes|
      role_id = attributes[:role_id]
      jurisdiction_id = attributes[:jurisdiction_id]

      # Skip duplicate roles in duplicate jurisdictions
      attribute_identifier = "#{role_id}_#{jurisdiction_id}" 
      next if _role_memberships.include?(attribute_identifier)
      _role_memberships << attribute_identifier

      Role.find(role_id).privileges.each do |priv|
        # Crafting the key like this avoids duplicate entitlements
        _entitlements["#{priv.id}_#{jurisdiction_id}"] = { :privilege_id => priv.id, :jurisdiction_id => jurisdiction_id }
      end

      # Save the role too
      role_memberships.build(attributes)
    end

    # Build a real entitlement for each uniqe entitlement
    _entitlements.each_pair { |key, value| entitlements.build(value) }
  end

  def self.investigators_for_jurisdictions(jurisdictions)
    jurisdictions = [jurisdictions] unless jurisdictions.respond_to?("each")
    investigators = []
    jurisdictions.each do |j|
      investigators += Privilege.investigate_event.entitlements.for_jurisdiction(j).collect { |e| e.user }
    end
    investigators.uniq.sort_by { |investigator| investigator.best_name }
  end

  def self.task_assignees_for_jurisdictions(jurisdictions)
    jurisdictions = [jurisdictions] unless jurisdictions.respond_to?("each")
    assignees = []
    jurisdictions.each do |j|
      assignees += Privilege.update_event.entitlements.for_jurisdiction(j).collect { |e| e.user }
    end
    assignees.uniq.sort_by { |assignee| assignee.best_name }
  end

  def self.default_task_assignees
    User.task_assignees_for_jurisdictions(
      User.current_user.jurisdictions_for_privilege(:assign_task_to_user))
  end

  # Convenience methods to find/set the current user on the thread from anywhere in the app
  def self.current_user=(user)
    Thread.current[:user] = user
  end

  def self.current_user
    Thread.current[:user]
  end  

  def task_view_settings
    settings = read_attribute(:task_view_settings) || {}
    settings.empty? ? {:look_ahead => 0, :look_back => 0} : settings
  end

  def store_as_task_view_settings(params)    
    view_settings = {}
    (params || []).each do |key, value|
      view_settings[key] = value if User.task_view_params.include?(key.to_sym)
    end
    update_attribute(:task_view_settings, view_settings)
  end

  def self.task_view_params
    [:users, :look_ahead, :look_back, :disease_filter, :task_statuses, :tasks_ordered_by]
  end

  protected
  
  def clear_base_error
    errors.delete(:role_memberships)
  end

end
