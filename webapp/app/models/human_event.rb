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

class HumanEvent < Event
  include Export::Cdc::HumanEvent
  extend NameAndBirthdateSearch

  validates_length_of :parent_guardian, :maximum => 255, :allow_blank => true

  validates_numericality_of :age_at_onset,
    :allow_nil => true,
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 120,
    :only_integer => true,
    :message => :bad_range

  validates_date :event_onset_date

  before_validation :set_onset_date, :set_age_at_onset

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
    :reject_if => :place_and_canonical_address_blank?
  accepts_nested_attributes_for :labs,
    :allow_destroy => true,
    :reject_if => proc { |attrs| reject_or_rewrite_attrs(attrs) }
  accepts_nested_attributes_for :participations_contact, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  accepts_nested_attributes_for :participations_encounter, :reject_if => proc { |attrs| attrs.all? { |k, v| ((k == "user_id") ||  (k == "encounter_location_type")) ? true : v.blank? } }

  after_save :associate_longitudinal_data

  class << self

    # Lab participations will either receive a place entity hash or a secondary_entity_id.
    #
    # Place entity hashes are received when the operation needs the flexibility to create
    # a new lab (place entity) in the system (automated staged messaging assignment).
    #
    # A secondary_entity_id will be received from drop-down select lists of labs in the UI.
    #
    # Both structures are inspected to determine nested-attribute rejection. If place
    # attributes are received, an attempt is made to reuse an existing entity to avoid
    # creating duplicates.
    def reject_or_rewrite_attrs(attrs)
      return true if (lab_place_attributes_blank?(attrs) && lab_result_attributes_blank?(attrs))
      rewrite_attributes_to_reuse_place_entities(attrs)
      return false
    end

    def lab_place_attributes_blank?(attrs)
      if attrs["place_entity_attributes"]
        return attrs["place_entity_attributes"]["place_attributes"].all? { |k, v| v.blank? }
      else
        return attrs["secondary_entity_id"].blank?
      end
    end

    def lab_result_attributes_blank?(attrs)
      attrs["lab_results_attributes"].all? { |k, v| v.reject{ |k, v| k == "position" }.all? { |k, v| v.blank? } }
    end

    def rewrite_attributes_to_reuse_place_entities(attrs)
      if attrs["place_entity_attributes"]
        place_attributes = attrs["place_entity_attributes"]["place_attributes"]
        existing_labs = Place.labs_by_name(place_attributes["name"])
        unless existing_labs.empty?
          attrs["secondary_entity_id"] = existing_labs.first.entity_id
          attrs.delete("place_entity_attributes")
        else
          place_attributes["place_type_ids"] = [Code.lab_place_type_id]
        end
      end
    end

    def get_allowed_queues(queues, jurisdiction_ids)
      EventQueue.queues_for_jurisdictions(jurisdiction_ids).all(:conditions => {:id => queues})
    end

    def get_states_and_descriptions
      new.states.collect do |state|
        OpenStruct.new :workflow_state => state, :description => state_description(state)
      end
    end

    def state_description(state)
      I18n.translate(state, :scope => [:workflow])
    end

    def find_all_for_filtered_view(options)
      users_view_jurisdictions = options[:view_jurisdiction_ids] || []
      return [] if users_view_jurisdictions.empty?

      where_clause = <<-SQL
        (events.type = 'MorbidityEvent' OR events.type = 'ContactEvent') AND
        (NOT diseases.sensitive OR diseases.sensitive IS NULL OR
         jurisdictions.secondary_entity_id || secondary_jurisdiction_ids
           && ARRAY[#{(options[:access_sensitive_jurisdiction_ids] || []).join(',')}]::integer[])
      SQL

      states = options[:states] || []
      if states.empty?
        where_clause << " AND workflow_state != 'not_routed'"
      else
        where_clause << " AND workflow_state IN (#{ states.map { |s| sanitize_sql_for_conditions(["'%s'", s]).untaint }.join(',') })"
      end

      if options[:diseases]
        where_clause << " AND disease_id IN (#{ options[:diseases].map { |d| sanitize_sql_for_conditions(["'%s'", d]).untaint }.join(',') })"
      end

      if options[:investigators]
        where_clause << " AND investigator_id IN (#{ options[:investigators].map { |i| sanitize_sql_for_conditions(["'%s'", i]).untaint }.join(',') })"
      end

      if options[:queues]
        queues = get_allowed_queues(options[:queues], users_view_jurisdictions)

        if queues.empty?
          raise(I18n.translate('no_queue_ids_returned'))
        else
          where_clause << " AND event_queue_id IN (#{ queues.map(&:id).join(',') })"
        end
      end

      if options[:do_not_show_deleted]
        where_clause << " AND events.deleted_at IS NULL"
      end

      order_direction = options[:order_direction].blank? ? 'ASC' : options[:order_direction]

      order_by_clause = case options[:order_by]
      when 'patient'
        "last_name #{order_direction}, first_name, disease_name, jurisdiction_short_name, workflow_state"
      when 'disease'
        "disease_name #{order_direction}, last_name, first_name, jurisdiction_short_name, workflow_state"
      when 'jurisdiction'
        "jurisdiction_short_name #{order_direction}, last_name, first_name, disease_name, workflow_state"
      when 'status'
        # Fortunately the event status code stored in the DB and the text the user sees mostly correspond to the same alphabetical ordering"
        "workflow_state #{order_direction}, last_name, first_name, disease_name, jurisdiction_short_name"
      when 'event_created'
        "events.created_at #{order_direction}, last_name, first_name, disease_name, jurisdiction_short_name, workflow_state"
      else
        "events.updated_at DESC"
      end

      users_view_jurisdictions_sanitized = users_view_jurisdictions.map do |j|
        sanitize_sql_for_conditions(["%d", j]).untaint
      end

      # Hard coding the query to wring out some speed.
      real_select = <<-SQL
        SELECT events.id AS id,
            events.event_onset_date AS event_onset_date,
            events.created_at AS created_at,
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
            event_queues.queue_name as queue_name,
            people.middle_name as middle_name
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
                AND (jurisdictions.secondary_entity_id IN (#{users_view_jurisdictions_sanitized.join(',')}))
            INNER JOIN entities AS jurisdiction_entities ON jurisdiction_entities.id = jurisdictions.secondary_entity_id
                AND (jurisdiction_entities.entity_type = 'PlaceEntity')
            INNER JOIN places AS jurisdiction_places ON jurisdiction_places.entity_id = jurisdiction_entities.id

            LEFT JOIN (
              SELECT
                event_id,
                CASE
                  WHEN secondary_jurisdiction_names_inner IS DISTINCT FROM ARRAY[NULL]::varchar[]
                    THEN secondary_jurisdiction_names_inner
                  ELSE ARRAY[]::varchar[]
                END AS secondary_jurisdiction_names,
                CASE
                  WHEN secondary_jurisdiction_ids_inner IS DISTINCT FROM ARRAY[NULL]::integer[]
                    THEN secondary_jurisdiction_ids_inner
                  ELSE ARRAY[]::integer[]
                END AS secondary_jurisdiction_ids
              FROM (
                SELECT
                    events.id AS event_id,
                    ARRAY_ACCUM(places.short_name) AS secondary_jurisdiction_names_inner,
                    ARRAY_ACCUM(pe.id) AS secondary_jurisdiction_ids_inner
                FROM
                    events
                    LEFT JOIN participations p
                        ON (p.event_id = events.id AND p.type = 'AssociatedJurisdiction')
                    LEFT JOIN entities pe
                        ON pe.id = p.secondary_entity_id
                    LEFT JOIN places
                        ON places.entity_id = pe.id
                GROUP BY events.id
              ) sec_juris_inner
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

            LEFT JOIN (
              SELECT
                event_id,
                CASE
                  WHEN secondary_jurisdiction_ids_inner IS DISTINCT FROM ARRAY[NULL]::integer[]
                    THEN secondary_jurisdiction_ids_inner
                  ELSE ARRAY[]::integer[]
                END AS secondary_jurisdiction_ids
              FROM (
                SELECT
                    events.id AS event_id,
                    ARRAY_ACCUM(p.secondary_entity_id) AS secondary_jurisdiction_ids_inner
                FROM
                    events
                    LEFT JOIN participations p
                        ON (p.event_id = events.id AND p.type = 'AssociatedJurisdiction')
                GROUP BY events.id
              ) sec_juris_inner
            ) sec_juris ON (sec_juris.event_id = events.id)

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

  def definitive_lab_date
    labs.collect do |l|
      l.lab_results.collect do |r|
        r.collection_date || r.lab_test_date
      end
    end.flatten.compact.sort.first
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

  def copy_from_person(person)
    self.suppress_validation(:first_reported_PH_date)
    self.build_jurisdiction
    self.build_interested_party
    self.jurisdiction.secondary_entity = (User.current_user.jurisdictions_for_privilege(:create_event).first || Place.unassigned_jurisdiction).entity
    self.interested_party.primary_entity_id = person.id
    self.interested_party.person_entity = person
    self.address = person.canonical_address
  end

  # Perform a shallow (event_coponents = nil) or deep (event_components != nil) copy of an event.
  # Can't simply do a single clone or a series of clones because there are some attributes we need
  # to leave behind, certain relationships that need to be severed, and we need to make a copy of
  # the address for longitudinal purposes.
  def copy_event(new_event, event_components)
    super(new_event, event_components)

    org_entity = self.interested_party.person_entity
    new_event.build_interested_party(:primary_entity_id => org_entity.id)
    entity_address = org_entity.addresses.find(:first, :conditions => ['event_id = ?', self.id], :order => 'created_at DESC')
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
        unless h.hospitals_participation.nil?
          if attrs = h.hospitals_participation.attributes
            attrs.delete('participation_id')
            new_h.build_hospitals_participation(attrs)
          end
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
  end

  def update_from_params(event_params)

    if !self.try(:disease_event).nil? and event_params.has_key?('disease_event_attributes')
      event_params['disease_event_attributes']['id'] = self.disease_event.id
    end

    self.attributes = event_params

  end

  def state_description
    I18n.t(state, :scope => [:workflow])
  end

  # Debt: some stuff here gets written to the database, and some still
  # requires the event to be saved.
  def route_to_jurisdiction(jurisdiction, secondary_jurisdiction_ids=[], note="")
    return false unless valid?
    primary_changed = false

    jurisdiction_id = jurisdiction.to_i if jurisdiction.respond_to?('to_i')
    jurisdiction_id = jurisdiction.id if jurisdiction.is_a? Entity
    jurisdiction_id = jurisdiction.entity_id if jurisdiction.is_a? Place

    transaction do
      # Handle the primary jurisdiction
      #
      # Do nothing if the passed-in jurisdiction is the current jurisdiction
      unless jurisdiction_id == self.jurisdiction.secondary_entity_id
        proposed_jurisdiction = PlaceEntity.jurisdictions.find(jurisdiction_id)
        raise(I18n.translate('new_jurisdiction_is_not_jurisdiction')) unless proposed_jurisdiction
        self.jurisdiction.update_attribute(:place_entity, proposed_jurisdiction)
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
      next if priv_required.nil?
      j_id = jurisdiction.secondary_entity_id
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
    end

    self.update_attributes(attrs)
  end

  def add_labs_from_staged_message(staged_message)
    raise(ArgumentError, I18n.translate('not_a_valid_staged_message', :staged_message => staged_message.class)) unless staged_message.respond_to?('message_header')

    # All tests have a scale type.  The scale type is well known and is part of the standard LOINC code data given in the SCALE_TYP
    # field. TriSano keeps the scale type in the loinc_codes table scale column.
    #
    # There are four scale types that we care about: ordinal (Ord: one of X), nominal (Nom: a string), quantitative (Qn: a number),
    # and ordinal or quantitative (OrdQn).
    #
    # An ordinal test result has values such as Positive or Reactive.  E.g. the lab was positive for HIV
    #
    # A quantitative test result has a value such as 100 or .5, which when combined with the units field gives a meaningful result.
    # E.g, the lab showed a hemoglobin count of 13.0 Gm/Dl.
    #
    # A nominal test result has a string.  In TriSano we are currently making the assumption that this is an organism name.
    # E.g the blood culture showed the influenza virus.
    #
    # An ordinal/quantiative test is either an ordinal string or a number
    #
    # These three principal (not including OrdQn) types of test results are, ideally, mapped to three different fields:
    #
    # Ord -> test_result_id
    # Qn  -> result_value
    # Nom -> organism_id
    #
    # In the case or Ord and Nom, if the value can't be mapped because the provided value does not match TriSano values,
    # e.g., the ordinal value is "Affirmative" instead of "Positive", then the result is placed in the result_value field,
    # rather than not mapping it at all.  This has the side effect of making an OrdQn the same as an Ord.
    #
    # In addition to organisms specified directly for nominal tests, ordinal and quantitative tests can have organisms too.
    # TriSano maintains a loinc code to organism relationship in the database

    # Set the lab name
    @lab_attributes = { "place_entity_attributes"=> { "place_attributes"=> { "name"=> staged_message.lab_name } },
      "lab_results_attributes" => {}
    }

    # Create one lab result per OBX segment
    i = 0
    @diseases = Set.new

    # country
    per_message_comments = ''
    unless staged_message.patient.address_country.blank?
      per_message_comments = "#{I18n.translate :country}: #{staged_message.patient.address_country}"
    end

    pv1 = staged_message.pv1
    orc = staged_message.common_order
    find_or_build_clinician(orc.clinician_last_name, orc.clinician_first_name, orc.clinician_phone_type, orc.clinician_telephone) unless orc.nil? or orc.clinician_last_name.blank?

    find_or_build_clinician(staged_message.pv1.attending_doctor[0], staged_message.pv1.attending_doctor[1]) unless pv1.nil? or pv1.attending_doctor.blank?

    find_or_build_clinician(staged_message.pv1.consulting_doctor[0], staged_message.pv1.consulting_doctor[1]) unless pv1.nil? or pv1.consulting_doctor.blank?

    staged_message.observation_requests.each do |obr|
      find_or_build_clinician(obr.clinician_last_name, obr.clinician_first_name, obr.clinician_phone_type, obr.clinician_telephone) unless obr.clinician_last_name.blank?

      @per_request_comments = per_message_comments.clone

      unless obr.specimen_id.blank?
        @per_request_comments += ", " unless @per_request_comments.blank?
        @per_request_comments += "#{I18n.translate :specimen_id}: #{obr.specimen_id}"
      end
      unless obr.specimen_source_2_5_1.blank? and obr.specimen_source_2_3_1.blank?
        @per_request_comments += ", " unless @per_request_comments.blank?
        @per_request_comments += "#{I18n.translate :specimen_source}: #{obr.specimen_source_2_5_1 || obr.specimen_source_2_3_1}"
      end

      obr.tests.each do |obx|
        set_loinc_scale_and_test_type obx
        if @scale_type.nil?
          self.add_note I18n.translate(:unknown_loinc_code, :loinc_code => obx.loinc_code)
          next
        end
        if @common_test_type.nil?
          self.add_note I18n.translate(:loinc_code_known_but_not_linked, :loinc_code => obx.loinc_code)
          next
        end
        add_lab_results staged_message, obr, obx, i
        i += 1
        self.add_note(I18n.translate("system_notes.elr_with_test_type_assigned", :test_type => obx.test_type, :locale => I18n.default_locale))
      end

      # Grab any diseases associated with this OBR
      loinc_code = LoincCode.find_by_loinc_code obr.test_performed
      loinc_code.diseases.each { |disease| @diseases << disease } if loinc_code and @diseases.blank?
    end

    unless i > 0
      # All OBX invalid
      raise StagedMessage::UnknownLoincCode, I18n.translate(:all_obx_unprocessable)
    end

    self.labs_attributes = [ @lab_attributes ]

    # Assign disease
    unless self.disease_event  # Don't overwrite disease if already there.
      case @diseases.size
      when 0
        staged_message.note = "#{staged_message.note} #{I18n.translate('no_loinc_code_maps_to_disease', :locale => I18n.default_locale)} "
      when 1
        disease_event = DiseaseEvent.new
        disease_event.disease = @diseases.to_a.first
        self.build_disease_event(disease_event.attributes)
        staged_message.note = "#{staged_message.note} #{I18n.translate('event_disease_set_to', :disease_name => disease_event.disease.disease_name, :locale => I18n.default_locale)} "
      else
        staged_message.note = "#{staged_message.note} #{I18n.translate('loinc_code_maps_to_multiple_diseases', :locale => I18n.default_locale)}" + @diseases.collect { |d| d.disease_name }.join('; ') + ". "
      end
    end

    unless staged_message.patient.primary_language.blank? or
      interested_party.nil? or
      interested_party.person_entity.person.primary_language_id
      staged_message.note ||= ''
      staged_message.note.sub! /\s+$/, ''
      staged_message.note += '. ' if staged_message.note.length > 0
      staged_message.note += I18n.translate :unmapped_language_code, :lang_code => staged_message.patient.primary_language, :locale => I18n.default_locale
    end

    unless staged_message.patient.dead_flag.blank? or disease_event.nil?
      code = case staged_message.patient.dead_flag
      when 'Y'
        ExternalCode.yes
      when 'N'
        ExternalCode.no
      end

      self.disease_event.died_id = code.id
    end

    if staged_message.common_order
      diagnostic_facility_name = staged_message.common_order.facility_name
      orc = staged_message.common_order

      unless diagnostic_facility_name.blank?
        place_entity = find_or_build_hospital(diagnostic_facility_name)

        place_entity.build_canonical_address(:street_number => orc.facility_address_street_no,
                            :street_name => orc.facility_address_street,
                            :city => orc.facility_address_city,
                            :state_id => orc.facility_address_trisano_state_id,
                            :postal_code => orc.facility_address_zip) unless orc.facility_address_empty?
        self.diagnostic_facilities.build :place_entity => place_entity
      end
    end

    unless disease_event.nil? or staged_message.pv1.blank? or
      staged_message.pv1.hospitalized_id.nil?
      hospitalized_id = staged_message.pv1.hospitalized_id
      self.disease_event.hospitalized_id = hospitalized_id

      if hospitalized_id == ExternalCode.yes.id
        facility_name = staged_message.pv2.facility_name if staged_message.pv2
        facility_name = staged_message.common_order.facility_name if facility_name.blank? and staged_message.common_order
        unless facility_name.blank?
          place_entity = find_or_build_hospital(facility_name)
          self.hospitalization_facilities.build :place_entity => place_entity
        end
      end
    end

    self.parent_guardian = staged_message.next_of_kin.parent_guardian.slice(0,2).join(', ') if staged_message.next_of_kin
  end

  def find_or_build_hospital(place_name)
    # assign the facility name, which requires finding or building a
    # place
    # do we already have this?
    place_entity = PlaceEntity.find(:first, 
                                    :conditions => [ "entities.deleted_at IS NULL AND LOWER(places.name) = ?", place_name.downcase ],
                                    :include => :place)

    # no? create it
    place_entity ||= PlaceEntity.new :place_attributes => {
      :name => place_name.titleize,
      :short_name => place_name.titleize
    }

    # make it a hospital
    place_code = Code.find_by_code_name_and_the_code('placetype', 'H')
    place_entity.place.place_types << place_code unless place_entity.place.place_types.include?(place_code)
    
    place_entity
  end

  def possible_treatments(reload=false)
    if reload or @possible_treatments.nil?
      options = { :select => 'distinct treatments.*', :order => 'treatment_name' }

      if disease = disease_event.try(:disease)
        options[:joins] = 'LEFT JOIN disease_specific_treatments b ON b.treatment_id = treatments.id'
        options[:conditions] = [<<-SQL, disease.id, self.id]
          (active = true AND disease_id = ?)
          OR treatments.id IN (
            SELECT treatment_id FROM participations_treatments a
              JOIN participations b ON b.id = a.participation_id AND b.event_id = ?)
        SQL
      else
        options[:conditions] = [<<-SQL, self.id]
          ("default" = true AND active = true)
          OR id IN (
            SELECT treatment_id FROM participations_treatments a
              JOIN participations b ON b.id = a.participation_id AND b.event_id = ?)
        SQL
      end
      @possible_treatments = Treatment.all(options)
    end
    @possible_treatments
  end

  private

  def add_lab_results(staged_message, obr, obx, i)
    comments = @per_request_comments.clone
    unless obx.abnormal_flags.blank?
      comments += ", " unless comments.blank?
      comments += "#{I18n.translate :abnormal_flags}: #{obx.abnormal_flags}"
    end

    comments += ", " unless comments.blank?
    comments += "Observation value: #{obx.obx_segment.observation_value}"

    result_hash = {}

    if @scale_type != "Nom"
      if @loinc_code.organism
        result_hash["organism_id"] = @loinc_code.organism.id
      else
        comments += ", " unless comments.blank?
        comments += "ELR Message: No organism mapped to LOINC code."
      end

      @loinc_code.diseases.each { |disease| @diseases << disease }
    end

    case @scale_type
    when "Ord", "OrdQn"
      obx_result = obx.result.gsub(/\s/, '').downcase
      if map_id = result_map[obx_result]
        result_hash["test_result_id"] = map_id
      else
        result_hash["result_value"] = obx.result
      end
    when "Qn"
      result_hash["result_value"] = obx.result
    when "Nom"
      # Try and find OBX-5 in the organism list, otherwise map to result_value
      # Eventually, we'll need to add more heuristics here for SNOMED etc.
      organism = Organism.first(:conditions => [ "organism_name ~* ?", '^'+obx.result+'$' ])
      if organism.blank?
        result_hash["result_value"] = obx.result
      else
        result_hash["organism_id"] = organism.id
        organism.diseases.each { |disease| @diseases << disease }
      end
    end

    begin
      lab_hash = {
        "test_type_id"       => @common_test_type.id,
        "collection_date"    => obr.collection_date,
        "lab_test_date"      => obx.test_date,
        "reference_range"    => obx.reference_range,
        "specimen_source_id" => obr.specimen_source.id,
        "staged_message_id"  => staged_message.id,
        "units"              => obx.units,
        "test_status_id"     => obx.trisano_status_id,
        "loinc_code"         => @loinc_code,
        "comment"            => comments
      }.merge!(result_hash)

      unless obr.filler_order_number.blank?
        lab_hash["accession_no"] = obr.filler_order_number
      end

      @lab_attributes["lab_results_attributes"][i.to_s] = lab_hash
    rescue Exception => error
      raise StagedMessage::BadMessageFormat, error.message
    end
  end

  def set_loinc_scale_and_test_type(obx)
    @loinc_code = LoincCode.find_by_loinc_code obx.loinc_code
    @scale_type = nil
    @common_test_type = nil

    if @loinc_code
      @scale_type = @loinc_code.scale.the_code
      @common_test_type = @loinc_code.common_test_type ||
        CommonTestType.find_by_common_name(obx.loinc_common_test_type)
    else
      # No :loinc_code entry.
      # Look at other OBX fields for hints to the scale and common
      # test type.
      @scale_type = obx.loinc_scale

      common_test_type_name = obx.loinc_common_test_type
      @common_test_type = CommonTestType.find_by_common_name(common_test_type_name) if common_test_type_name
    end
  end

  def result_map
    self.class.result_map
  end

  class << self
    def result_map
      # For ordinal tests, a single result has multiple synonyms, such as: "Positive", " Confirmed", " Detected", " Definitive"
      # So, first load the TriSano test_results, then bust out the slash-separated synonyms into hash keys whose value is the test_result ID.
      # I.e: { "Positive" => 1, "Confirmed" => 1, "Negative" => 2, ... }
      unless @result_map
        test_results = ExternalCode.find_all_by_code_name("test_result")
        @result_map = {}
        test_results.each do |result|
          result.code_description.split('/').each do |component|
            @result_map[component.gsub(/\s/, '').downcase] = result.id
          end if result.code_description
        end
      end
      @result_map
    end
  end

  def find_or_build_clinician(last_name, first_name, telephone_type=nil, telephone=nil)
    person_attributes = {
      :last_name   => last_name ,
      :first_name  => first_name,
      :person_type => 'clinician'
    }
    person = Person.first :conditions => person_attributes
    if person
      person_entity_id = person.person_entity.id
      @clinician = clinicians.to_a.find do |c|
        c.secondary_entity_id == person_entity_id
      end
      @clinician ||= clinicians.build :secondary_entity_id => person_entity_id
    else
      @clinician = clinicians.to_a.find do |c|
        c.person_entity.person.last_name == last_name && c.person_entity.person.first_name == first_name
      end
      @clinician ||= clinicians.build :person_entity_attributes => { :person_attributes => person_attributes }
    end

    unless telephone_type.nil? or telephone.blank? or telephone.all? {|x|x.nil?}
      area_code, number, extension = telephone
      telephone_attributes = {
        :entity_location_type => telephone_type,
        :area_code => area_code,
        :phone_number => number,
        :extension => extension
      }

      @clinician.person_entity.telephones.to_a.find do |t|
        t.entity_location_type == telephone_type &&
        t.area_code == area_code &&
        t.phone_number == number &&
        t.extension == extension
      end or @clinician.person_entity.telephones.build(telephone_attributes)
    end

    @clinician
  rescue
  end

  def set_age_at_onset
    birthdate = safe_call_chain(:interested_party, :person_entity, :person, :birth_date)
    self.age_info = AgeInfo.create_from_dates(birthdate, self.event_onset_date)
  end

  def set_onset_date
    self.event_onset_date = resolve_onset_date
  end

  def resolve_onset_date
    safe_call_chain(:disease_event, :disease_onset_date) ||
      safe_call_chain(:disease_event, :date_diagnosed)   ||
      definitive_lab_date ||
      self.first_reported_PH_date   ||
      self.created_at.try(:to_date) ||
      Date.today
  end

  def validate
    super

    county_jurisdiction = self.address.try(:county).try(:jurisdiction)
    if county_jurisdiction == Jurisdiction.out_of_state &&
        (((self.lhd_case_status != ExternalCode.out_of_state) && (!self.lhd_case_status.nil?)) &&
          ((self.state_case_status != ExternalCode.out_of_state) && (!self.state_case_status.nil?)))
      errors.add(:base, :invalid_case_status, :status => ExternalCode.out_of_state.code_description, :attr => I18n.t(:county).downcase, :value => self.address.county.code_description)
    end

    return if self.interested_party.nil?
    return unless bdate = self.interested_party.person_entity.try(:person).try(:birth_date)
    base_errors = {}

    self.hospitalization_facilities.each do |hf|

      if (date = hf.hospitals_participation.try(:admission_date).try(:to_date)) && (date < bdate)
        hf.hospitals_participation.errors.add(:admission_date, :cannot_precede_birth_date)
        base_errors['hospitals'] = [:precede_birth_date, {:thing => I18n.t(:hospitalization)}]
      end
      if (date = hf.hospitals_participation.try(:discharge_date).try(:to_date)) && (date < bdate)
        hf.hospitals_participation.errors.add(:discharge_date, :cannot_precede_birth_date)
        base_errors['hospitals'] = [:precede_birth_date, { :thing => I18n.t(:hospitalization) }]
      end
    end
    self.interested_party.treatments.each do |t|
      if (date = t.treatment_date.try(:to_date)) && (date < bdate)
        t.errors.add(:treatment_date, :cannot_precede_birth_date)
        base_errors['treatments'] = [:precede_birth_date, { :thing => I18n.t(:treatment) }]
      end
      if (date = t.stop_treatment_date.try(:to_date)) && (date < bdate)
        t.errors.add(:stop_treatment_date, :cannot_precede_birth_date)
        base_errors['treatments'] = [:precede_birth_date, { :thing => I18n.t(:treatment) }]
      end
    end
    risk_factor = self.interested_party.risk_factor
    if (date = risk_factor.try(:pregnancy_due_date).try(:to_date)) && (date < bdate)
      risk_factor.errors.add(:pregnancy_due_date, :cannot_precede_birth_date)
      base_errors['risk_factor'] = [:precede_birth_date, { :thing => I18n.t(:risk_factor) }]
    end
    if (date = self.disease_event.try(:disease_onset_date).try(:to_date)) && (date < bdate)
      self.disease_event.errors.add(:disease_onset_date, :cannot_precede_birth_date)
      base_errors['disease'] = [:precede_birth_date, { :thing => I18n.t(:disease) }]
    end
    if (date = self.disease_event.try(:date_diagnosed).try(:to_date)) && (date < bdate)
      self.disease_event.errors.add(:date_diagnosed, :cannot_precede_birth_date)
      base_errors['disease'] = [:precede_birth_date, { :thing => I18n.t(:disease) }]
    end
    self.labs.each do |l|
      l.lab_results.each do |lr|
        if (date = lr.collection_date.try(:to_date)) && (date < bdate)
          lr.errors.add(:collection_date, :cannot_precede_birth_date)
          base_errors['labs'] = [:precede_birth_date, { :thing => I18n.t(:lab_result) }]
        end
        if (date = lr.lab_test_date.try(:to_date)) && (date < bdate)
          lr.errors.add(:lab_test_date, :cannot_precede_birth_date)
          base_errors['labs'] = [:precede_birth_date, { :thing => I18n.t(:lab_result) }]
        end
      end
    end
    if (date = self.results_reported_to_clinician_date.try(:to_date)) && (date < bdate)
      self.errors.add(:results_reported_to_clinician_date, :cannot_precede_birth_date)
    end
    if (date = self.first_reported_PH_date.try(:to_date)) && (date < bdate)
      self.errors.add(:first_reported_PH_date, :cannot_precede_birth_date)
    end

    unless base_errors.empty? && self.errors.empty?
      base_errors.values.each { |msg| self.errors.add(:base, *msg) }
    end
  end

  def associate_longitudinal_data
    if address
      address.update_attributes(:entity_id => interested_party.primary_entity_id)
    end
  end
end
