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

    def search_by_name_and_birth_date(name, bdate, options={})
      find_by_name_bdate(name, bdate, options)
    end

    def search_by_name(name)
      find_by_name_bdate(name)
    end

    def find_by_name_bdate(name, bdate=nil, options={})
      # Throw an exception early if birth date not parseable
      if bdate.is_a? String
        parsed = ParseDate.parsedate(bdate)
        raise 'Invalid birthdate' unless parsed[0] and parsed[1] and parsed[2]
      end

      soundex_codes = []
      fulltext_terms = []

      sql_terms = nil
      unless name.blank?
        raw_terms = name.split(" ")

        raw_terms.each do |word|
          soundex_codes << word.to_soundex.downcase unless word.to_soundex.nil?
          fulltext_terms << sanitize_sql(["%s", word]).sub(",", "").downcase
        end

        fulltext_terms << soundex_codes unless soundex_codes.empty?
        sql_terms = fulltext_terms.join(" | ")
      end

      where_clause = ""
      where_clause += "people.vector @@ to_tsquery('#{sql_terms}')" if sql_terms
      if bdate
        where_clause += " AND" if sql_terms
        where_clause += " people.birth_date = '#{sanitize_sql(["%s", bdate])}'" if bdate
        # If they typed in a name and birth date allow for empty birth dates too.
        where_clause += " OR people.birth_date IS NULL" if sql_terms
      end

      order_by_clause = ""
      order_by_clause << "people.birth_date, " if bdate
      order_by_clause << "ts_rank(people.vector, to_tsquery('#{sql_terms}')) DESC," if sql_terms
      order_by_clause << " events.id DESC"

      select = <<-SQL
        SELECT events.id AS id,
               events.event_onset_date AS event_onset_date,
               events."type" AS event_type,
               events.deleted_at AS deleted_at,
               entities.id AS entity_id,
               people.first_name AS first_name,
               people.last_name AS last_name,
               people.birth_date AS birth_date,
               external_codes.code_description AS birth_gender,
               diseases.disease_name AS disease_name,
               jurisdiction_entities.id AS jurisdiction_entity_id,
               jurisdiction_places.short_name AS jurisdiction_short_name,
               sec_juris.secondary_jurisdiction_entity_ids AS secondary_jurisdictions
        FROM events
             INNER JOIN participations ON participations.event_id = events.id
                  AND (participations."type" = 'InterestedParty' )
             LEFT OUTER JOIN entities ON entities.id = participations.primary_entity_id
                  AND (entities.entity_type = 'PersonEntity' )
             LEFT OUTER JOIN people ON people.entity_id = entities.id
             LEFT OUTER JOIN external_codes ON people.birth_gender_id = external_codes.id
                  AND (external_codes.code_name = 'gender')
             LEFT OUTER JOIN disease_events ON disease_events.event_id = events.id
             LEFT OUTER JOIN diseases ON disease_events.disease_id = diseases.id
             INNER JOIN participations AS jurisdictions ON jurisdictions.event_id = events.id
                  AND (jurisdictions.type = 'Jurisdiction')
             INNER JOIN entities AS jurisdiction_entities ON jurisdiction_entities.id = jurisdictions.secondary_entity_id
                  AND (jurisdiction_entities.entity_type = 'PlaceEntity')
             INNER JOIN places AS jurisdiction_places ON jurisdiction_places.entity_id = jurisdiction_entities.id
             LEFT JOIN (
                SELECT
                    events.id AS event_id,
                    ARRAY_ACCUM(p.secondary_entity_id) AS secondary_jurisdiction_entity_ids
                FROM
                    events
                    LEFT JOIN participations p
                        ON (p.event_id = events.id AND p.type = 'AssociatedJurisdiction')
                GROUP BY events.id
            ) sec_juris
                ON (sec_juris.event_id = events.id)
        WHERE (#{where_clause})
              AND ( (events."type" = 'MorbidityEvent' OR events."type" = 'ContactEvent') )
        ORDER BY #{order_by_clause}
      SQL
      
      if options[:page_size] && options[:page]
        self.paginate_by_sql [select], :page => options[:page], :per_page => options[:page_size]
      else
        self.find_by_sql select
      end
    end

    def get_allowed_queues(query_queues)
      system_queues = EventQueue.queues_for_jurisdictions(User.current_user.jurisdiction_ids_for_privilege(:view_event))
      queue_ids = system_queues.collect { |system_queue| query_queues.include?(system_queue.queue_name) ? system_queue.id : nil }.compact
      queue_names = system_queues.collect { |system_queue| query_queues.include?(system_queue.queue_name) ? system_queue.queue_name : nil }.compact
      return queue_ids, queue_names
    end

    def get_states_and_descriptions
      new.states.collect do |state|
        OpenStruct.new :workflow_state => state, :description => state_description(state)
      end
    end

    def state_description(state)
      new.states(state).meta[:description] || state.to_s.titleize
    end

    def find_all_for_filtered_view(options = {})
      where_clause = "(events.type = 'MorbidityEvent' OR events.type = 'ContactEvent')"

      states = options[:states] || []
      if states.empty?
        where_clause << " AND workflow_state != 'not_routed'"
      else
        where_clause << " AND workflow_state IN (#{ states.map { |s| "'#{s}'" }.join(',') })"
      end
    
      if options[:diseases]
        where_clause << " AND disease_id IN (#{options[:diseases].join(',')})"
      end

      if options[:investigators]
        where_clause << " AND investigator_id IN (#{options[:investigators].join(',')})"
      end

      if options[:queues]
        queue_ids, queue_names = get_allowed_queues(options[:queues])

        if queue_ids.empty?
          raise 'No queue ids returned'
        else
          where_clause << " AND event_queue_id IN (#{queue_ids.join(',')})"
        end
      end

      if options[:do_not_show_deleted]
        where_clause << " AND events.deleted_at IS NULL"
      end

      order_by_clause = case options[:order_by]
      when 'patient'
        "last_name, first_name, disease_name, jurisdiction_short_name, workflow_state"
      when 'disease'
        "disease_name, last_name, first_name, jurisdiction_short_name, workflow_state"
      when 'jurisdiction'
        "jurisdiction_short_name, last_name, first_name, disease_name, workflow_state"
      when 'status'
        # Fortunately the event status code stored in the DB and the text the user sees mostly correspond to the same alphabetical ordering"
        "workflow_state, last_name, first_name, disease_name, jurisdiction_short_name"
      else
        "events.updated_at DESC"
      end

      users_view_jurisdictions = User.current_user.jurisdiction_ids_for_privilege(:view_event)

      query_options = options.reject { |k, v| [:page, :order_by, :set_as_default_view].include?(k) }
      User.current_user.update_attribute('event_view_settings', query_options) if options[:set_as_default_view] == "1"

      # Hard coding the query to wring out some speed.
      real_select = <<-SQL
        SELECT events.id AS id,
            events.event_onset_date AS event_onset_date,
            events.type AS type,
            events.deleted_at AS deleted_at,
            events.workflow_state as workflow_state,
            events.investigator_id as investigator_id,
            events.event_queue_id as event_queue_id,
            entities.id AS entity_id,
            people.first_name AS first_name,
            people.last_name AS last_name,
            diseases.disease_name AS disease_name,
            jurisdiction_entities.id AS jurisdiction_entity_id,
            jurisdiction_places.short_name AS jurisdiction_short_name,
            sec_juris.secondary_jurisdiction_names AS secondary_jurisdictions,
            CASE
               WHEN users.given_name IS NOT NULL AND users.given_name != '' THEN users.given_name
               WHEN users.last_name IS NOT NULL AND users.last_name != '' THEN trim(BOTH ' ' FROM users.first_name || ' ' || users.last_name)
               WHEN users.user_name IS NOT NULL AND users.user_name != '' THEN users.user_name
               ELSE users.uid
            END AS investigator_name,
            event_queues.queue_name as queue_name
        FROM events
            INNER JOIN participations ON participations.event_id = events.id
                AND (participations.type = 'InterestedParty' )
            INNER JOIN entities ON entities.id = participations.primary_entity_id
                AND (entities.entity_type = 'PersonEntity' )
            INNER JOIN people ON people.entity_id = entities.id

            LEFT OUTER JOIN disease_events ON disease_events.event_id = events.id
            LEFT OUTER JOIN diseases ON disease_events.disease_id = diseases.id

            INNER JOIN participations AS jurisdictions ON jurisdictions.event_id = events.id
                AND (jurisdictions.type = 'Jurisdiction')
                AND (jurisdictions.secondary_entity_id IN (#{users_view_jurisdictions.join(',')}))
            INNER JOIN entities AS jurisdiction_entities ON jurisdiction_entities.id = jurisdictions.secondary_entity_id
                AND (jurisdiction_entities.entity_type = 'PlaceEntity')
            INNER JOIN places AS jurisdiction_places ON jurisdiction_places.entity_id = jurisdiction_entities.id

            LEFT JOIN (
                SELECT
                    events.id AS event_id,
                    ARRAY_ACCUM(places.short_name) AS secondary_jurisdiction_names
                FROM
                    events
                    LEFT JOIN participations p
                        ON (p.event_id = events.id AND p.type = 'AssociatedJurisdiction')
                    LEFT JOIN entities pe 
                        ON pe.id = p.secondary_entity_id
                    LEFT JOIN places 
                        ON places.entity_id = pe.id
                GROUP BY events.id
            ) sec_juris ON (sec_juris.event_id = events.id)

            LEFT JOIN users ON users.id = events.investigator_id
            LEFT JOIN event_queues ON event_queues.id = events.event_queue_id

      SQL

      # The paginate plugin needs a total row count.  Normally it would simply re-execute the main query wrapped in a count(*).
      # But in an effort to shave off some more time, we will provide a row count with this simplified version of the main
      # query.
      count_select = <<-SQL
        SELECT COUNT(*)
        FROM events
            INNER JOIN participations AS jurisdictions ON jurisdictions.event_id = events.id
                AND (jurisdictions.type = 'Jurisdiction')
                AND (jurisdictions.secondary_entity_id IN (#{users_view_jurisdictions.join(',')}))

            LEFT OUTER JOIN disease_events ON disease_events.event_id = events.id
            LEFT OUTER JOIN diseases ON disease_events.disease_id = diseases.id

            LEFT JOIN users ON users.id = events.investigator_id
            LEFT JOIN event_queues ON event_queues.id = events.event_queue_id

      SQL

      count_select << "WHERE (#{where_clause})\n" unless where_clause.blank?
      row_count = Event.count_by_sql(count_select)

      real_select << "WHERE (#{where_clause})\n" unless where_clause.blank?
      real_select << "ORDER BY #{order_by_clause}"

      find_options = { 
        :page          => options[:page],
        :total_entries => row_count
      }
      find_options[:per_page] = options[:per_page] if options[:per_page].to_i > 0

      Event.paginate_by_sql(real_select, find_options)

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
    primary_changed = false

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
        primary_changed = true
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

      if self.disease
        applicable_forms = Form.get_published_investigation_forms(self.disease_event.disease_id, self.jurisdiction.secondary_entity_id, self.class.name.underscore)
        self.add_forms(applicable_forms)
      end
      
      reload # Any existing references to this object won't see these changes without this
    end
    return primary_changed
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
    # Commented out becuase UT is using queues not as a place for investigators to pull work from, but to route a case
    # to a 'program' (department, e.g. STDs).  And then a program manager routes to an individual.  I'm  not deleting
    # this code, 'cause I'd like to ressurect it some day.
    #
    # when :assigned_to_queue
    #   attrs[:investigator_id] = nil
    # when :assigned_to_investigator
    #   attrs[:event_queue_id] = nil
    end

    self.update_attributes(attrs)
  end

  def add_labs_from_staged_message(staged_message)
    raise ArgumentError, "#{staged_message.class} is not a valid staged message" unless staged_message.respond_to?('message_header')

    lab_attributes = { "place_entity_attributes"=> { "place_attributes"=> { "name"=> staged_message.message_header.sending_facility } },
                        "lab_results_attributes" => {}
    }

    obr = staged_message.observation_request
    i = 0
    obr.tests.each do | obx |
      specimen_source = ExternalCode.find_by_sql("SELECT id FROM external_codes WHERE code_name = 'specimen' AND code_description ILIKE '#{obr.specimen_source}'").first
      specimen_source_id = specimen_source ? specimen_source['id'] : nil
      result_hash = {
        "test_type"          => obx.test_type,
        "collection_date"    => obr.collection_date,
        "lab_test_date"      => obx.observation_date,
        "reference_range"    => obx.reference_range,
        "lab_result_text"    => obx.result,
        "specimen_source_id" => specimen_source_id
      }
      lab_attributes["lab_results_attributes"][i.to_s] = result_hash
      i += 1
    end
    self.labs_attributes = [ lab_attributes ]
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
