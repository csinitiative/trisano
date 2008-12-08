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

class Event < ActiveRecord::Base
  include Blankable
  include Export::Cdc::EventRules
  
  after_update :save_associations
  before_save :generate_mmwr
  before_create :set_record_number
  before_validation_on_create :set_event_onset_date

  if RAILS_ENV == "production"
    attr_protected :event_status
  end

  composed_of :age_info, :mapping => [%w(age_at_onset age_at_onset), %w(age_type_id age_type_id)]
  belongs_to  :age_type, :class_name => 'ExternalCode', :foreign_key => :age_type_id

  belongs_to :investigator, :class_name => 'User'
  belongs_to :imported_from, :class_name => 'ExternalCode'
  belongs_to :lhd_case_status, :class_name => 'ExternalCode'
  belongs_to :udoh_case_status, :class_name => 'ExternalCode'
  belongs_to :outbreak_associated, :class_name => 'ExternalCode'

  belongs_to :event_queue

  has_one :disease_event, :order => 'created_at ASC', :dependent => :delete

  has_many :participations

  has_many :form_references
  has_many :answers

  def self.primary_jurisdiction_code_id
    @@primary_jurisdiction_code_id ||= Code.primary_jurisdiction_participant_type_id
  end

  def self.secondary_jurisdiction_code_id
    @@secondary_jurisdiction_code_id ||= Code.secondary_jurisdiction_participant_type_id
  end

  has_one :jurisdiction, :class_name => 'Participation', :conditions => ["role_id = ?", primary_jurisdiction_code_id]

  has_many :contacts, 
    :class_name => 'Participation',  
    :foreign_key => "event_id",
    :conditions => ["role_id = ?", Code.contact_type_id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :associated_jurisdictions, :class_name => 'Participation',
    :conditions => ['role_id = ?', secondary_jurisdiction_code_id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :all_jurisdictions, :class_name => 'Participation',
    :conditions => ['role_id IN (?)', [primary_jurisdiction_code_id, secondary_jurisdiction_code_id]],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :notes, :order => 'updated_at ASC', :dependent => :destroy

  # Consider acts_as_tree.
  has_many :place_child_events, :class_name => 'PlaceEvent', :foreign_key => 'parent_id' do
    def active(reload=false)
      @active_places = nil if reload
      @active_places ||= PlaceEvent.find(:all, :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id])
    end
  end
  has_many :contact_child_events, :class_name => 'ContactEvent', :foreign_key => 'parent_id' do
    def active(reload=false)
      @active_contacts = nil if reload
      @active_contacts ||= ContactEvent.find(:all, :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id])
    end
  end
  has_many :child_events, :class_name => 'Event', :foreign_key => 'parent_id' do
    def active(reload=false)
      @active_contacts = nil if reload
      @active_contacts ||= Event.find(:all, :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id])
    end
  end
  belongs_to :parent_event, :class_name => 'Event', :foreign_key => 'parent_id'

  # Turn off auto validation of has_many associations
  def validate_associated_records_for_contacts() end
  def validate_associated_records_for_participations() end
  def validate_associated_records_for_answers() end
  def validate_associated_records_for_notes() end

  validates_date :event_onset_date
  validates_associated :contacts
  validates_associated :answers
  validates_associated :notes
  validates_existence_of :investigator, :allow_nil => true
  validates_length_of :event_name, :maximum => 100, :allow_blank => true
  validates_length_of :acuity, :maximum => 255, :allow_blank => true
  validates_length_of :other_data_1, :maximum => 255, :allow_blank => true
  validates_length_of :other_data_2, :maximum => 255, :allow_blank => true
  validates_length_of :outbreak_name, :maximum => 255, :allow_blank => true
  ### Debt:  Event Status stuff should be made into its own object and associated with event

  @@states = {}
  @@states['NEW']       = { 
    :transitions => ["ASGD-LHD"],
    :action_phrase => nil,
    :priv_required => :create_event,
    :description => "New",
    :state_code => "NEW"
  }
  @@states['ASGD-LHD']  = {
    :transitions => ["ASGD-LHD", "ACPTD-LHD", "RJCTD-LHD"],
    :action_phrase => nil,
    :priv_required => :route_event_to_any_lhd,
    :description => "Assigned to Local Health Dept.",
    :state_code => "ASGD-LHD"
  }
  @@states['ACPTD-LHD'] = {
    :transitions => ["ASGD-LHD", "ASGD-INV", "UI"],
    :action_phrase => "Accept",
    :priv_required => :accept_event_for_lhd,
    :description => "Accepted by Local Health Dept.",
    :state_code => "ACPTD-LHD"
  }
  @@states['RJCTD-LHD'] = {
    :transitions => ["ASGD-LHD"],
    :action_phrase => "Reject",
    :priv_required => :accept_event_for_lhd,
    :description => "Rejected by Local Health Dept.",
    :state_code => "RJCTD-LHD"
  }
  @@states['ASGD-INV']  = {
    :transitions => ["ASGD-LHD", "UI", "RJCTD-INV"],
    :action_phrase => "Route locally to",
    :priv_required => :route_event_to_investigator,
    :description => "Assigned to Investigator",
    :state_code => "ASGD-INV"
  }
  @@states['UI']        = {
    :transitions => ["ASGD-LHD", "IC"],
    :action_phrase => "Accept",
    :priv_required => :accept_event_for_investigation,
    :description => "Under Investigation",
    :state_code => "UI"
  }
  @@states['RJCTD-INV'] = {
    :transitions => ["ASGD-LHD", "ASGD-INV", "UI"],
    :action_phrase => "Reject",
    :priv_required => :accept_event_for_investigation,
    :description => "Rejected by Investigator",
    :state_code => "RJCTD-INV"
  }
  @@states['IC']        = {
    :transitions => ["ASGD-LHD", "APP-LHD", "RO-MGR"],
    :action_phrase => "Mark Investigation Complete",
    :priv_required => :investigate_event ,
    :description => "Investigation Complete",
    :state_code => "IC"
  }
  @@states['APP-LHD']   = {
    :transitions => ["ASGD-LHD", "CLOSED", "RO-STATE"],
    :action_phrase => "Approve",
    :priv_required => :approve_event_at_lhd ,
    :description => "Approved by LHD",
    :state_code => "APP-LHD"
  }
  @@states['RO-MGR']    = {
    :transitions => ["ASGD-LHD", "IC"],
    :action_phrase => "Reopen",
    :priv_required => :approve_event_at_lhd ,
    :description => "Reopened by Manager",
    :state_code => "RO-MGR"
  }
  @@states['CLOSED']    = {
    :transitions => [],
    :action_phrase => "Approve",
    :priv_required => :approve_event_at_state ,
    :description => "Approved by State",
    :state_code => "CLOSED"
  }
  @@states['RO-STATE']  = {
    :transitions => ["ASGD-LHD", "APP-LHD", "RO-MGR"],
    :action_phrase => "Reopen",
    :priv_required => :approve_event_at_state ,
    :description => "Reopened by State",
    :state_code => "RO-STATE"
  }

  @@ordered_states = []
  @@ordered_states << @@states['NEW']
  @@ordered_states << @@states['ASGD-LHD']
  @@ordered_states << @@states['ACPTD-LHD']
  @@ordered_states << @@states['RJCTD-LHD']
  @@ordered_states << @@states['ASGD-INV']
  @@ordered_states << @@states['UI']
  @@ordered_states << @@states['RJCTD-INV']
  @@ordered_states << @@states['IC']
  @@ordered_states << @@states['APP-LHD']
  @@ordered_states << @@states['RO-MGR']
  @@ordered_states << @@states['CLOSED']
  @@ordered_states << @@states['RO-STATE']

  class << self

    def get_action_phrases(state_names)
      state_names.to_a
      actions = []
      state_names.each do |state_name|
        unless @@states[state_name][:action_phrase].nil?
          actions << OpenStruct.new( :phrase => @@states[state_name][:action_phrase], :state => state_name )
        end
      end
      actions
    end

    def get_transition_states(state_name)
      @@states[state_name][:transitions]
    end

    def get_required_privilege(state_name)
      @@states[state_name][:priv_required]
    end

    def get_state_keys
      @@states.keys
    end

    def get_states_and_descriptions
      @@ordered_states.map { |state| OpenStruct.new( :state => state[:state_code], :description => state[:description]) }
    end

    def get_state_description(state_name)
      @@states[state_name][:description]
    end

    def participation_code(description)
      Code.find_by_code_name_and_code_description('participant', description).id
    end

    # A hash that provides a basic field index for the event forms. It maps the event form
    # attribute keys to some metadata that is used to drive core field and core follow-up
    # configurations in form builder.
    # 
    # Names do not have to match the field name on the form views. Names are used to 
    # drive the drop downs for core field and core follow up configurations. So more context
    # can be given to these names than might appear on the actual event forms, because in
    # drop down in form builder, 'Last name' isn't going to be enough information for the user.
    def exposed_attributes
      CoreField.event_fields(self.to_s.underscore)
    end

    def new_ibis_records
      # New: Record has not been sent to IBIS, record has a disease, record is confirmed, probable, or suspect, record has not been soft-deleted
      new_records = Event.find_by_sql("
                                      SELECT e.id AS event_id FROM events e, disease_events d, external_codes c
                                      WHERE (e.sent_to_ibis = FALSE
                                      OR e.sent_to_ibis IS NULL)
                                      AND e.deleted_at IS NULL
                                      AND d.event_id = e.id
                                      AND d.disease_id IS NOT NULL 
                                      AND e.udoh_case_status_id = c.id
                                      AND c.code_name = 'case'
                                      AND c.the_code IN ('C', 'P', 'S') 
        ")
    end
      
    def updated_ibis_records
      # New: Record has been sent to IBIS, record has been updated, record has a disease, record is confirmed, probable, or suspect, record has not been soft-deleted
      updated_records = Event.find_by_sql("
                                      SELECT e.id AS event_id FROM events e, disease_events d, external_codes c
                                      WHERE e.sent_to_ibis = TRUE
                                      AND e.ibis_update = TRUE
                                      AND e.deleted_at IS NULL
                                      AND d.event_id = e.id
                                      AND d.disease_id IS NOT NULL 
                                      AND e.udoh_case_status_id = c.id
                                      AND c.code_name = 'case'
                                      AND c.the_code IN ('C', 'P', 'S') 
        ")
    end

    def deleted_ibis_records
      # New: Record has been sent to IBIS, record has been updated, record has a disease, record is not confirmed, probable, or suspect OR record has been soft-deleted
      updated_records = Event.find_by_sql("
                                      SELECT e.id AS event_id FROM events e, disease_events d, external_codes c
                                      WHERE e.sent_to_ibis = TRUE
                                      AND e.ibis_update = TRUE
                                      AND d.event_id = e.id
                                      AND d.disease_id IS NOT NULL 
                                      AND e.udoh_case_status_id = c.id
                                      AND c.code_name = 'case'
                                      AND (c.the_code NOT IN ('C', 'P', 'S') OR e.deleted_at IS NOT NULL)
        ")
    end

    def exportable_ibis_records
      new_ibis_records + updated_ibis_records + deleted_ibis_records
    end

    def reset_ibis_status(events)
      event_ids = events.compact.collect {|record| record.event_id}
      Event.update_all('ibis_update=false, sent_to_ibis=true', ['id IN (?)', event_ids])
    end
      
  end

  def legal_state_transition?(proposed_state)
    @@states[self.event_status][:transitions].include?(proposed_state) ? true : false
  end

  def under_investigation?
    ['UI', 'IC', 'RO-MGR'].include?(self.event_status)
  end

  # returns only the references for forms that should be rendered on
  # the investigation tab
  def investigation_form_references
    form_references.select {|ref| ref.form.has_investigator_view_elements?}
  end

  def core_only_form_references
    form_references.reject {|ref| ref.form.has_investigator_view_elements?}
  end

  def primary_jurisdiction
    active_jurisdiction.secondary_entity.current_place if active_jurisdiction
  end

  def secondary_jurisdictions
    associated_jurisdictions.collect { |j| j.secondary_entity.current_place }
  end

  def jurisdiction_of_investigation
    primary_jurisdiction
  end

  def disease
    self.disease_event
  end

  def disease=(attributes)
    return if attributes.values_blank?

    self.build_disease_event if self.disease_event.nil?
    self.disease_event.attributes = attributes
  end  

  def new_contact_attributes=(contact_attributes)
    contact_attributes.each do |attributes|
      code = attributes.delete(:entity_location_type_id)
      next if attributes.values_blank?

      person = {}
      person[:last_name] = attributes.delete(:last_name)
      person[:first_name] = attributes.delete(:first_name)
      person[:disposition_id] = attributes.delete(:disposition_id)

      contact_participation = contacts.build(:role_id => Event.participation_code('Contact'))
      contact_entity = contact_participation.build_secondary_entity
      contact_entity.entity_type = "person"
      contact_entity.build_person_temp( person )

      next if attributes.values_blank?
      el = contact_entity.telephone_entities_locations.build(
        :entity_location_type_id => code,
        :primary_yn_id => ExternalCode.yes_id,
        :location_type_id => Code.telephone_location_type_id)
      el.build_location.telephones.build(attributes)
    end
  end

  def existing_contact_attributes=(contact_attributes)
    contacts.reject(&:new_record?).each do |contact|
      attributes = contact_attributes[contact.secondary_entity.person_temp.id.to_s]

      # Which entity_location to edit is passed along in the (hidden) attribute contact_phone_id
      el_id = attributes.delete(:contact_phone_id).to_i if attributes

      if attributes && !attributes.values_blank?
        person = {}
        person[:last_name] = attributes.delete(:last_name)
        person[:first_name] = attributes.delete(:first_name)
        person[:disposition_id] = attributes.delete(:disposition_id)

        contact.secondary_entity.person_temp.attributes = person

        # They may be adding a phone number to an existing contact who did not lready have one
        if el_id == 0 || el_id.blank?
          code = attributes.delete(:entity_location_type_id)
          next if attributes.values_blank?
          el = contact.secondary_entity.telephone_entities_locations.build(
            :entity_location_type_id => code,
            :primary_yn_id => ExternalCode.yes_id,
            :location_type_id => Code.telephone_location_type_id)
          el.build_location.telephones.build(attributes)
        else
          # Don't just find it, loop through the association array looking for it
          contact.secondary_entity.telephone_entities_locations.each do |tel_el|
            if tel_el.id == el_id
              # If the contact had a phone number and the user blanked it out, delete it
              if attributes.values_blank?
                tel_el.destroy
                tel_el.location.destroy
              else
                tel_el.entity_location_type_id = attributes.delete(:entity_location_type_id)
                tel_el.location.telephones.last.attributes = attributes
              end
              break
            end
          end
        end
      else
        # Soft delete the contact event (which should always be there despite the conditional)
        contact.participating_event.soft_delete if contact.participating_event
        # Remove the participation pointing at the entity
        contacts.delete(contact)
      end
    end
  end

  def new_note_attributes=(attributes)
    # There can only be one new note
    return if attributes.values_blank?
    note = notes.build(attributes)
    note.user = User.current_user
  end  
  
  def existing_note_attributes=(notes_attributes)
    # existing notes can't be deleted or edited, but they can be marked as struck through
    notes.reject(&:new_record?).each do |note|
      attributes = notes_attributes[note.id.to_s]
      note.struckthrough = attributes[:struckthrough] if attributes
    end
  end

  # This method is used to add user selected fields and, if the timing is just right,
  # auto-assigned fields to an event.
  def add_forms(forms_to_add)
    forms_to_add = [forms_to_add] unless forms_to_add.respond_to?('each')

    # Accepts either form_ids or forms.  If forms, convert to form_ids
    forms_to_add.map! { |form_ref| if form_ref.is_a? Form then form_ref.id else form_ref.to_i end } 

    # Remember if this event has forms persisted with it already
    event_has_saved_forms = self.form_references.size > 0

    # This will assign potentially viable forms to form_references, but not if there are some already there
    self.get_investigation_forms

    # Get the form ids that are associated with this event (either from the database or via get_investigation_forms)
    existing_or_viable_form_ids = self.form_references.map { |ref| ref.form_id }

    if event_has_saved_forms
      # Lets be sure that there are no dups between the desired forms and the existing forms
      forms_to_add -= existing_or_viable_form_ids
    else
      # Persist all passed in forms plus all viable forms
      forms_to_add += existing_or_viable_form_ids
    end
    Event.transaction do
      unless (forms_to_add.all? do |form_id|
            # Legitimate form?  If not, will throw RecordNotFound that caller should catch.
            Form.find(form_id)
            self.form_references.create(:form_id => form_id)
          end)
        raise "Unable to process new forms"
      end
    end
  end

  def soft_delete
    Event.transaction do
      transactional_soft_delete
    end
  end

  def transactional_soft_delete
    if self.deleted_at.nil?
      self.deleted_at = Time.new
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
    attributes.each { |key, value| answers.build(:question_id => key, :check_box_answer => value[:check_box_answer]) }
  end
  
  def new_radio_buttons=(attributes)
    attributes.each { |key, value| answers.build(:question_id => key, :radio_button_answer => value[:radio_button_answer], :export_conversion_value_id => value[:export_conversion_value_id]) }
  end  

  def get_or_initialize_answer(question_id)
    answers.detect(lambda { Answer.new(:question_id => question_id) } ) { |answer_object| answer_object.question_id == question_id }
  end

  def active_jurisdiction
    self.jurisdiction
  end

  def active_jurisdiction=(attributes)
    self.jurisdiction = Participation.new(:role_id => Event.participation_code('Jurisdiction')) if self.jurisdiction.nil?
    self.jurisdiction.attributes = attributes
  end

  # Debt: Consolidate sanitize_sql_for_conditions calls where possible
  def self.find_by_criteria(*args)
    options = args.extract_options!
    fulltext_terms = []
    where_clause = " p3.type != 'PlaceEvent'"
    order_by_clause = "p3.type DESC, p3.primary_last_name, p3.primary_first_name ASC"
    issue_query = false
    
    if !options[:event_type].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += " p3.type = '" + sanitize_sql_for_conditions(["%s", options[:event_type]]) + "'"
    end

    if !options[:disease].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += " p3.disease_id = " + sanitize_sql_for_conditions(["%s", options[:disease]])
    end
    
    if !options[:gender].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?

      if options[:gender] == "Unspecified"
        # Debt:  The 'AND event_id IS NOT NULL' is kind of a hack.  Will do until this query is examined more closely.
        where_clause += "p3.primary_birth_gender_id IS NULL AND event_id IS NOT NULL"
      else
        where_clause += "p3.primary_birth_gender_id = " + sanitize_sql_for_conditions(["%s", options[:gender]])
      end
      
    end
    
    if !options[:event_status].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "p3.event_status = '" + sanitize_sql_for_conditions(["%s", options[:event_status]]) + "'"
    end
    
    if !options[:city].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "a.city ILIKE '" + sanitize_sql_for_conditions(["%s", options[:city]]) + "%'"
    end

    if !options[:county].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "a.county_id = " + sanitize_sql_for_conditions(["%s", options[:county]])
    end
    
    if !options[:jurisdiction_id].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "p3.jurisdiction_id = " + sanitize_sql_for_conditions(["%s", options[:jurisdiction_id]])
    else
      where_clause += " AND " unless where_clause.empty?
      allowed_jurisdiction_ids =  User.current_user.jurisdictions_for_privilege(:view_event).collect   {|j| j.entity_id}
      allowed_jurisdiction_ids += User.current_user.jurisdictions_for_privilege(:update_event).collect {|j| j.entity_id}
      allowed_ids_str = allowed_jurisdiction_ids.uniq!.inject("") { |str, entity_id| str += "#{entity_id}," }
      where_clause += "p3.jurisdiction_id IN (" + allowed_ids_str.chop + ")"
    end
    
    # Debt: The UI shows the user a format to use. Something a bit more robust
    # could be in place.
    if !options[:birth_date].blank?
      if (options[:birth_date].size == 4 && options[:birth_date].to_i != 0)
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += "EXTRACT(YEAR FROM p3.primary_birth_date) = '" + sanitize_sql_for_conditions(["%s",options[:birth_date]]) + "'"
      else
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += "p3.primary_birth_date = '" + sanitize_sql_for_conditions(["%s", options[:birth_date]]) + "'"
      end
      
    end
    
    # Problem?
    if !options[:entered_on_start].blank? || !options[:entered_on_end].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      
      if !options[:entered_on_start].blank? && !options[:entered_on_end].blank?
        where_clause += "p3.created_at BETWEEN '" + sanitize_sql_for_conditions(["%s", options[:entered_on_start]]) + 
          "' AND '" + sanitize_sql_for_conditions(options[:entered_on_end]) + "'"
      elsif !options[:entered_on_start].blank?
        where_clause += "p3.created_at > '" + sanitize_sql_for_conditions(["%s", options[:entered_on_start]]) + "'"
      else
        where_clause += "p3.created_at < '" + sanitize_sql_for_conditions(["%s", options[:entered_on_end]]) + "'"
      end
     
    end
    
    # Debt: The sql_term building is duplicated in Person. Where do you
    # factor out code common to models? Also, it may be that we don't 
    # need two different search avenues (CMR and People).
    if !options[:sw_last_name].blank? || !options[:sw_first_name].blank?
    
      issue_query = true
      
      where_clause += " AND " unless where_clause.empty?
      
      if !options[:sw_last_name].blank?
        where_clause += "p3.primary_last_name ILIKE '" + sanitize_sql_for_conditions(["%s", options[:sw_last_name]]) + "%'"
      end
      
      if !options[:sw_first_name].blank?
        where_clause += " AND " unless options[:sw_last_name].blank?
        where_clause += "p3.primary_first_name ILIKE '" + sanitize_sql_for_conditions(["%s", options[:sw_first_name]]) + "%'"
      end
      
    elsif !options[:fulltext_terms].blank?
      issue_query = true
      soundex_codes = []
      raw_terms = options[:fulltext_terms].split(" ")
      
      raw_terms.each do |word|
        soundex_code = Text::Soundex.soundex(word)
        soundex_codes << soundex_code.downcase unless soundex_code.nil?
        fulltext_terms << sanitize_sql_for_conditions(["%s", word]).sub(",", "").downcase
      end
      
      fulltext_terms << soundex_codes unless soundex_codes.empty?
      sql_terms = fulltext_terms.join(" | ")
      
      where_clause += " AND " unless where_clause.empty?
      where_clause += "vector @@ to_tsquery('#{sql_terms}')"
      order_by_clause = " ts_rank(vector, '#{sql_terms}') DESC, last_name, first_name ASC;"
      
    end
    
    query = "
    SELECT 
           p3.event_id, 
           p3.type, 
           p3.primary_entity_id AS entity_id,
           p3.primary_first_name AS first_name,
           p3.primary_middle_name AS middle_name,
           p3.primary_last_name AS last_name,
           p3.primary_birth_date AS birth_date,
           p3.disease_id,
           p3.disease_name,
           p3.primary_record_number AS record_number,
           p3.event_onset_date,
           p3.primary_birth_gender_id AS birth_gender_id,
           p3.event_status,
           p3.jurisdiction_id,
           p3.jurisdiction_name, 
           p3.vector,
           p3.created_at,
           p3. deleted_at,
           c.code_description AS gender,
           a.city, 
           co.code_description AS county
    FROM 
           ( SELECT 
                    p1.event_id, p1.type, p1.primary_entity_id, p1.vector, p1.primary_first_name, p1.primary_middle_name, p1.primary_last_name,
                    p1.primary_birth_date, p1.disease_id, p1.disease_name, p1.primary_record_number, p1.event_onset_date, p1.primary_birth_gender_id,
                    p1.event_status, p1.created_at, p1.deleted_at, p2.jurisdiction_id, p2.jurisdiction_name
             FROM 
                    ( SELECT 
                             p.event_id as event_id, people.vector as vector, people.entity_id as primary_entity_id, people.first_name as primary_first_name,
                             people.last_name as primary_last_name, people.middle_name as primary_middle_name, people.birth_date as primary_birth_date,
                             d.id as disease_id, d.disease_name as disease_name, record_number as primary_record_number, event_onset_date as event_onset_date,
                             people.birth_gender_id as primary_birth_gender_id,
                             e.event_status as event_status, e.type as type,
                             e.created_at, e.deleted_at
                      FROM   
                             events e
                      INNER JOIN  
                             participations p on p.event_id = e.id
                      INNER JOIN 
                             ( SELECT DISTINCT ON
                                      (entity_id) *
                               FROM
                                      people
                               ORDER BY entity_id, created_at DESC
                              ) AS people
                                ON people.entity_id = p.primary_entity_id
                      LEFT OUTER JOIN 
                            ( SELECT DISTINCT ON 
                                     (event_id) * 
                              FROM   
                                     disease_events 
                              ORDER BY event_id, created_at DESC
                            ) AS disease_events 
                              ON disease_events.event_id = e.id
                      LEFT OUTER JOIN 
                            diseases d ON disease_events.disease_id = d.id
                      WHERE  
                            p.primary_entity_id IS NOT NULL 
                      AND   p.secondary_entity_id IS NULL
                    ) AS p1
             FULL OUTER JOIN 
                   (
                     SELECT 
                            secondary_entity_id AS jurisdiction_id, 
                            j.name AS jurisdiction_name,
                            p.event_id AS event_id
                     FROM   
                            events e
                     INNER JOIN 
                            participations p ON p.event_id = e.id
                     LEFT OUTER JOIN 
                            codes c ON c.id = p.role_id
                     LEFT OUTER JOIN 
                           ( SELECT DISTINCT ON 
                                    (entity_id) entity_id, 
                                    name 
                             FROM 
                                    places 
                             ORDER BY 
                                    entity_id, created_at DESC
                           ) AS j ON j.entity_id = p.secondary_entity_id
                     WHERE  c.code_description = 'Jurisdiction'
                   ) AS p2 ON p1.event_id = p2.event_id
           ) AS p3
    LEFT OUTER JOIN 
           ( SELECT DISTINCT ON 
                    (entity_id) entity_id, location_id
             FROM
                    entities_locations, external_codes
             WHERE
                    external_codes.code_name = 'yesno'  
             AND
                    external_codes.the_code = 'Y'
             AND
                    entities_locations.primary_yn_id = external_codes.id
             ORDER BY
                    entity_id, entities_locations.created_at DESC
           ) AS el ON el.entity_id = p3.primary_entity_id
    LEFT OUTER JOIN 
           locations l ON l.id = el.location_id
    LEFT OUTER JOIN 
           addresses a ON a.location_id = l.id
    LEFT OUTER JOIN 
           external_codes co ON co.id = a.county_id
    LEFT OUTER JOIN 
           external_codes c ON c.id = p3.primary_birth_gender_id
    WHERE 
           #{where_clause}
    ORDER BY 
           #{order_by_clause}"
    
    find_by_sql(query) if issue_query
  end

  def get_investigation_forms
    if self.form_references.empty?
      return if self.disease.nil? || self.disease.disease_id.blank?
      i = -1
      Form.get_published_investigation_forms(self.disease.disease_id, self.active_jurisdiction.secondary_entity_id, self.class.name.underscore).each do |form|
        self.form_references[i += 1] = FormReference.new(:form_id => form.id)
      end
    end
  end

  def cache_old_attributes
    @old_attributes = self.attributes
    @nested_attributes = {}
    nested_attribute_paths.merge(ibis_nested_attribute_paths).each do |key, call_path|
      @nested_attributes[key] = safe_call_chain(*call_path)
    end
  end

  def old_attributes
    @old_attributes
  end

  def nested_attributes
    @nested_attributes
  end
   
  # after find doesn't work unless its part of the actual class.
  def after_find
    self.cache_old_attributes
  end

  def set_primary_entity_on_secondary_participations
    self.participations.each do |participation|
      if participation.primary_entity_id.nil?
        participation.update_attribute('primary_entity_id', self.patient.primary_entity.id)
      end
    end
  end

  private
  
  def set_record_number
    customer_number_sequence = 'events_record_number_seq'
    record_number = connection.select_value("select nextval('#{customer_number_sequence}')")
    self.record_number = record_number
  end
  
  def generate_mmwr
    epi_dates = { :onsetdate => disease.nil? ? nil : disease.disease_onset_date, 
      :diagnosisdate => disease.nil? ? nil : disease.date_diagnosed, 
      #      :labresultdate => @lab.lab_result.nil? ? nil : @lab.lab_result.lab_test_date, 
      :firstreportdate => self.first_reported_PH_date }
    mmwr = Mmwr.new(epi_dates)
    
    self.MMWR_week = mmwr.mmwr_week
    self.MMWR_year = mmwr.mmwr_year
  end

  def set_event_onset_date
    self.event_onset_date = Date.today
  end

  def save_associations
    contacts.each do |contact|
      contact.secondary_entity.person_temp.save(false)
      contact.secondary_entity.telephone_entities_locations.each do |el|
        # Unless the phone number was destroyed, save it
        unless el.frozen?
          el.save(false)
          el.location.telephones.each { |t| t.save(false) }
        end
      end
    end
    disease.save(false) unless disease.nil?
    answers.each { |answer| answer.save(false) }
    if !answers.empty? && form_references.empty?
      self.get_investigation_forms
      self.form_references.each { |form_ref| form_ref.event_id = self.id; form_ref.save(false) }
    end
    notes.each { |note| note.save(false) }
    # Jurisdictions don't need to be saved on edit.  They can only be set by create.  After that routing is used.
  end

end
