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

class MorbidityEvent < HumanEvent
  
  supports :tasks
  supports :attachments

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

  has_one :reporting_agency, :foreign_key => "event_id"
  has_one :reporter, :foreign_key => "event_id"

  accepts_nested_attributes_for :reporting_agency,
    :allow_destroy => true,
    :reject_if => proc { |attrs| check_agency_attrs(attrs) }

  accepts_nested_attributes_for :reporter, 
    :allow_destroy => true, 
    :reject_if => proc { |attrs| check_reporter_attrs(attrs) }

  def self.check_agency_attrs(attrs)
    return false if attrs.has_key?("secondary_entity_id") # Adding new record via search
    place_empty = attrs["place_entity_attributes"]["place_attributes"].all? { |k, v| v.blank? }
    phones_empty = attrs["place_entity_attributes"]["telephones_attributes"].all? { |k, v| v.all? { |k, v| v.blank? } }
    (place_empty && phones_empty) ? true : false
  end

  def self.check_reporter_attrs(attrs)
    person_empty = attrs["person_entity_attributes"]["person_attributes"].all? { |k, v| v.blank? }
    phones_empty = attrs["person_entity_attributes"]["telephones_attributes"].all? { |k, v| v.all? { |k, v| v.blank? } }
    (person_empty && phones_empty) ? true : false
  end

  before_save :generate_mmwr
  before_save :initialize_children

  def route_to_jurisdiction(jurisdiction, secondary_jurisdiction_ids=[], note="")
    jurisdiction_id = jurisdiction.to_i if jurisdiction.respond_to?('to_i')
    jurisdiction_id = jurisdiction.id if jurisdiction.is_a? Entity
    jurisdiction_id = jurisdiction.entity_id if jurisdiction.is_a? Place

    transaction do
      # Handle the primary jurisdiction
      #
      # Do nothing if the passed-in jurisdiction is the current jurisdiction
      unless jurisdiction_id == self.jurisdiction.secondary_entity_id
        proposed_jurisdiction = Entity.find(jurisdiction_id) # Will raise an exception if record not found
        raise "New jurisdiction is not a jurisdiction" if proposed_jurisdiction.place.place_type_id != Code.find_by_code_name_and_the_code('placetype', 'J').id
        self.jurisdiction.update_attribute("secondary_entity_id", jurisdiction_id)
        self.update_attributes(:event_queue_id => nil,
          :investigator_id => nil,
          :investigation_started_date => nil,
          :investigation_completed_LHD_date => nil,
          :review_completed_by_state_date => nil)
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
        Form.get_published_investigation_forms(self.disease_event.disease_id, self.jurisdiction.secondary_entity_id, self.class.name.underscore).each do |form|
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
    conditions[0] += " AND jurisdictions.type = 'Jurisdiction' AND patients.type = 'InterestedParty'"
    
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
    find_options[:per_page] = options[:per_page] if options[:per_page].to_i > 0


    MorbidityEvent.paginate(:all, find_options)
  rescue Exception => ex
    logger.error ex
    raise ex
  end

  private
  
  def generate_mmwr
    epi_dates = { :onsetdate => disease.nil? ? nil : disease.disease_onset_date, 
      :diagnosisdate => disease.nil? ? nil : disease.date_diagnosed, 
      :labresultdate => definitive_lab_result.nil? ? nil : definitive_lab_result.lab_test_date,
      :firstreportdate => self.first_reported_PH_date }
    mmwr = Mmwr.new(epi_dates)
    
    self.MMWR_week = mmwr.mmwr_week
    self.MMWR_year = mmwr.mmwr_year
  end

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
