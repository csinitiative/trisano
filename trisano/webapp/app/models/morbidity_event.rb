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

class MorbidityEvent < HumanEvent
  
  #    def self.new_event_tree(event_hash = {:disease => {}, :active_jurisdiction => {}})
  #      event = MorbidityEvent.new(event_hash)

  def self.new_event_tree()
    event = MorbidityEvent.new
    event.patient = Participation.new_patient_participation_with_address_and_phone
    event.jurisdiction = Participation.new(:role_id => Event.participation_code('Jurisdiction'))
    event.build_disease_event
    event.patient.participations_treatments.build
    event.patient.build_participations_risk_factor
    event.labs << Participation.new_lab_participation
    event.hospitalized_health_facilities << Participation.new_hospital_participation
    event.diagnosing_health_facilities << Participation.new_diagnostic_participation
    event.contacts << Participation.new_contact_participation
    event.place_exposures << Participation.new_exposure_participation
    event.reporter = Participation.new_reporter_participation
    event.notes.build
    event
  end

  def self.new_event_from_patient(patient_entity)
    event = MorbidityEvent.new
    event.patient = Participation.new_patient_participation(patient_entity)    
    jurisdiction = Participation.new_jurisdiction_participation
    event.jurisdiction = jurisdiction    
    event.event_status = 'NEW'
    event
  end
  
  def self.core_views
    [
      ["Demographics", "Demographics"], 
      ["Clinical", "Clinical"], 
      ["Laboratory", "Laboratory"], 
      ["Contacts", "Contacts"],
      ["Epidemiological", "Epidemiological"], 
      ["Reporting", "Reporting"], 
      ["Administrative", "Administrative"]
    ]
  end

  has_many :place_exposures, 
    :class_name => 'Participation',
    :foreign_key => "event_id",
    :conditions => ['role_id = ?', Code.place_exposure_type_id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_one :reporting_agency, 
    :class_name => 'Participation', 
    :foreign_key => "event_id",
    :conditions => ["role_id = ?", Code.reporting_agency_type_id]

  has_one :reporter, 
    :class_name => 'Participation', 
    :foreign_key => "event_id",
    :conditions => ["role_id = ?", Code.reported_by_type_id]

  # Turn off auto validation of has_many associations
  def validate_associated_records_for_place_exposures() end

  validates_associated :place_exposures
  validates_associated :reporting_agency
  validates_associated :reporter

  def new_place_exposure_attributes=(place_exposure_attributes)
    place_exposure_attributes.each do |attributes|
      next if attributes.values_blank?
      place_exposure_participation = place_exposures.build(:role_id => Event.participation_code('Place Exposure'))
      place_exposure_participation.build_participations_place(:date_of_exposure => attributes.delete('date_of_exposure'))

      if attributes["entity_id"].blank?
        place_exposure_entity = place_exposure_participation.build_secondary_entity
        place_exposure_entity.entity_type = 'place'
        place_exposure_entity.build_place_temp(attributes)
      else
        place_exposure_entity = Entity.find(attributes["entity_id"])
        place_exposure_participation.secondary_entity = place_exposure_entity
      end
    end
  end

  def existing_place_exposure_attributes=(place_exposure_attributes)
    place_exposures.reject(&:new_record?).each do |place_exposure|
      attributes = place_exposure_attributes[place_exposure.id.to_s]
      if attributes && !attributes.values_blank?
        place_exposure.participations_place.date_of_exposure = attributes.delete("date_of_exposure")
      else
        place_exposure.participating_event.soft_delete if place_exposure.participating_event
        place_exposures.delete(place_exposure)
      end
    end
  end

  def active_reporting_agency
    self.reporting_agency
  end

  def active_reporter
    self.reporter
  end

  def update_reporting_agency_with_existing(attributes)
    place = Place.find(attributes.delete(:id))
    self.build_reporting_agency(:role_id => Event.participation_code('Reporting Agency')) if self.reporting_agency.nil?
    self.reporting_agency.secondary_entity = place.entity    
  end

  def update_reporting_agency_with_new(attributes)
    agency = attributes.delete(:name)
    self.build_reporting_agency(:role_id => Event.participation_code('Reporting Agency')) if self.reporting_agency.nil?
    new_agency =  Entity.new
    new_agency.entity_type = 'place'
    new_agency.build_place_temp(:name => agency, :place_type_id => Code.other_place_type_id)
    self.reporting_agency.secondary_entity = new_agency
  end

  # hopefully, this will hurt less now
  def active_reporting_agency=(attributes)
    if attributes.has_key?(:id)
      update_reporting_agency_with_existing(attributes)
    elsif not attributes[:name].blank? # eventually use has_key? and let validation verify 'blankness'
      update_reporting_agency_with_new(attributes)
    else
      if self.reporting_agency
        self.reporting_agency.destroy 
        self.reporting_agency.reset
      end
    end      

    # Now the reporter and reporter phone (this part still hurts)

    # If there is a saved reporter and the user has blanked it out, delete reporter participation
    self.reporter.destroy if attributes.values_blank? && self.reporter

    return if attributes.values_blank?

    # User can send either a reporter or a phone number or both.  Regardless we need a participation and an entity if we don't have one already
    self.build_reporter(:role_id => Event.participation_code('Reported By')).build_secondary_entity if self.reporter.nil?
    self.reporter.secondary_entity.entity_type = 'person'
    
    # Process the person, if any
    last_name = attributes.delete(:last_name)
    first_name = attributes.delete(:first_name)

    # Build a person if we don't have one
    self.reporter.secondary_entity.build_person_temp if self.reporter.secondary_entity.person_temp.nil?
    self.reporter.secondary_entity.person_temp.attributes = { :last_name => last_name, :first_name => first_name }

    # Now do the phone, if any (attached to person, not agency)
    return if attributes.values_blank?

    # This is the existing entity_location_id (pointing at the phone), if any
    el_id = attributes.delete(:id).to_i

    # If there's no ID, then they are adding a new phone
    if el_id == 0 || el_id.blank?
      code = attributes.delete(:entity_location_type_id)
      # They might have selected a phone type (work, home, etc.) but nothing else, just bail.
      return if attributes.values_blank?

      # Build the phone
      el = self.reporter.secondary_entity.telephone_entities_locations.build(
        :entity_location_type_id => code,
        :primary_yn_id => ExternalCode.yes_id,
        :location_type_id => Code.telephone_location_type_id)
      el.build_location.telephones.build(attributes)
    else
      # Don't just 'find' the existing phone, loop through the association array looking for it
      self.reporter.secondary_entity.telephone_entities_locations.each do |tel_el|
        if tel_el.id == el_id
          # The user has blanked out the phone number of an existing reporter, delete it
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
  end

  def route_to_jurisdiction(jurisdiction, secondary_jurisdiction_ids=[], note="")
    jurisdiction_id = jurisdiction.to_i if jurisdiction.respond_to?('to_i')
    jurisdiction_id = jurisdiction.id if jurisdiction.is_a? Entity
    jurisdiction_id = jurisdiction.entity_id if jurisdiction.is_a? Place

    transaction do
      # Handle the primary jurisdiction
      #
      # Do nothing if the passed-in jurisdiction is the current jurisdiction
      unless jurisdiction_id == active_jurisdiction.secondary_entity_id
        proposed_jurisdiction = Entity.find(jurisdiction_id) # Will raise an exception if record not found
        raise "New jurisdiction is not a jurisdiction" if proposed_jurisdiction.current_place.place_type_id != Code.find_by_code_name_and_the_code('placetype', 'J').id
        self.active_jurisdiction.update_attribute("secondary_entity_id", jurisdiction_id)
        self.update_attributes(:event_queue_id => nil,
          :investigator_id => nil,
          :investigation_started_date => nil,
          :investigation_completed_LHD_date => nil,
          :review_completed_UDOH_date => nil)
        self.add_note(self.instance_eval(Event.states[self.event_status].note_text) + "\n#{note}")
      end

      # Handle secondary jurisdictions
      #
      existing_secondary_jurisdiction_ids = associated_jurisdictions.collect { |participation| participation.secondary_entity_id }

      # if an existing secondary jurisdiction ID is not in the passed-in ids, delete
      (existing_secondary_jurisdiction_ids - secondary_jurisdiction_ids).each do |id_to_delete|
        associated_jurisdictions.delete(associated_jurisdictions.find_by_secondary_entity_id(id_to_delete))
      end

      # if an passed-in ID is not in the existing secondary jurisdiction IDs, add
      (secondary_jurisdiction_ids - existing_secondary_jurisdiction_ids).each do |id_to_add|
        associated_jurisdictions.create(:secondary_entity_id => id_to_add, :role_id => Event.participation_code('Secondary Jurisdiction'))
      end

      # Add any new forms to this event  I guess we'll keep any old ones for now.
      if self.disease
        forms_in_use = self.form_references.map { |ref| ref.form_id }
        Form.get_published_investigation_forms(self.disease.disease_id, self.active_jurisdiction.secondary_entity_id, self.class.name.underscore).each do |form|
          self.form_references.create(:form_id => form.id) unless forms_in_use.include?(form.id)
        end
      end
      
      reload # Any existing references to this object won't see these changes without this
    end
  end
  
  def self.find_all_for_filtered_view(options = {})
    
    conditions = ["jurisdictions.secondary_entity_id IN (?)", User.current_user.jurisdiction_ids_for_privilege(:view_event)]
    conjunction = "AND"

    states = get_allowed_states(options[:states])
    if states.empty?
      raise
    else
      conditions[0] += " #{conjunction} event_status IN (?)"
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
        raise
      else
        conditions[0] += " #{conjunction} event_queue_id IN (?)"
        conditions << queue_ids
      end
    end

    if options[:do_not_show_deleted]
      conditions[0] += " AND deleted_at IS NULL"
    end

    order_by = case options[:order_by]
    when 'patient'
      "people.last_name, people.first_name, diseases.disease_name, places.name, events.event_status"
    when 'disease'
      "diseases.disease_name, people.last_name, people.first_name, places.name, events.event_status"
    when 'jurisdiction'
      "places.name, people.last_name, people.first_name, diseases.disease_name, events.event_status"
    when 'status'
      # Fortunately the event status code stored in the DB and the text the user sees mostly correspond to the same alphabetical ordering"
      "events.event_status, people.last_name, people.first_name, diseases.disease_name, places.name"
    else
      "events.updated_at DESC"
    end

    # We can't :include the associations 'all_jurisdictions' _and_ 'patient', cause the :conditions on them make AR generate ambiguous SQL, so echoing here.
    conditions[0] += " AND jurisdictions.role_id = ? AND patients.role_id = ?"
    conditions << primary_jurisdiction_code_id
    conditions << Code.interested_party_id
    
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
      :page => options[:page]
    }

    MorbidityEvent.paginate(:all, find_options)
  rescue Exception => ex
    logger.error ex
    raise ex
  end

  def save_associations
    super

    if reporting_agency && !reporting_agency.frozen?
      reporting_agency.save(false)
      reporting_agency.secondary_entity.save(false)
      reporting_agency.secondary_entity.place_temp.save(false)
    end

    if reporter && !reporter.frozen?
      reporter.save(false)
      reporter.secondary_entity.person_temp.save(false) if reporter.secondary_entity.person_temp

      reporter.secondary_entity.telephone_entities_locations.each do |el|
        unless el.frozen?
          el.save(false)
          el.location.telephones.each { |t| t.save(false) }
        end
      end
    end

    place_exposures.each do |pe|
      pe.participations_place.save(false)
      pe.secondary_entity.place_temp.save(false)
    end
  end

  private
  
  # Expects string of space separated event states e.g. new, acptd-lhd, etc.
  def self.get_allowed_states(query_states=nil)
    system_states = Event.get_state_keys
    return system_states if query_states.nil?
    query_states.collect! { |state| state.upcase }
    system_states.collect { |system_state| query_states.include?(system_state) ? system_state : nil }.compact
  end

  def self.get_allowed_queues(query_queues)
    system_queues = EventQueue.queues_for_jurisdictions(User.current_user.jurisdiction_ids_for_privilege(:view_event))
    queue_ids = system_queues.collect { |system_queue| query_queues.include?(system_queue.queue_name) ? system_queue.id : nil }.compact
    queue_names = system_queues.collect { |system_queue| query_queues.include?(system_queue.queue_name) ? system_queue.queue_name : nil }.compact
    return queue_ids, queue_names
  end

end
