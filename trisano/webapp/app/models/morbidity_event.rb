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
  include Routing::Workflow

  supports :tasks
  supports :attachments

  workflow do
    state 'NEW' do |s|
      s.transitions = ["ASGD-LHD"]
      s.required_privilege = :create_event
      s.description = "New"
      s.state_code = "NEW"
      s.note_text = '"Event created for jurisdiction #{self.primary_jurisdiction.name}."'
    end
    state 'ASGD-LHD' do |s|
      s.transitions = ["ASGD-LHD", "ACPTD-LHD", "RJCTD-LHD"]
      s.required_privilege = :route_event_to_any_lhd
      s.description = "Assigned to Local Health Dept."
      s.state_code = "ASGD-LHD"
      s.note_text = '"Routed to jurisdiction #{self.primary_jurisdiction.name}."'
    end
    state 'ACPTD-LHD' do |s|
      s.transitions = ["ASGD-LHD", "ASGD-INV"]
      s.action_phrase = "Accept"
      s.required_privilege = :accept_event_for_lhd
      s.description = "Accepted by Local Health Dept."
      s.state_code = "ACPTD-LHD"
      s.note_text = '"Accepted by #{self.primary_jurisdiction.name}."'
    end
    state 'RJCTD-LHD' do |s|
      s.transitions = ["ASGD-LHD"]
      s.action_phrase = "Reject"
      s.required_privilege = :accept_event_for_lhd
      s.description = "Rejected by Local Health Dept."
      s.state_code = "RJCTD-LHD"
      s.note_text = '"Rejected by #{self.primary_jurisdiction.name}."'
    end
    state 'ASGD-INV' do |s|
      s.transitions = ["ASGD-LHD", "UI", "RJCTD-INV", "ASGD-INV"]
      s.action_phrase = "Route to queue"
      s.required_privilege = :route_event_to_investigator
      s.description = "Assigned to Investigator"
      s.state_code = "ASGD-INV"
      s.note_text = 'if self.investigator then "Routed to investigator #{self.investigator.best_name}." else "Routed to queue #{self.event_queue.queue_name}." end'
    end
    state 'UI' do |s|
      s.transitions = ["ASGD-LHD", "IC", "ASGD-INV"]
      s.action_phrase = "Accept"
      s.required_privilege = :accept_event_for_investigation
      s.description = "Under Investigation"
      s.state_code = "UI"
      s.note_text = '"Accepted for investigation."'
    end
    state 'RJCTD-INV' do |s|
      s.transitions = ["ASGD-LHD", "ASGD-INV"]
      s.action_phrase = "Reject"
      s.required_privilege = :accept_event_for_investigation
      s.description = "Rejected by Investigator"
      s.state_code = "RJCTD-INV"
      s.note_text = '"Rejected for investigation."'
    end
    state 'IC' do |s|
      s.transitions = ["ASGD-LHD", "APP-LHD", "RO-MGR", "ASGD-INV"]
      s.action_phrase = "Mark Investigation Complete"
      s.required_privilege = :investigate_event 
      s.description = "Investigation Complete"
      s.state_code = "IC"
      s.note_text = '"Completed investigation."'
    end
    state 'APP-LHD' do |s|
      s.transitions = ["ASGD-LHD", "CLOSED", "RO-STATE"]
      s.action_phrase = "Approve"
      s.required_privilege = :approve_event_at_lhd 
      s.description = "Approved by LHD"
      s.state_code = "APP-LHD"
      s.note_text = '"Approved at #{self.primary_jurisdiction.name}."'
    end
    state 'RO-MGR' do |s|
      s.transitions = ["ASGD-LHD", "IC", "ASGD-INV"]
      s.action_phrase = "Reopen"
      s.required_privilege = :approve_event_at_lhd 
      s.description = "Reopened by Manager"
      s.state_code = "RO-MGR"
      s.note_text = '"Reopened by #{self.primary_jurisdiction.name} manager."'
    end
    state 'CLOSED' do |s|
      s.action_phrase = "Approve"
      s.required_privilege = :approve_event_at_state 
      s.description = "Approved by State"
      s.state_code = "CLOSED"
      s.note_text = '"Approved by State."'
    end
    state 'RO-STATE' do |s|
      s.transitions = ["ASGD-LHD", "APP-LHD", "RO-MGR", "ASGD-INV"]
      s.action_phrase = "Reopen"
      s.required_privilege = :approve_event_at_state 
      s.description = "Reopened by State"
      s.state_code = "RO-STATE"
      s.note_text = '"Reopened by State."'
    end  
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
    phones_empty = attrs["place_entity_attributes"].has_key?("telephones_attributes") && attrs["place_entity_attributes"]["telephones_attributes"].all? { |k, v| v.all? { |k, v| v.blank? } }
    (place_empty && phones_empty) ? true : false
  end

  def self.check_reporter_attrs(attrs)
    person_empty = attrs["person_entity_attributes"]["person_attributes"].all? { |k, v| v.blank? }
    phones_empty = attrs["person_entity_attributes"].has_key?("telephones_attributes") && attrs["person_entity_attributes"]["telephones_attributes"].all? { |k, v| v.all? { |k, v| v.blank? } }
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
        proposed_jurisdiction = PlaceEntity.find(jurisdiction_id) # Will raise an exception if record not found
        raise "New jurisdiction is not a jurisdiction" unless Place.jurisdictions.include?(proposed_jurisdiction.place)
        self.jurisdiction.update_attribute("secondary_entity_id", jurisdiction_id)
        self.update_attributes(:event_queue_id => nil,
          :investigator_id => nil,
          :investigation_started_date => nil,
          :investigation_completed_LHD_date => nil,
          :review_completed_by_state_date => nil)
        self.add_note(self.instance_eval(MorbidityEvent.states[self.event_status].note_text) + "\n#{note}")
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
  
  def copy_event(new_event, event_components)
    super(new_event, event_components)

    if event_components.include?("contacts")
      # Deferred for now, due to lack of clarity.  Should the cloned event point at the very same contacts (can't do this right now because
      # a contact can currently have only one parent -- surgery required to allow events to have more than one parent) or should it create
      # independent clones of the contact events?  Prolly, the former.
    end

    if event_components.include?("reporting")
      new_event.build_reporting_agency(:secondary_entity_id => self.reporting_agency.secondary_entity_id) if self.reporting_agency
      new_event.build_reporter(:secondary_entity_id => self.reporter.secondary_entity_id) if self.reporter
      new_event.first_reported_PH_date = self.first_reported_PH_date
      new_event.results_reported_to_clinician_date = self.results_reported_to_clinician_date
    end
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
    system_states = self.get_state_keys
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
