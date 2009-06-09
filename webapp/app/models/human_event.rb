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

class HumanEvent < Event
  include Export::Cdc::HumanEvent  

  validates_length_of :parent_guardian, :maximum => 255, :allow_blank => true

  validates_numericality_of :age_at_onset,
    :allow_nil => true,
    :greater_than_or_equal_to => 0,
    :only_integer => true,
    :message => 'is negative. This is usually caused by an incorrect onset date or birth date.'

  before_validation_on_create :set_age_at_onset
  before_validation_on_update :set_age_at_onset

  has_one :interested_party, :foreign_key => "event_id"

  has_many :labs,
    :foreign_key => "event_id",
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :hospitalization_facilities,
    :foreign_key => "event_id",
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :diagnostic_facilities,
    :foreign_key => "event_id",
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :clinicians,
    :foreign_key => "event_id",
    :order => 'created_at ASC',
    :dependent => :destroy

  belongs_to :participations_contact
  belongs_to :participations_encounter

  accepts_nested_attributes_for :interested_party
  accepts_nested_attributes_for :hospitalization_facilities, 
    :allow_destroy => true, 
    :reject_if => proc { |attrs| attrs["secondary_entity_id"].blank? && attrs["hospitals_participation_attributes"].all? { |k, v| v.blank? } } 
  accepts_nested_attributes_for :clinicians, 
    :allow_destroy => true, 
    :reject_if => proc { |attrs| attrs.has_key?("person_entity_attributes") && attrs["person_entity_attributes"]["person_attributes"].all? { |k, v| if v == 'clinician' then true else v.blank? end } }
  accepts_nested_attributes_for :diagnostic_facilities, 
    :allow_destroy => true, 
    :reject_if => proc { |attrs| attrs.has_key?("place_entity_attributes") && attrs["place_entity_attributes"]["place_attributes"].all? { |k, v| v.blank? } } 
  accepts_nested_attributes_for :labs, 
    :allow_destroy => true, 
    :reject_if => proc { |attrs| rewrite_attrs(attrs) }
  accepts_nested_attributes_for :participations_contact, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  accepts_nested_attributes_for :participations_encounter, :reject_if => proc { |attrs| attrs.all? { |k, v| ((k == "user_id") ||  (k == "encounter_location_type")) ? true : v.blank? } }

  class << self
    def rewrite_attrs(attrs)
      entity_attrs = attrs["place_entity_attributes"]
      lab_attrs = entity_attrs["place_attributes"]
      return true if (lab_attrs.all? { |k, v| v.blank? } && attrs["lab_results_attributes"].all? { |k, v| v.all? { |k, v| v.blank? } })

      # If there's a lab with the same name already in the database, use that instead.
      existing_labs = Place.labs_by_name(lab_attrs["name"])
      unless existing_labs.empty?
        attrs["secondary_entity_id"] = existing_labs.first.entity_id
        attrs.delete("place_entity_attributes")
      else
        lab_attrs["place_type_ids"] = [Code.lab_place_type_id]
      end

      return false
    end

    def search_by_name(name)
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
      order_by_clause = " ts_rank(people.vector, to_tsquery('#{sql_terms}')) DESC, people.last_name, people.first_name, entities.id, events.event_onset_date ASC;"

      options = { :include => [ { :interested_party => { :person_entity => :person } }, :disease_event ],
        :conditions => where_clause,
        :order => order_by_clause }

      # This may or may not be a Rails bug, but in order for HumanEvent to know that MorbidityEvent and ContactEvent are
      # its descendents, and thus generate the proper where clause, Rails needs to have 'seen' these classes at least
      # once, so do something innocuous in order to ensure this.
      MorbidityEvent.object_id; ContactEvent.object_id
      self.all(options)
    end

    def get_allowed_queues(query_queues)
      system_queues = EventQueue.queues_for_jurisdictions(User.current_user.jurisdiction_ids_for_privilege(:view_event))
      queue_ids = system_queues.collect { |system_queue| query_queues.include?(system_queue.queue_name) ? system_queue.id : nil }.compact
      queue_names = system_queues.collect { |system_queue| query_queues.include?(system_queue.queue_name) ? system_queue.queue_name : nil }.compact
      return queue_ids, queue_names
    end


    def find_all_for_filtered_view(options = {})
      # We can't :include the associations 'all_jurisdictions' _and_ 'patient', cause the :conditions on them make AR generate ambiguous SQL, so echoing here.
      # TODO is the above still true since we've gone all STI
      conditions = ["jurisdictions.type = 'Jurisdiction' AND patients.type = 'InterestedParty'"]
      conjunction = "AND"

      states = options[:states] || []
      unless states.empty?
        conditions[0] += " #{conjunction} workflow_state IN (?)"
        conditions << states
      end
    
      if options[:diseases]
        conditions[0] += " #{conjunction} disease_id IN (?)"
        conditions << options[:diseases]
      end

      if options[:investigators]
        conditions[0] += " #{conjunction} investigator_id IN (?)"
        conditions << options[:investigators]
      end

      if options[:queues]
        queue_ids, queue_names = get_allowed_queues(options[:queues])

        if queue_ids.empty?
          raise 'No queue ids returned'
        else
          conditions[0] += " #{conjunction} event_queue_id IN (?)"
          conditions << queue_ids
        end
      end

      if options[:do_not_show_deleted]
        conditions[0] += " AND deleted_at IS NULL"
      end

      conditions[0] += " AND (events.type = 'MorbidityEvent' OR events.type = 'ContactEvent')"

      order_by = case options[:order_by]
      when 'patient'
        "people.last_name, people.first_name, diseases.disease_name, places.name, events.workflow_state"
      when 'disease'
        "diseases.disease_name, people.last_name, people.first_name, places.name, events.workflow_state"
      when 'jurisdiction'
        "places.name, people.last_name, people.first_name, diseases.disease_name, events.workflow_state"
      when 'status'
        # Fortunately the event status code stored in the DB and the text the user sees mostly correspond to the same alphabetical ordering"
        "events.workflow_state, people.last_name, people.first_name, diseases.disease_name, places.name"
      else
        "events.updated_at DESC"
      end

      from = "(	SELECT DISTINCT events.* from events " +
        "LEFT JOIN participations jurisdictions ON jurisdictions.event_id = events.id " +
        "WHERE jurisdictions.secondary_entity_id IN (#{User.current_user.jurisdiction_ids_for_privilege(:view_event).join(',')}) " +
        ") as events "
        
      # Similar to above comment, we now need to explicitly spell out the joins.  By the way, we're doing this join just so we can sort by different fields
      joins = "LEFT JOIN participations jurisdictions ON jurisdictions.event_id = events.id
               LEFT JOIN entities place_entities ON place_entities.id = jurisdictions.secondary_entity_id
               LEFT JOIN places ON places.entity_id = place_entities.id

               LEFT JOIN participations patients ON patients.event_id = events.id
               LEFT JOIN entities person_entities ON person_entities.id = patients.primary_entity_id
               LEFT JOIN people ON people.entity_id = person_entities.id"

      if options[:diseases]
        joins << " LEFT JOIN disease_events ON disease_events.event_id = events.id"
      else
        joins << " LEFT OUTER JOIN disease_events ON disease_events.event_id = events.id"
      end
      joins << " LEFT JOIN diseases ON disease_events.disease_id = diseases.id"

      query_options = options.reject { |k, v| [:page, :order_by, :set_as_default_view].include?(k) }
      User.current_user.update_attribute('event_view_settings', query_options) if options[:set_as_default_view] == "1"

      find_options = {
        :joins => joins,
        :conditions => conditions,
        :order => order_by,
        :from => from,
        # :select => select,
        :page => options[:page]
      }
      find_options[:per_page] = options[:per_page] if options[:per_page].to_i > 0

      Event.paginate(:all, find_options)
    rescue Exception => ex
      logger.error ex
      raise ex
    end

  end

  def lab_results
    @results ||= (
      results = []
      labs.each do |lab|
        lab.lab_results.each do |lab_result|
          results << lab_result
        end
      end
      results
    )
  end

  def definitive_lab_result
    # CDC calculations expect one lab result.  Choosing the most recent to be it
    return nil if lab_results.empty?
    self.lab_results.sort_by { |lab_result| lab_result.lab_test_date || Date.parse("01/01/0000") }.last
  end

  def set_primary_entity_on_secondary_participations
    self.participations.each do |participation|
      if participation.primary_entity_id.nil?
        participation.update_attribute('primary_entity_id', self.interested_party.person_entity.id)
      end
    end
  end

  def party
    @party ||= self.safe_call_chain(:interested_party, :person_entity, :person)
  end

  # Perform a shallow (event_coponents = nil) or deep (event_components != nil) copy of an event.
  # Can't simply do a single clone or a series of clones because there are some attributes we need
  # to leave behind, certain relationships that need to be severed, and we need to make a copy of 
  # the address for longitudinal purposes.
  def copy_event(new_event, event_components)
    super(new_event, event_components)

    org_entity = self.interested_party.person_entity
    new_event.build_interested_party(:primary_entity_id => org_entity.id)
    entity_address = org_entity.addresses.find(:first, :conditions => 'event_id IS NOT NULL', :order => 'created_at DESC')
    new_event.address = entity_address ? entity_address.clone : nil
    new_event.imported_from_id = self.imported_from_id
    new_event.parent_guardian = self.parent_guardian
    new_event.other_data_1 = self.other_data_1
    new_event.other_data_2 = self.other_data_2
    
    return unless event_components   # Shallow, demographics only, copy

    # If event_components is not nil, then continue on with a deep copy

    if event_components.include?("clinical")
      self.hospitalization_facilities.each do |h|
        new_h = new_event.hospitalization_facilities.build(:secondary_entity_id => h.secondary_entity_id)
        if attrs = h.hospitals_participation.attributes
          attrs.delete('participation_id')
          new_h.build_hospitals_participation(attrs)
        end
      end

      self.interested_party.treatments.each do |t|
        attrs = t.attributes
        attrs.delete('participation_id')
        new_event.interested_party.treatments.build(attrs)
      end

      if rf = self.interested_party.risk_factor
        attrs = self.interested_party.risk_factor.attributes
        attrs.delete('participation_id')
        new_event.interested_party.build_risk_factor(attrs)
      end

      self.clinicians.each do |c|
        new_event.clinicians.build(:secondary_entity_id => c.secondary_entity_id)
      end

      self.diagnostic_facilities.each do |d|
        new_event.diagnostic_facilities.build(:secondary_entity_id => d.secondary_entity_id)
      end
    end

    if event_components.include?("lab")
      self.labs.each do |l|
        lab = new_event.labs.build(:secondary_entity_id => l.secondary_entity_id)
        l.lab_results.each do |lr|
          attrs = lr.attributes
          attrs.delete('participation_id')
          lab.lab_results.build(attrs)
        end
      end
    end

    if event_components.include?("notes")
    end
  end

  def state_description
    current_state.meta[:description] || state.to_s.titleize
  end

  def route_to_jurisdiction(jurisdiction, secondary_jurisdiction_ids=[], note="")
    jurisdiction_id = jurisdiction.to_i if jurisdiction.respond_to?('to_i')
    jurisdiction_id = jurisdiction.id if jurisdiction.is_a? Entity
    jurisdiction_id = jurisdiction.entity_id if jurisdiction.is_a? Place

    transaction do
      # Handle the primary jurisdiction
      #
      # Do nothing if the passed-in jurisdiction is the current jurisdiction
      unless jurisdiction_id == self.jurisdiction.secondary_entity_id
        proposed_jurisdiction = PlaceEntity.find(jurisdiction_id) # Will raise an exception if record not found
        raise "New jurisdiction is not a jurisdiction" unless Place.jurisdictions.include?(proposed_jurisdiction.place)
        self.jurisdiction.update_attribute("secondary_entity_id", jurisdiction_id)
        self.add_note note
      end

      # Handle secondary jurisdictions
      existing_secondary_jurisdiction_ids = associated_jurisdictions.collect { |participation| participation.secondary_entity_id }

      # if an existing secondary jurisdiction ID is not in the passed-in ids, delete
      (existing_secondary_jurisdiction_ids - secondary_jurisdiction_ids).each do |id_to_delete|
        associated_jurisdictions.delete(associated_jurisdictions.find_by_secondary_entity_id(id_to_delete))
      end

      # if an passed-in ID is not in the existing secondary jurisdiction IDs, add
      (secondary_jurisdiction_ids - existing_secondary_jurisdiction_ids).each do |id_to_add|
        associated_jurisdictions.create(:secondary_entity_id => id_to_add)
      end

      # Add any new forms to this event  I guess we'll keep any old ones for now.
      if self.disease
        forms_in_use = self.form_references.map { |ref| ref.form_id }
        Form.get_published_investigation_forms(self.disease_event.disease_id, self.jurisdiction.secondary_entity_id, self.class.name.underscore).each do |form|
          self.form_references.create(:form_id => form.id) unless forms_in_use.include?(form.id)
        end
      end
      
      reload # Any existing references to this object won't see these changes without this
    end
  end  
  
  # transitions that are allowed to be rendered by this user
  def allowed_transitions
    current_state.events.select do |event|
      priv_required = current_state.events(event).meta[:priv_required]
      j_id = primary_jurisdiction.entity_id
      User.current_user.is_entitled_to_in?(priv_required, j_id)
    end
  end

  def undo_workflow_side_effects
    attrs = {
      :investigation_started_date => nil,
      :investigation_completed_LHD_date => nil,
      :review_completed_by_state_date => nil
    }
    case self.state
    when :assigned_to_lhd
      attrs[:investigator_id] = nil
      attrs[:event_queue_id]  = nil
    when :assigned_to_queue
      attrs[:investigator_id] = nil
    when :assigned_to_investigator
      attrs[:event_queue_id] = nil
    end

    self.update_attributes(attrs)
  end

  private

  def set_age_at_onset
    birthdate = safe_call_chain(:interested_party, :person_entity, :person, :birth_date)
    onset = onset_candidate_dates.compact.first
    self.age_info = AgeInfo.create_from_dates(birthdate, onset)    
  end

  def onset_candidate_dates
    dates = []
    dates << safe_call_chain(:disease_event, :disease_onset_date)
    dates << safe_call_chain(:disease_event, :date_diagnosed)
    collections = []
    test_dates = []
    self.labs.each do |l| 
      l.lab_results.collect{|r| collections << r.collection_date}
      l.lab_results.collect{|r| test_dates << r.lab_test_date}
    end
    dates << collections.compact.sort
    dates << test_dates.compact.sort
    dates << self.first_reported_PH_date
    dates << self.event_onset_date
    dates << self.created_at.to_date unless self.created_at.nil?
    dates.flatten
  end

end
