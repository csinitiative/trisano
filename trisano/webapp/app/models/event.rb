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

class Event < ActiveRecord::Base
  include Blankable
  include TaskFilter
  include Export::Cdc::EventRules
  
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
  belongs_to :state_case_status, :class_name => 'ExternalCode'
  belongs_to :outbreak_associated, :class_name => 'ExternalCode'

  has_one :jurisdiction

  has_many :associated_jurisdictions,
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :all_jurisdictions, :class_name => 'Participation',
    :conditions => ["participations.type IN ('Jurisdiction', 'AssociatedJurisdiction')"],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_one :disease_event, :order => 'created_at ASC', :dependent => :delete

  belongs_to :event_queue
  has_many :form_references
  has_many :answers, :autosave => true
  has_many :tasks, :order => 'due_date ASC'
  has_many :notes, :order => 'updated_at ASC', :dependent => :destroy
  has_many :attachments, :order => 'updated_at DESC'

  has_many :participations

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
  
  has_many :encounter_child_events, :class_name => 'EncounterEvent', :foreign_key => 'parent_id' do
    def active(reload=false)
      @active_encounters = nil if reload
      @active_encounters ||= EncounterEvent.find(:all, :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id])
    end
  end

  has_many :child_events, :class_name => 'Event', :foreign_key => 'parent_id' do
    def active(reload=false)
      @active_events = nil if reload
      @active_events ||= Event.find(:all, :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id])
    end
  end
  
  # These are morbidity events that have been 'elevated' from contacts of this event
  has_many :morbidity_child_events, :class_name => 'MorbidityEvent', :foreign_key => 'parent_id' do
    def active(reload=false)
      @active_siblings = nil if reload
      @active_siblings ||= MorbidityEvent.find(:all, :conditions => ["parent_id = ? AND deleted_at IS NULL", proxy_owner.id])
    end
  end

  has_one :address

  belongs_to :parent_event, :class_name => 'Event', :foreign_key => 'parent_id'

  accepts_nested_attributes_for :jurisdiction, 
    :reject_if => proc { |attrs| attrs["secondary_entity_id"].blank? } 
  accepts_nested_attributes_for :disease_event, 
    :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  accepts_nested_attributes_for :contact_child_events,
    :allow_destroy => true,
    :reject_if => proc { |attrs| check_contact_attrs(attrs) }
  accepts_nested_attributes_for :place_child_events,
    :allow_destroy => true,
    :reject_if => proc { |attrs| check_place_attrs(attrs) }
  accepts_nested_attributes_for :encounter_child_events,
    :allow_destroy => true,
    :reject_if => proc { |attrs| check_encounter_attrs(attrs) }
  accepts_nested_attributes_for :notes,
    :reject_if => proc { |attrs| !attrs.has_key?('note') || attrs['note'].blank?}
  accepts_nested_attributes_for :address, 
    :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  def self.check_contact_attrs(attrs)
    person_empty = attrs["interested_party_attributes"]["person_entity_attributes"]["person_attributes"].all? { |k, v| v.blank? }
    phones_empty = attrs["interested_party_attributes"]["person_entity_attributes"]["telephones_attributes"].all? { |k, v| v.all? { |k, v| v.blank? } }
    disposition_empty = attrs["participations_contact_attributes"].all? { |k, v| v.blank? }

    (person_empty && phones_empty && disposition_empty) ? true : false
  end

  def self.check_place_attrs(attrs)
    place_empty = attrs["interested_place_attributes"]["primary_entity_id"].nil? && attrs["interested_place_attributes"]["place_entity_attributes"]["place_attributes"].all? { |k, v| v.blank? }
    exposure_empty = attrs["participations_place_attributes"].all? { |k, v| v.blank? }

    (place_empty && exposure_empty) ? true : false
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

  validates_date :event_onset_date
  validates_existence_of :investigator, :allow_nil => true
  validates_length_of :event_name, :maximum => 100, :allow_blank => true
  validates_length_of :acuity, :maximum => 255, :allow_blank => true
  validates_length_of :other_data_1, :maximum => 255, :allow_blank => true
  validates_length_of :other_data_2, :maximum => 255, :allow_blank => true
  validates_length_of :outbreak_name, :maximum => 255, :allow_blank => true

  cattr_reader :per_page
  @@per_page = 25

  def self.states
    Routing::State.states
  end

  states['NEW'] = Routing::State.new({ 
      :transitions => ["ASGD-LHD"],
      :action_phrase => nil,
      :priv_required => :create_event,
      :description => "New",
      :state_code => "NEW",
      :note_text => '"Event created for jurisdiction #{self.primary_jurisdiction.name}."'
    })
  states['ASGD-LHD'] = Routing::State.new({
      :transitions => ["ASGD-LHD", "ACPTD-LHD", "RJCTD-LHD"],
      :action_phrase => nil,
      :priv_required => :route_event_to_any_lhd,
      :description => "Assigned to Local Health Dept.",
      :state_code => "ASGD-LHD",
      :note_text => '"Routed to jurisdiction #{self.primary_jurisdiction.name}."'
    })
  states['ACPTD-LHD'] = Routing::State.new({
      :transitions => ["ASGD-LHD", "ASGD-INV"],
      :action_phrase => "Accept",
      :priv_required => :accept_event_for_lhd,
      :description => "Accepted by Local Health Dept.",
      :state_code => "ACPTD-LHD",
      :note_text => '"Accepted by #{self.primary_jurisdiction.name}."'
    })
  states['RJCTD-LHD'] = Routing::State.new({
      :transitions => ["ASGD-LHD"],
      :action_phrase => "Reject",
      :priv_required => :accept_event_for_lhd,
      :description => "Rejected by Local Health Dept.",
      :state_code => "RJCTD-LHD",
      :note_text => '"Rejected by #{self.primary_jurisdiction.name}."'
    })
  states['ASGD-INV'] = Routing::State.new({
      :transitions => ["ASGD-LHD", "UI", "RJCTD-INV", "ASGD-INV"],
      :action_phrase => "Route to queue",
      :priv_required => :route_event_to_investigator,
      :description => "Assigned to Investigator",
      :state_code => "ASGD-INV",
      :note_text => 'if self.investigator then "Routed to investigator #{self.investigator.best_name}." else "Routed to queue #{self.event_queue.queue_name}." end'
    })
  states['UI'] = Routing::State.new({
      :transitions => ["ASGD-LHD", "IC", "ASGD-INV"],
      :action_phrase => "Accept",
      :priv_required => :accept_event_for_investigation,
      :description => "Under Investigation",
      :state_code => "UI",
      :note_text => '"Accepted for investigation."'
    })
  states['RJCTD-INV'] = Routing::State.new({
      :transitions => ["ASGD-LHD", "ASGD-INV"],
      :action_phrase => "Reject",
      :priv_required => :accept_event_for_investigation,
      :description => "Rejected by Investigator",
      :state_code => "RJCTD-INV",
      :note_text => '"Rejected for investigation."'
    })
  states['IC'] = Routing::State.new({
      :transitions => ["ASGD-LHD", "APP-LHD", "RO-MGR", "ASGD-INV"],
      :action_phrase => "Mark Investigation Complete",
      :priv_required => :investigate_event ,
      :description => "Investigation Complete",
      :state_code => "IC",
      :note_text => '"Completed investigation."'
    })
  states['APP-LHD'] = Routing::State.new({
      :transitions => ["ASGD-LHD", "CLOSED", "RO-STATE"],
      :action_phrase => "Approve",
      :priv_required => :approve_event_at_lhd ,
      :description => "Approved by LHD",
      :state_code => "APP-LHD",
      :note_text => '"Approved at #{self.primary_jurisdiction.name}."'
    })
  states['RO-MGR'] = Routing::State.new({
      :transitions => ["ASGD-LHD", "IC", "ASGD-INV"],
      :action_phrase => "Reopen",
      :priv_required => :approve_event_at_lhd ,
      :description => "Reopened by Manager",
      :state_code => "RO-MGR",
      :note_text => '"Reopened by #{self.primary_jurisdiction.name} manager."'
    })
  states['CLOSED'] = Routing::State.new({
      :transitions => [],
      :action_phrase => "Approve",
      :priv_required => :approve_event_at_state ,
      :description => "Approved by State",
      :state_code => "CLOSED",
      :note_text => '"Approved by State."'
    })
  states['RO-STATE']  = Routing::State.new({
      :transitions => ["ASGD-LHD", "APP-LHD", "RO-MGR", "ASGD-INV"],
      :action_phrase => "Reopen",
      :priv_required => :approve_event_at_state ,
      :description => "Reopened by State",
      :state_code => "RO-STATE",
      :note_text => '"Reopened by State."'
    })

  @@ordered_states = []
  @@ordered_states << states['NEW']
  @@ordered_states << states['ASGD-LHD']
  @@ordered_states << states['ACPTD-LHD']
  @@ordered_states << states['RJCTD-LHD']
  @@ordered_states << states['ASGD-INV']
  @@ordered_states << states['UI']
  @@ordered_states << states['RJCTD-INV']
  @@ordered_states << states['IC']
  @@ordered_states << states['APP-LHD']
  @@ordered_states << states['RO-MGR']
  @@ordered_states << states['CLOSED']
  @@ordered_states << states['RO-STATE']

  class << self

    def action_phrases_for(*state_names)
      state_names.collect do |state_name|
        if states[state_name].action_phrase
          OpenStruct.new(:phrase => states[state_name].action_phrase, :state => state_name)
        end
      end.compact
    end

    def get_state_keys
      Event.states.keys
    end

    def get_states_and_descriptions
      @@ordered_states.map { |state| OpenStruct.new( :state => state.state_code, :description => state.description) }
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

    def active_ibis_records(start_date, end_date)
      # New: Record has not been sent to IBIS, record has a disease, record is confirmed, probable, or suspect, record has not been soft-deleted
      Event.find_by_sql(" SELECT e.id AS event_id FROM events e, disease_events d, external_codes c
                          WHERE e.deleted_at IS NULL
                          AND d.event_id = e.id
                          AND d.disease_id IS NOT NULL 
                          AND e.state_case_status_id = c.id
                          AND c.code_name = 'case'
                          AND c.the_code IN ('C', 'P', 'S') 
                          AND ((e.created_at BETWEEN '#{start_date}' AND '#{end_date}') OR (e.ibis_updated_at BETWEEN '#{start_date}' AND '#{end_date}'))
        ")
    end
      
    def deleted_ibis_records(start_date, end_date)
      # New: Record has been sent to IBIS, record has been updated, record has a disease, record is not confirmed, probable, or suspect OR record has been soft-deleted
      Event.find_by_sql(" SELECT e.id AS event_id FROM events e, disease_events d, external_codes c
                          WHERE e.sent_to_ibis = TRUE
                          AND d.event_id = e.id
                          AND d.disease_id IS NOT NULL 
                          AND e.state_case_status_id = c.id
                          AND c.code_name = 'case'
                          AND (c.the_code NOT IN ('C', 'P', 'S') OR (e.deleted_at BETWEEN '#{start_date}' AND '#{end_date}'))
                          AND e.ibis_updated_at BETWEEN '#{start_date}' AND '#{end_date}'
        ")
    end

    def exportable_ibis_records(start_date, end_date)
      active_ibis_records(start_date, end_date) + deleted_ibis_records(start_date, end_date)
    end

    def reset_ibis_status(events)
      event_ids = events.compact.collect {|record| record.id if record.id}
      Event.update_all('sent_to_ibis=true', ['id IN (?)', event_ids])
    end

    def generate_event_search_where_clause(options)
      fulltext_terms = []
      where_clause = " participations.type != 'PlaceEvent'"
      order_by_clause = "participations.type DESC, last_name, first_name ASC"
      issue_query = false

      if !options[:diseases].blank?
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += " disease_id IN (" + options[:diseases].collect{|id| sanitize_sql_for_conditions(["%s", id])}.join(',') + ")"
      end

      if !options[:gender].blank?
        issue_query = true
        where_clause += " AND " unless where_clause.empty?

        if options[:gender] == "Unspecified"
          # Debt:  The 'AND event_id IS NOT NULL' is kind of a hack.  Will do until this query is examined more closely.
          where_clause += "birth_gender_id IS NULL"
        else
          where_clause += "birth_gender_id = " + sanitize_sql_for_conditions(["%s", options[:gender]])
        end
      end

      if !options[:event_status].blank?
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += "event_status = '" + sanitize_sql_for_conditions(["%s", options[:event_status]]) + "'"
      end

      if !options[:city].blank?
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += "city ILIKE '" + sanitize_sql_for_conditions(["%s", options[:city]]) + "%'"
      end

      if !options[:county].blank?
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += "county_id = " + sanitize_sql_for_conditions(["%s", options[:county]])
      end

      if !options[:jurisdiction_id].blank?
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += "(jurisdictions_events.secondary_entity_id = " + sanitize_sql_for_conditions(["%s", options[:jurisdiction_id]])
        where_clause += " OR associated_jurisdictions_events.secondary_entity_id = " + sanitize_sql_for_conditions(["%s", options[:jurisdiction_id]]) + ")"
      else
        where_clause += " AND " unless where_clause.empty?
        allowed_jurisdiction_ids =  User.current_user.jurisdictions_for_privilege(:view_event).collect   {|j| j.entity_id}
        allowed_jurisdiction_ids += User.current_user.jurisdictions_for_privilege(:update_event).collect {|j| j.entity_id}
        allowed_ids_str = allowed_jurisdiction_ids.uniq!.inject("") { |str, entity_id| str += "#{entity_id}," }
        where_clause += "(jurisdictions_events.secondary_entity_id IN (" + allowed_ids_str.chop + ")"
        where_clause += " OR associated_jurisdictions_events.secondary_entity_id IN (" + allowed_ids_str.chop + ") )"
      end

      # Debt: The UI shows the user a format to use. Something a bit more robust
      # could be in place.
      if !options[:birth_date].blank?
        if (options[:birth_date].size == 4 && options[:birth_date].to_i != 0)
          issue_query = true
          where_clause += " AND " unless where_clause.empty?
          where_clause += "EXTRACT(YEAR FROM birth_date) = '" + sanitize_sql_for_conditions(["%s",options[:birth_date]]) + "'"
        else
          issue_query = true
          where_clause += " AND " unless where_clause.empty?
          where_clause += "birth_date = '" + sanitize_sql_for_conditions(["%s", options[:birth_date]]) + "'"
        end
      end

      # Problem?
      if !options[:entered_on_start].blank? || !options[:entered_on_end].blank?
        issue_query = true
        where_clause += " AND " unless where_clause.empty?

        if !options[:entered_on_start].blank? && !options[:entered_on_end].blank?
          where_clause += "events.created_at BETWEEN '" + sanitize_sql_for_conditions(["%s", options[:entered_on_start]]) +
            "' AND '" + sanitize_sql_for_conditions(options[:entered_on_end]) + "'"
        elsif !options[:entered_on_start].blank?
          where_clause += "events.created_at > '" + sanitize_sql_for_conditions(["%s", options[:entered_on_start]]) + "'"
        else
          where_clause += "events.created_at < '" + sanitize_sql_for_conditions(["%s", options[:entered_on_end]]) + "'"
        end
      end

      # Debt: The sql_term building is duplicated in Person. Where do you
      # factor out code common to models? Also, it may be that we don't
      # need two different search avenues (CMR and People).
      if !options[:sw_last_name].blank? || !options[:sw_first_name].blank?

        issue_query = true

        where_clause += " AND " unless where_clause.empty?

        if !options[:sw_last_name].blank?
          where_clause += "last_name ILIKE '" + sanitize_sql_for_conditions(["%s", options[:sw_last_name]]) + "%'"
        end

        if !options[:sw_first_name].blank?
          where_clause += " AND " unless options[:sw_last_name].blank?
          where_clause += "first_name ILIKE '" + sanitize_sql_for_conditions(["%s", options[:sw_first_name]]) + "%'"
        end

      elsif !options[:fulltext_terms].blank?
        issue_query = true
        soundex_codes = []
        raw_terms = options[:fulltext_terms].split(" ")

        raw_terms.each do |word|
          soundex_codes << word.to_soundex.downcase unless word.to_soundex.nil?
          fulltext_terms << sanitize_sql_for_conditions(["%s", word]).sub(",", "").downcase
        end

        fulltext_terms << soundex_codes unless soundex_codes.empty?
        sql_terms = fulltext_terms.join(" | ")

        where_clause += " AND " unless where_clause.empty?
        where_clause += "vector @@ to_tsquery('#{sql_terms}')"
        order_by_clause = " ts_rank(vector, '#{sql_terms}') DESC, last_name, first_name ASC;"
      end
      [where_clause, order_by_clause, issue_query]
    end
  end

  def under_investigation?
    ['UI', 'IC', 'RO-MGR'].include?(self.event_status)
  end

  def current_state
    Event.states[self.event_status]
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
    safe_call_chain(:jurisdiction, :place_entity, :place)
  end

  def secondary_jurisdictions
    associated_jurisdictions.collect { |j| j.place_entity.place }
  end

  def jurisdiction_of_investigation
    primary_jurisdiction
  end

  def disease
    self.disease_event
  end

  def add_note(message, note_type="administrative")
    self.notes << Note.new(:note => message, :note_type => note_type)
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
                                             
  # This method is used to add user selected forms and, if the timing is just right,
  # auto-assigned forms to an event.
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
      # Persist all passed in forms plus all viable forms while clearing form_references of any new records added above
      self.form_references.clear
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
      self.add_note("Event deleted")
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

  def self.find_by_criteria(*args)
    options = args.extract_options!

    return if !options[:event_type].blank? && !['MorbidityEvent', 'ContactEvent'].include?(options[:event_type]) 

    where_clause, order_by_clause, issue_query = Event.generate_event_search_where_clause(options)

    if issue_query || !options[:event_type].blank?
      event_types = options[:event_type].blank? ? [MorbidityEvent, ContactEvent] : [ Kernel.const_get(options[:event_type]) ]
      event_types.inject([]) do | results, event_type|
        results += event_type.find(:all,
          :include => [ { :interested_party => { :person_entity => :person } },
            :address,
            :disease_event,
            :jurisdiction,
            :associated_jurisdictions
          ],
          :conditions => where_clause,
          :order => order_by_clause)
        results
      end
    end
  end

  def self.search_by_name(name)
    soundex_codes = []
    fulltext_terms = []
    raw_terms = name.split(" ")

    raw_terms.each do |word|
      soundex_codes << word.to_soundex.downcase unless word.to_soundex.nil?
      fulltext_terms << sanitize_sql(["%s", word]).sub(",", "").downcase
    end

    fulltext_terms << soundex_codes unless soundex_codes.empty?
    sql_terms = fulltext_terms.join(" | ")

    where_clause = "people.vector @@ to_tsquery('#{sql_terms}')"
    order_by_clause = " ts_rank(people.vector, '#{sql_terms}') DESC, people.last_name, people.first_name ASC;"

    options = { :include => [ { :interested_party => { :person_entity => :person } }, :disease_event ],
                :conditions => where_clause,
                :order => order_by_clause }
    MorbidityEvent.all(options) + ContactEvent.all(options)
  end

  def get_investigation_forms
    if self.form_references.empty?
      return [] if self.disease_event.nil? || self.disease_event.disease_id.blank?
      i = -1
      Form.get_published_investigation_forms(self.disease_event.disease_id, self.jurisdiction.secondary_entity_id, self.class.name.underscore).each do |form|
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

  # Indicates whether an event supports tasks. Generally used by the UI in shared partials
  # to determine whether task-specific layout should be included.
  #
  # Sub-classes can either override this method to return true or use a declarative option:
  #
  # supports :tasks
  def supports_tasks?
    false
  end

  # Indicates whether an event supports attachements. Generally used by the UI in shared partials
  # to determine whether attachment-specific layout should be included.
  #
  # Sub-classes can either override this method to return true or use a declarative option:
  #
  # supports :attachments
  def supports_attachments?
    false
  end

  class << self
    def supports(functionality)
      return unless [:tasks, :attachments].include?(functionality)
      supports_method = %Q{
        def supports_#{functionality.to_s}?
          true
        end
      }
      class_eval(supports_method)
    end
  end

  
  private

  def set_record_number
    customer_number_sequence = 'events_record_number_seq'
    record_number = connection.select_value("select nextval('#{customer_number_sequence}')")
    self.record_number = record_number
  end
  
  def set_event_onset_date
    self.event_onset_date = Date.today
  end

end
