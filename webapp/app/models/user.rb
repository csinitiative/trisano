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
  serialize :shortcut_settings, Hash

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
    priv_id = Privilege.find_by_priv_name(privilege.to_s).try(:id)
    return false unless priv_id
    role_ids = PrivilegesRole.find_all_by_privilege_id(priv_id.to_i).collect { |p| p.role_id}
    self.role_memberships.detect { |r| role_ids.include?(r.role_id) && j_ids.include?(r.jurisdiction_id) }.nil? ? false : true
  end
  
  def is_entitled_to?(privilege)
    self.roles.all.each do |r|
      ret = r.privileges.detect { |p| p.priv_name.to_sym == privilege }.nil? ? false : true
      return ret if ret == true
    end
    false
  end

  def jurisdictions_for_privilege(privilege)
    Place.jurisdictions_for_privilege_by_user_id(id, privilege.to_s).uniq
  end

  def jurisdiction_ids_for_privilege(privilege)
    priv_id = Privilege.find_by_priv_name(privilege.to_s).id
    role_ids = PrivilegesRole.find_all_by_privilege_id(priv_id).collect { |p| p.role_id }
    self.role_memberships.collect { |r| r.jurisdiction_id if role_ids.include?(r.role_id) }.compact.uniq
  end
  
  def admin_jurisdiction_ids
    priv_id = Privilege.find_by_priv_name("administer").id
    role_ids = PrivilegesRole.find_all_by_privilege_id(priv_id.to_i).collect { |p| p.role_id }
    @admin_jurisdiction_ids ||= self.role_memberships.collect { |r| r.jurisdiction_id if role_ids.include?(r.role_id) }.compact.uniq
  end
  
  def self.investigators_for_jurisdictions(jurisdictions)
    jurisdictions = [jurisdictions] unless jurisdictions.respond_to?("each")
    investigators = []
    jurisdictions.each do |j|
      Privilege.investigate_event.roles.all.each do |r|
        investigators += r.role_memberships.for_jurisdiction(j).collect { |e| e.user }
      end
    end
    investigators.uniq.sort_by { |investigator| investigator.best_name }
  end

  def self.task_assignees_for_jurisdictions(jurisdictions)
    jurisdictions = [jurisdictions] unless jurisdictions.respond_to?("each")
    assignees = []
    jurisdictions.each do |j|
      Privilege.update_event.roles.all.each do |r|
        assignees += r.role_memberships.for_jurisdiction(j).collect { |e| e.user }
      end
    end
    assignees.uniq.sort_by { |assignee| assignee.best_name }
  end

  def drop_all_roles
    roles.clear
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
 
  def shortcut_settings
    settings = read_attribute(:shortcut_settings) || {}
    #You can stick default values in here (or in the db)
    settings.empty? ? {} : settings
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

  def role_membership_attributes=(rm_attributes)
    role_memberships.clear

    _role_memberships = []

    rm_attributes.each do |attributes|
      role_id = attributes[:role_id]
      jurisdiction_id = attributes[:jurisdiction_id]

      # Skip duplicate roles in duplicate jurisdictions
      attribute_identifier = "#{role_id}_#{jurisdiction_id}" 
      next if _role_memberships.include?(attribute_identifier)
      _role_memberships << attribute_identifier

      role_memberships.build(attributes)
    end
  end

  protected
  
  def clear_base_error
    errors.delete(:role_memberships)
  end

end
