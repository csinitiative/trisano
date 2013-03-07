# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

class Event < ActiveRecord::Base
  include Blankable
  include TaskFilter
  include EventSearch
  include Export::Cdc::EventRules

  after_create :auto_assign_forms_on_create
  before_update :auto_assign_forms_on_update, :if => :disease_changed?

  if RAILS_ENV == "production"
    attr_protected :workflow_state
  end

  composed_of :age_info, :mapping => [%w(age_at_onset age_at_onset), %w(age_type_id age_type_id)]
  belongs_to  :age_type, :class_name => 'ExternalCode', :foreign_key => :age_type_id

  belongs_to :investigator, :class_name => 'User'
  belongs_to :imported_from, :class_name => 'ExternalCode'
  belongs_to :lhd_case_status, :class_name => 'ExternalCode'
  belongs_to :state_case_status, :class_name => 'ExternalCode'
  belongs_to :outbreak_associated, :class_name => 'ExternalCode'

  has_one :jurisdiction, :dependent => :destroy
  alias primary_jurisdiction jurisdiction # fixes csv exports
  has_many :event_type_transitions

  has_many :associated_jurisdictions,
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :all_jurisdictions, :class_name => 'Participation',
    :conditions => ["participations.type IN ('Jurisdiction', 'AssociatedJurisdiction')"],
    :order => 'created_at ASC'

  has_one :disease_event, :order => 'created_at ASC', :dependent => :delete

  belongs_to :event_queue
  has_many :form_references, :order => 'created_at ASC', :dependent => :destroy
  has_many :forms, :through => :form_references
  has_many :answers, :autosave => true, :include => [:question]
  has_many :tasks, :order => 'due_date ASC'
  has_many :notes, :order => 'created_at DESC', :dependent => :destroy
  has_many :attachments, :order => 'updated_at DESC'

  has_many :participations

  has_many :place_child_events,
           :class_name => 'PlaceEvent',
           :foreign_key => 'parent_id',
           :order => "position, created_at ASC" do
    def active(reload=false)
      @active_places = nil if reload
      @active_places ||= PlaceEvent.find(:all,
        :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id],
        :order => "position, created_at ASC"
      )
    end
  end

  has_many :contact_child_events,
           :class_name => 'ContactEvent',
           :foreign_key => 'parent_id',
           :order => 'position, created_at ASC' do
    def active(reload=false)
      @active_contacts = nil if reload
      @active_contacts ||= ContactEvent.find(:all,
        :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id],
        :order => "position, created_at ASC"
      )
    end
  end

  has_many :encounter_child_events, :class_name => 'EncounterEvent', :foreign_key => 'parent_id',
           :include => :participations_encounter, :order => "participations_encounters.encounter_date DESC" do
    def active(reload=false)
      @active_encounters = nil if reload
      @active_encounters ||= EncounterEvent.find(:all,
        :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id],
        :include => :participations_encounter,
        :order => "participations_encounters.encounter_date DESC"
      )
    end
  end

  has_many :child_events,
    :class_name => 'Event',
    :foreign_key => 'parent_id',
    :order => "created_at ASC"

  named_scope :active, :conditions => ['deleted_at IS NULL']
  named_scope :root_level_events,
    :conditions => ['type IN (?)', %w(MorbidityEvent ContactEvent AssessmentEvent)],
    :order => "created_at ASC"

  named_scope :sensitive, lambda { |user|
    jurisdiction_ids = user.jurisdiction_ids_for_privilege(:access_sensitive_diseases)
    jurisdiction_ids << "NULL" if jurisdiction_ids.empty?
    {
      :joins => "JOIN (SELECT a.event_id FROM participations a LEFT JOIN disease_events b on b.event_id = a.event_id LEFT JOIN diseases c ON disease_id = c.id WHERE (c.sensitive IS NULL or c.sensitive = false) OR ((a.type = 'Jurisdiction' OR a.type = 'AssociatedJurisdiction') AND a.secondary_entity_id IN (#{jurisdiction_ids.join(',')})) GROUP BY a.event_id) j ON events.id = j.event_id"
    }
  }

  named_scope :for_jurisdictions, lambda { |jurisdiction_ids|
    { :conditions => { :participations => { :secondary_entity_id => jurisdiction_ids } },
      :include => :all_jurisdictions }
  }

  # These are assessment events that have been 'elevated' from contacts of this event
  has_many :assessment_child_events, :class_name => 'AssessmentEvent', :foreign_key => 'parent_id' do
    def active(reload=false)
      @active_assessment_siblings = nil if reload
      @active_assessment_siblings ||= AssessmentEvent.find(:all, :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id])
    end
  end

  # These are morbidity events that have been 'elevated' from contacts of this event
  has_many :morbidity_child_events, :class_name => 'MorbidityEvent', :foreign_key => 'parent_id' do
    def active(reload=false)
      @active_morbidity_siblings = nil if reload
      @active_morbidity_siblings ||= MorbidityEvent.find(:all, :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id])
    end
  end

  has_one :address

  belongs_to :parent_event, :class_name => 'Event', :foreign_key => 'parent_id'

  has_many :investigator_form_sections, :dependent => :destroy

  accepts_nested_attributes_for :jurisdiction, :reject_if => proc { |attrs| attrs["secondary_entity_id"].blank? }
  accepts_nested_attributes_for :disease_event, :reject_if => :nested_attributes_blank?
  accepts_nested_attributes_for :contact_child_events,
                                :allow_destroy => true,
                                :reject_if => proc { |attrs| check_contact_attrs(attrs) }
  accepts_nested_attributes_for :place_child_events, 
                  			        :allow_destroy => true,
                  			        :reject_if => :place_exposure_blank?
  accepts_nested_attributes_for :encounter_child_events,
                                :allow_destroy => true,
		 	                    	    :reject_if => proc { |attrs| check_encounter_attrs(attrs) }
  accepts_nested_attributes_for :notes, :reject_if => proc { |attrs| !attrs.has_key?('note') || attrs['note'].blank?}
  accepts_nested_attributes_for :address, :reject_if => :nested_attributes_blank? 
  accepts_nested_attributes_for :investigator_form_sections,
                                :allow_destroy => true,
                                :reject_if => :nested_attributes_blank?

  def self.check_contact_attrs(attrs)
    # Contact is an existing entity chosen from search
    return false if attrs["interested_party_attributes"].has_key?('primary_entity_id') and !attrs["interested_party_attributes"][:primary_entity_id].blank?

    # Contact is brand new
    person_empty = attrs["interested_party_attributes"]["person_entity_attributes"]["person_attributes"].all? { |k, v| v.blank? }
    phones_empty = attrs["interested_party_attributes"]["person_entity_attributes"]["telephones_attributes"].all? { |k, v| v.all? { |k, v| v.blank? } }
    disposition_empty = attrs["participations_contact_attributes"].all? { |k, v| v.blank? }

    (person_empty && phones_empty && disposition_empty) ? true : false
  end

  def place_exposure_blank?(attrs)
    attrs["interested_place_attributes"]["primary_entity_id"].nil? &&
      place_and_canonical_address_blank?(attrs["interested_place_attributes"]) &&
      nested_attributes_blank?(attrs["participations_place_attributes"])
  end

  def self.check_encounter_attrs(attrs)
    encounter_empty = attrs["participations_encounter_attributes"].all? do |k, v|
      if ((k == "user_id") ||  (k == "encounter_location_type"))
        true
      else
        v.blank?
      end
    end

    encounter_empty ? true : false
  end

  validates_date :results_reported_to_clinician_date, :allow_blank => true
  validates_existence_of :investigator, :allow_nil => true
  validates_numericality_of :acuity, :only_integer => true, :less_than => 100, :allow_nil => true
  validates_length_of :event_name, :maximum => 100, :allow_blank => true
  validates_length_of :other_data_1, :maximum => 255, :allow_blank => true
  validates_length_of :other_data_2, :maximum => 255, :allow_blank => true
  validates_length_of :outbreak_name, :maximum => 255, :allow_blank => true

  cattr_reader :per_page
  @@per_page = 25

  # Hack.  We want the some validations to fire only when being saved
  # directly, not indirectly as part of a morbidity event.  Morbs will
  # check related events explicitly.  This value should be set in the
  # controller, if it is being used
  attr_accessor :validate_against_bday

  def suppress_validation(validation)
    suppressed_validations << validation
  end

  def suppress_validation?(validation)
    suppressed_validations.include?(validation)
  end

  def suppressed_validations
    @suppressed_validations ||= []
  end

  class << self
    include PostgresFu

    def followup_core_paths(event_id)
      sql = "SELECT core_path
            FROM form_references, form_elements,forms
            WHERE form_references.event_id = " + sanitize_sql(event_id.to_s) + "
            AND forms.id = form_references.form_id
            AND form_elements.form_id = forms.id
            AND type = 'FollowUpElement'
            AND core_path != ''"

      core_paths = connection.execute sql

      core_paths.collect do |cp|
        cp['core_path'].gsub(/\[([A-Za-z\-_]+?)\]\[/, '[\1_attributes][')
      end
    end
  end

  def short_type
    @short_type ||= self.type.sub(/event$/i, '')
  end

  def deleted?
    not deleted_at.nil?
  end

  def open_for_investigation?
    self.under_investigation? or self.investigation_complete? or self.reopened_by_manager?
  end

  # returns only the references for forms that should be rendered on
  # the investigation tab
  def investigation_form_references
    form_references.select {|ref| ref.form.has_investigator_view_elements?}
  end

  def core_only_form_references
    form_references.reject {|ref| ref.form.has_investigator_view_elements?}
  end

  def jurisdiction_of_investigation
    jurisdiction
  end

  def jurisdiction_entity_ids
    if new_record?
      [
        jurisdiction.try(:secondary_entity_id),
        associated_jurisdictions.map(&:secondary_entity_id)
      ].flatten.compact.uniq
    else
      Set.new(all_jurisdictions.map(&:secondary_entity_id))
    end
  end

  # wow. wish this didn't return the disease_event.
  def disease
    self.disease_event
  end

  def disease?
    !self.disease_event.try(:disease).nil?
  end

  def sensitive?
    self.disease_event.try(:disease).try(:sensitive)
  end

  def add_note(message, *note_type_and_options)
    options = note_type_and_options.extract_options!
    note_type = note_type_and_options.first.blank? ? 'administrative' : note_type_and_options.first.to_s
    note = Note.new options.merge(:note => message, :note_type => note_type)
    self.notes << note # this will save the note
    note
  end

  def brief_notes
    self.notes.select {|n| n.note_type == :brief.to_s}
  end

  def eager_load_answers
    self.answers
  end

  # Walks through all unsaved children of this event and assigns them the parent's disease and
  # jurisdiction.  Expected to be called after parent and children have been initially created
  # but not saved, i.e., from the morbidity_event controller, but should be called as needed.
  # Can't do this after the save, because we don't want to overwrite any user made changes to
  # existing records.
  def initialize_children
    parent_jurisdiction = nil
    if self.jurisdiction
      parent_jurisdiction = Jurisdiction.new
      parent_jurisdiction.secondary_entity_id = self.jurisdiction.secondary_entity_id
    end

    parent_disease_event = nil
    unless self.disease_event.nil?
      parent_disease_event = DiseaseEvent.new
      parent_disease_event.disease_id = self.disease_event.disease_id
    end

    # Can't use plain old child_events association 'cause nothin's been saved yet
    # new_record? because we don't wanna overwrite user-made changes
    (self.contact_child_events.select(&:new_record?) + self.place_child_events.select(&:new_record?)).each do |child|
      child.build_disease_event(parent_disease_event.attributes) unless parent_disease_event.nil?
      child.build_jurisdiction(parent_jurisdiction.attributes) unless parent_jurisdiction.nil?
    end
  end

  def add_forms(forms_to_add)
    return if forms_to_add.blank?
    forms = forms_to_add.is_a?(Array) ? forms_to_add : [forms_to_add]
    forms.map! { |f| f.is_a?(Form) ? f : Form.find(f.to_i) }
    existing_template_ids = self.form_references.map(&:template_id)
    forms_to_add = forms.select {|f| !existing_template_ids.include?(f.template_id) }

    Event.transaction do
      forms_to_add.each do |f|
        self.form_references.create!(:form_id => f.id, :template_id => f.template_id)
      end
    end
  end

  def remove_forms(form_ids)
    return if form_ids.blank?
    form_ids = [form_ids] unless form_ids.is_a? Array
    transaction do
      form_ids.each do |form_id|
        form_reference = FormReference.find_by_event_id_and_form_id(self.id, form_id)
        if form_reference.nil?
          raise I18n.translate('missing_form_reference')
        else
          form_reference.destroy
        end
      end
      return true
    end
  rescue Exception => ex
    I18nLogger.fatal("could_not_remove_form_from_event", :message => ex.message + ex.backtrace.join("\n"))
    return
  end

  def soft_delete
    Event.transaction do
      transactional_soft_delete
    end
  end

  def transactional_soft_delete
    if self.deleted_at.nil?
      self.deleted_at = Time.new
      self.add_note(I18n.translate('system_notes.event_deleted', :locale => I18n.default_locale))
      self.save!
      self.child_events.each { |child| child.transactional_soft_delete }
      true
    else
      nil
    end
  end

  def answers=(attributes)
    if answers.empty?
      answers.build(attributes.values)
    else
      answers.each { |answer| answer.attributes = attributes[answer.id.to_s] }
    end
  end

  def new_answers=(attributes)
    answers.build(attributes)
  end

  def new_checkboxes=(attributes)
    attributes.each do |key, value|
      answers.build(
        :question_id => key,
        :check_box_answer => value[:check_box_answer],
        :code => value[:code]
      )
    end
  end

  def new_radio_buttons=(attributes)
    attributes.each do |key, value|
      answers.build(
        :question_id => key,
        :radio_button_answer => value[:radio_button_answer],
        :export_conversion_value_id => value[:export_conversion_value_id],
        :code => value[:code]
      )
    end
  end

  def get_or_initialize_answer(answer_attributes)
    Answer.find(:first, :conditions => answer_attributes) || Answer.new(answer_attributes)
  end

  def clone_event(event_components=[])
    event_components = [] if event_components.nil?
    _event = self.class.new
    self.copy_event(_event, event_components)
    _event
  end

  def copy_event(new_event, event_components)
    new_event.suppress_validation(:first_reported_PH_date)
    new_event.event_name = "#{I18n.translate('copy_of', :locale => I18n.default_locale)} #{self.event_name}" unless self.event_name.blank?
    new_event.build_jurisdiction
    new_event.jurisdiction.secondary_entity = (User.current_user.jurisdictions_for_privilege(:create_event).first || Place.unassigned_jurisdiction).entity
    new_event.workflow_state = 'accepted_by_lhd' unless new_event.jurisdiction.place.is_unassigned_jurisdiction?
    new_event.acuity = self.acuity

    if event_components.include?("clinical")
      if self.disease_event
        new_event.build_disease_event(:hospitalized_id =>  self.disease_event.hospitalized_id,
          :died_id => self.disease_event.died_id,
          :disease_onset_date => self.disease_event.disease_onset_date,
          :date_diagnosed => self.disease_event.date_diagnosed)
      end
    end

    if event_components.include?("disease_specific")
      self.form_references.each do |form|
        new_event.form_references.build(:form_id => form.form_id, :template_id => form.template_id) # Can't use add_forms here since the new event isn't saved
      end

      self.answers.each do |answer|
        new_event.answers.build(:question_id => answer.question_id,
          :text_answer => answer.text_answer,
          :export_conversion_value_id => answer.export_conversion_value_id)
      end
    end

    if event_components.include?("notes")
      self.notes.each do |note|
        if note.note_type == "clinical"
          attrs = note.attributes
          attrs.delete('event_id')
          new_event.notes.build(attrs)
        end
      end
    end
  end

  def events_quick_list(reload=false)
    if reload or @events_quick_list.nil?
      @events_quick_list = self.class.find_by_sql([<<-SQL, self.id, self.id])
        SELECT ev.id,
               ev.workflow_state,
               ev.type,
               TRIM(
                 COALESCE(pp.first_name, '')
                 || ' '
                 || COALESCE(pp.last_name, '')
               ) as full_name
          FROM events ev
          JOIN participations pt ON pt.event_id = ev.id AND pt.type = 'InterestedParty'
          JOIN entities en ON en.id = pt.primary_entity_id AND en.deleted_at IS NULL
          JOIN people pp ON pp.entity_id = en.id
         WHERE ev.parent_id = ?
           AND ev.type IN ('MorbidityEvent', 'ContactEvent')
           AND ev.deleted_at IS NULL
        UNION
        SELECT ev.id,
               ev.workflow_state,
               ev.type,
               pl.name as full_name
          FROM events ev
          JOIN participations pt ON pt.event_id = ev.id AND pt.type = 'InterestedPlace'
          JOIN entities en ON en.id = pt.primary_entity_id AND en.deleted_at IS NULL
          JOIN places pl ON pl.entity_id = en.id
         WHERE ev.parent_id = ?
           AND ev.type IN ('PlaceEvent')
           AND ev.deleted_at IS NULL;
      SQL
    else
      @events_quick_list
    end
  end

  def event_siblings_quick_list(reload=false)
    return [] if parent_event.nil?
    if reload or @event_siblings.nil?
      @event_siblings = parent_event.events_quick_list.reject { |event| event == self }
    else
      @event_siblings
    end
  end

  def promote_to(event_type)
    method_name = "promote_to_#{event_type}"
    supports_method_name = "supports_#{method_name}?"
    if self.send(supports_method_name)
      return self.send(method_name)
    else
      return false
    end    
  end
  
  def promote_to_morbidity_event
    raise(I18n.t("cannot_promote_unsaved_event")) if self.new_record?

    # In case the event is in a state that doesn't exist for a morbidity evnet.
    # Also check that the event type supports the not_routed state. (Assessment Events do not.)
    if self.respond_to?(:not_routed?) && self.not_routed?
      if self.jurisdiction.place.is_unassigned_jurisdiction?
        self.promote_as_new
      else
        self.promote_as_accepted
      end
    end

    self['type'] = MorbidityEvent.to_s
    # Pull morb forms
    if self.disease_event && self.disease_event.disease
      jurisdiction = self.jurisdiction ? self.jurisdiction.secondary_entity_id : nil
      self.add_forms(Form.get_published_investigation_forms(self.disease_event.disease_id, jurisdiction, 'morbidity_event'))
    end
    self.add_note(I18n.translate("system_notes.event_promoted_from_to", :locale => I18n.default_locale, :from => self.type.humanize.downcase, :to => "morbidity event"))
    self.created_at = Time.now

    if self.save
      EventTypeTransition.create(:event => self, :was => self.class, :became => MorbidityEvent, :by => User.current_user)
      self.freeze
      expire_parent_record_contacts_cache
      # Return a fresh copy from the db
      MorbidityEvent.find(self.id)
    else
      false
    end
  end
  
  def promote_to_assessment_event
    raise(I18n.t("cannot_promote_unsaved_event")) if self.new_record?

    # In case the event is in a state that doesn't exist for a morbidity evnet.
    # Also check that the event type supports the not_routed state. (Assessment Events do not.)
    if self.respond_to?(:not_routed?) && self.not_routed?
      if self.jurisdiction.place.is_unassigned_jurisdiction?
        self.promote_as_new
      else
        self.promote_as_accepted
      end
    end

    self['type'] = AssessmentEvent.to_s
    # Pull assessment event forms
    if self.disease_event && self.disease_event.disease
      jurisdiction = self.jurisdiction ? self.jurisdiction.secondary_entity_id : nil
      self.add_forms(Form.get_published_investigation_forms(self.disease_event.disease_id, jurisdiction, 'assessment_event'))
    end
    self.add_note(I18n.translate("system_notes.event_promoted_from_to", :locale => I18n.default_locale, :from => self.type.humanize.downcase, :to => "morbidity event"))
    self.created_at = Time.now

    if self.save
      EventTypeTransition.create(:event => self, :was => self.class, :became => AssessmentEvent, :by => User.current_user)
      self.freeze
      expire_parent_record_contacts_cache
      # Return a fresh copy from the db
      AssessmentEvent.find(self.id)
    else
      false
    end
  end

  def patient
    if self.respond_to?(:interested_party) &&
       self.interested_party.present? &&
       self.interested_party.person_entity.present? &&
       self.interested_party.person_entity.person.present? 
      return interested_party.person_entity.person
    end
  end
  
  def disease_name
    if self.respond_to?(:disease) &&
       self.disease.present? &&
       self.disease.disease.present?
      return disease.disease.disease_name
    end
  end
  
  def self.get_all_states_and_descriptions
    # Events have slightly different workflows.  Get the union.
    all_states = MorbidityEvent.get_states_and_descriptions + 
                 ContactEvent.get_states_and_descriptions + 
                 AssessmentEvent.get_states_and_descriptions

    unique_states = []
    all_states.each do |state| 
      unique_workflow_states = unique_states.map(&:workflow_state)
      unique_states << state unless unique_workflow_states.include?(state.workflow_state)
    end
    return unique_states
  end

  def disease_changed?
    self.disease_event and self.disease_event.disease_id_changed?
  end

  def can_receive_auto_assigned_forms?
    self.disease_event and self.disease_event.disease_id and self.jurisdiction
  end

  def auto_assign_forms_on_create
    return unless can_receive_auto_assigned_forms?
    create_form_references
    if (self.form_references.size > 0)
      self.form_references.each do |ref|
        ref.event_id = self.id
        ref.save
      end
    end
    self.update_attribute(:undergone_form_assignment, true)
  end

  def auto_assign_forms_on_update
    return unless can_receive_auto_assigned_forms?
    add_forms(available_forms)
    self.undergone_form_assignment = true
  end

  def needs_forms_update?
    self.available_forms.length > 0 or  self.forms_to_remove.length > 0
  end

  def forms_to_remove
    forms = Form.get_published_investigation_forms(self.disease_event.disease_id, self.jurisdiction.secondary_entity_id, self.class.name.underscore)
    template_ids = forms.map(&:template_id)
    self.form_references.map(&:form).select {|f| !template_ids.include?(f.template_id) }
  end

  def common_forms
    forms = Form.get_published_investigation_forms(self.disease_event.disease_id, self.jurisdiction.secondary_entity_id, self.class.name.underscore)
    forms.select {|f| self.forms_in_use.map(&:id).include?(f.id) }
  end

  def forms_in_use
    self.form_references.map(&:form)
  end

  def available_forms
    return [] unless self.disease_event
    forms = Form.get_published_investigation_forms(self.disease_event.disease_id, self.jurisdiction.secondary_entity_id, self.class.name.underscore)
    template_ids = self.form_references.map(&:template_id)
    forms.select {|f| !template_ids.include?(f.template_id) }
  end

  def create_form_answers_for_repeating_form_elements
    self.form_references.each { |fr| fr.create_answers_for_repeaters }
  end

  private
  def create_form_references
    return [] if self.disease_event.nil? || self.disease_event.disease_id.blank? || self.jurisdiction.nil?

    auto_assignable_forms = Form.auto_assignable_forms(self.disease_event.disease_id, self.jurisdiction.secondary_entity_id, self.class.name.underscore)
    template_ids = self.form_references.map(&:template_id)
    auto_assignable_forms.each do |f|
      next if template_ids.include?(f.template_id)
      self.form_references << FormReference.new(:form_id => f.id, :template_id => f.template_id)
    end
    true
  end


  # This method can be invoked by sub-classes before_create hooks in order to set
  # attributes on them which may be required for saving. Jurisdiction and disease
  # setting is also attempted by Event#initialize_children. The duplication that
  # occurs by having the before_create hooks call direct_child_creation_initialization
  # on the creation of a morbidity event with children doesn't incur any penalty
  # when saving from the morbidity event level b/c the parent_event.*.nil? checks
  # will return true in that scenario.
  def direct_child_creation_initialization
    build_jurisdiction_based_on_parent
    build_disease_based_on_parent
  end

  def build_jurisdiction_based_on_parent
    return if parent_event.nil? || parent_event.jurisdiction.nil? || !self.jurisdiction.nil?
    parent_jurisdiction = Jurisdiction.new
    parent_jurisdiction.secondary_entity_id = parent_event.jurisdiction.secondary_entity_id
    build_jurisdiction(parent_jurisdiction.attributes)
  end

  def build_disease_based_on_parent
    return if parent_event.nil? || parent_event.disease_event.nil? || !self.disease_event.nil?
    parent_disease_event = DiseaseEvent.new
    parent_disease_event.disease_id = parent_event.disease_event.disease_id
    build_disease_event(parent_disease_event.attributes)
  end

  # Indicates whether an event supports something. Generally used by the UI in shared partials
  # to determine whether task-specific layout should be included.
  #
  # Is evaulated at runtime so we must limit the type of functionality supported so we can explictly
  # set the defaults below the class definition, so when the class is loaded, it defines methods
  # for each of these functionalities.

  def self.supported_functionality
    %w(
        encounter_specific_treatments
        encounter_specific_labs
        tasks
        attachments
        promote_to_morbidity_event
        promote_to_assessment_event
        child_events
      )
  end



  # Sub-classes can either override these method to return true or use a declarative option:
  # supports :something
  class << self
    # self is the class from which support :something is being called

    def supports(functionality)
      raise "Unsupported functionality" unless Event.supported_functionality.include?(functionality.to_s)

      supports_method = %Q{
        def supports_#{functionality.to_s}?
          true
        end
      }

      # adds method to the calling class so supports_something? and returns true
      class_eval(supports_method)
    end #def supports
  end #class << self
end

# Define methods for supported event functionality such as
# supports_tasks? which will return false, allowing subclasses
# who have defined supports :tasks to override this
#
# Must get called outside the class so when class is loaded the code is evaulated
Event.supported_functionality.each do |functionality|
  Event.send(:define_method, "supports_#{functionality}?", Proc.new {false})
end
