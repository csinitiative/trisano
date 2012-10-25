# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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
  has_many :email_addresses, :order => "updated_at", :as => :owner

  validates_associated :role_memberships
  validates_presence_of :uid, :user_name, :status
  validates_uniqueness_of :uid, :user_name
  validates_length_of :uid, :maximum => 50
  validates_length_of :given_name, :maximum => 127, :allow_blank => true
  validates_length_of :first_name, :maximum => 32, :allow_blank => true
  validates_length_of :last_name, :maximum => 64, :allow_blank => true
  validates_length_of :initials, :maximum => 8, :allow_blank => true
  validates_length_of :user_name, :maximum => 20, :allow_blank => true
  validates_length_of :generational_qualifer, :maximum => 8, :allow_blank => true
  validates_each :status, :allow_blank => true do |record, attr, value|
    record.errors.add attr, :valid_status, :status => self.valid_status_sentence unless valid_statuses.include?(value)
  end

  serialize :event_view_settings, Hash
  serialize :event_display_settings, Hash
  serialize :task_view_settings, Hash
  serialize :shortcut_settings, Hash

  before_validation_on_create :set_initial_status
  after_validation :clear_base_error

  class << self
    def status_array
      [
        [I18n.t('user_statuses.active'),   'active'  ],
        [I18n.t('user_statuses.disabled'), 'disabled']
      ]
    end

    def valid_statuses
      @valid_statuses ||= status_array.collect { |status| status.last }
    end

    def valid_status_sentence
      @valid_status_sentence ||= status_array.collect do |status|
        status.first
      end.to_sentence :last_word_connector => I18n.t(:or), :two_words_connector => I18n.t(:or)
    end

    def set_default_admin_uid(uid, options={})
      reset_column_information
      admin_role = Role.find_by_role_name("Administrator")
      unassigned_jurisdiction = Place.unassigned_jurisdiction.entity

      user = User.find_or_initialize_by_uid(:uid => uid, :user_name => uid)
      user.update_attributes!(options)
      
      RoleMembership.create(:user => user, :role => admin_role, :jurisdiction => unassigned_jurisdiction)
    end

    def load_default_users(users)
      reset_column_information
      User.transaction do
        users.each do |user|
          u = User.find_or_initialize_by_uid(:uid => user['uid'], :user_name => user['user_name'])
          u.update_attributes!(user)
        end
      end
    end
  end

  def toggle_event_display?
    event_display_settings and event_display_settings[:event_display_option] == "1"
  end

  def active?
    return !self.disabled?
  end

  # Lazy loads a cache of user's jurisdictions and privileges in the form: privs[:priv_name] = [jurisdiction_ids...]
  # E.g. privs[:update_event] = [59, 56]
  # Jurisdiction ids collection is actually a Set, so no dupes and set math is in play.
  # Cache lasts as long as the user does, which is the length of one request.
  def privs
    @privs ||= get_privs
  end

  def get_privs
    returning(Hash.new { |h, k| h[k] = Set.new }) do |privs|
      # I feel the need for speed
      results = User.find_by_sql([<<-SQL, self.uid])
        SELECT DISTINCT rm.jurisdiction_id as j_id, p.priv_name as priv
          FROM users u, role_memberships rm, privileges_roles pr, privileges p
         WHERE u.uid = ?
           AND u.id = rm.user_id
           AND rm.role_id = pr.role_id
           AND pr.privilege_id = p.id
      SQL
      results.each {|record| privs[record.priv.to_sym] << record.j_id.to_i}
    end
  end

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

  def disabled?
    self.status.downcase == 'disabled'
  end

  def disable
    self.update_attribute(:status, 'disabled')
  end

  def is_entitled_to_in?(privilege, jurisdiction_ids, reload=false)
    @privs = nil if reload
    # jurisdiction_ids may be an array or a single ID.  Convert them all to ints just to be sure.
    j_ids = Set.new([jurisdiction_ids].flatten.map(&:to_i))
    !(privs[privilege.to_sym] & j_ids).empty?
  end

  def is_entitled_to?(*privileges)
    privileges.any? {|priv| !privs[priv.to_sym].empty?}
  end

  # Debt: this is actually
  # jurisdiction_*places*__for_privilege. should probably rename.
  def jurisdictions_for_privilege(privilege)
    Place.jurisdictions_for_privilege_by_user_id(id, privilege.to_s).uniq
  end

  # same as privs[privilege], but converts Set to array so join and
  # other array-ish things can be done to it
  def jurisdiction_ids_for_privilege(privilege)
    privs[privilege.to_sym].to_a
  end

  def admin_jurisdiction_ids
    @admin_jurisdiction_ids ||= jurisdiction_ids_for_privilege(:administer)
  end

  def sensitive_disease_jurisdiction_ids
    @sensitive_disease_jurisdiction_ids ||= jurisdiction_ids_for_privilege(:access_sensitive_diseases)
  end

  def self.investigators_for_jurisdictions(jurisdictions)
    jurisdictions = [jurisdictions] unless jurisdictions.respond_to?("each")
    investigators = User.find_by_sql([<<-SQL, jurisdictions])
      SELECT DISTINCT e.id, e.uid, e.user_name, e.given_name, e.first_name, e.last_name
        FROM privileges a
        JOIN privileges_roles b ON b.privilege_id = a.id
        JOIN roles c ON c.id = b.role_id
        JOIN role_memberships d ON d.role_id = c.id
        JOIN users e ON e.id = d.user_id
       WHERE a.priv_name = 'investigate_event'
         AND d.jurisdiction_id IN (?)
       ORDER BY e.first_name, e.last_name;
    SQL
    investigators.uniq.sort_by { |investigator| investigator.best_name }
  end

  def self.investigators
    self.users_by_priv_name('investigate_event')
  end

  def self.state_managers
    self.users_by_priv_name('approve_event_at_state')
  end

  named_scope :users_by_priv_name, lambda { |priv_name|
    { :conditions => { :privileges => { :priv_name => priv_name.to_s } },
      :select => "DISTINCT ON(users.id) users.*",
      :joins => [ "INNER JOIN role_memberships ON role_memberships.user_id = users.id",
        "INNER JOIN privileges_roles ON privileges_roles.role_id = role_memberships.role_id",
        "INNER JOIN privileges ON privileges.id = privileges_roles.privilege_id" ]
    }
  }

  named_scope :active, :conditions => { :status => 'active' }

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

  def owns?(thing)
    if thing.respond_to?(:owner_id)
      thing.owner_id == self.id
    else
      false
    end
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

  def state_manager?
    is_entitled_to?(:approve_event_at_state)
  end

  def can_create?(event=nil, reload=false)
    can?(:create_event, event, reload)
  end

  def can_update?(event=nil, reload=false)
    can?(:update_event, event, reload)
  end

  def can_view?(event=nil, reload=false)
    can?(:view_event, event, reload)
  end

  def can_access_sensitive_diseases?(event=nil, reload=false)
    can?(:access_sensitive_diseases, event, reload)
  end

  def can_route_to_any_lhd?(event=nil, reload=false)
    @privs = nil if reload
    if event.nil?
      is_entitled_to?(:route_event_to_any_lhd)
    else
      privs[:route_event_to_any_lhd].include? event.jurisdiction.secondary_entity_id
    end
  end

  def can?(priv, event=nil, reload=false)
    @privs = nil if reload
    if event.nil? || event.jurisdiction_entity_ids.empty?
      is_entitled_to?(priv)
    else
      !(privs[priv] & event.jurisdiction_entity_ids).empty?
    end
  end

  def password_expired?
    return if config_options[:trisano_auth][:password_expiry_date] == 0 or config_options[:trisano_auth][:password_expiry_date].nil?
    password_last_updated and password_last_updated < config_options[:trisano_auth][:password_expiry_date].days.ago.to_date
  end

  def password_expires_soon?
    return if config_options[:trisano_auth][:password_expiry_date] == 0 or
      config_options[:trisano_auth][:password_expiry_date].nil? or
      config_options[:trisano_auth][:password_expiry_notice_date].nil?
    days_left = config_options[:trisano_auth][:password_expiry_date] - config_options[:trisano_auth][:password_expiry_notice_date]
    password_last_updated and password_last_updated < days_left.days.ago.to_date
  end

  protected

  def clear_base_error
    errors.delete(:role_memberships)
  end

  def set_initial_status
    self.status = 'active' if self.status.blank?
  end
end
