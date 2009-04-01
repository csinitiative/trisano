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
require 'ostruct'

class MorbidityEvent < HumanEvent
  include Workflow

  supports :tasks
  supports :attachments

  before_save :generate_mmwr
  before_save :initialize_children

  workflow do
    # on_entry evaluated at wrong time, so note is attached to meta for :new
    state :new, :meta => {:note_text => '"Event created for jurisdiction #{self.primary_jurisdiction.name}."'} do
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
    end        
    state :assigned_to_lhd, :meta => {:description => 'Assigned to Local Health Dept.'} do
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
      event :accept, :transitions_to => :accepted_by_lhd, :meta => {:priv_required => :accept_event_for_lhd} do |note|
        unless User.current_user.is_entitled_to_in?(:accept_event_for_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Accepted by #{self.primary_jurisdiction.name}.\n" + note
      end
      event :reject, :transitions_to => :rejected_by_lhd, :meta => {:priv_required => :accept_event_for_lhd} do |note|
        unless User.current_user.is_entitled_to_in?(:accept_event_for_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Rejected by #{self.primary_jurisdiction.name}.\n" + note
      end
    end
    state :accepted_by_lhd, :meta => {:description => 'Accepted by Local Health Dept.'} do
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
      event :assign_to_investigator, :transitions_to => :assigned_to_investigator, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_investigator, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        note = if self.investigator
                 "Routed to investigator #{self.investigator.try(:best_name)}\n#{note}"
               else
                 "Routed to queue #{self.event_queue.try(:queue_name)}\n#{note}"
               end
        add_note note
      end
      event :investigate, :transitions_to => :under_investigation, :meta => {:priv_required => :accept_event_for_investigator} do |note|
        unless User.current_user.is_entitled_to_in?(:accept_event_for_investigation, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Accepted by Investigator\n" + note
      end
    end 
    state :rejected_by_lhd, :meta => {:description => "Rejected by Local Health Dept."} do
      on_entry do |prior_state, triggering_event, *event_args|
        self.route_to_jurisdiction(Place.jurisdiction_by_name("Unassigned"))
      end
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
    end
    state :assigned_to_investigator do
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
      event :accept, :transitions_to => :under_investigation, :meta => {:priv_required => :accept_event_for_investigation} do |note|
        unless User.current_user.is_entitled_to_in?(:accept_event_for_investigation, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Accepted by Investigator.\n#{note}"
      end
      event :reject, :transitions_to => :rejected_by_investigator, :meta => {:priv_required => :accept_event_for_investigation} do |note|
        unless User.current_user.is_entitled_to_in?(:accept_event_for_investigation, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Rejected for investigation.\n#{note}"
      end
      event :assign_to_investigator, :transitions_to => :assigned_to_investigator, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_investigator, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        note = if self.investigator
                 "Routed to investigator #{self.investigator.try(:best_name)}\n#{note}"
               else
                 "Routed to queue #{self.event_queue.try(:queue_name)}\n#{note}"
               end
        add_note note
      end
      # need a way to reset state if an event queue goes away.
      event :reset, :transitions_to => :accepted_by_lhd do
        halt! "Investigator already assigned" unless investigator.nil?
      end
    end
    state :under_investigation do
      on_entry do |prior_state, triggering_event, *event_args|
        self.investigator_id = User.current_user.id
        self.investigation_started_date = Date.today
      end
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
      event :complete, :transitions_to => :investigation_complete, :meta => {:priv_required => :investigate_event} do |note|
        unless User.current_user.is_entitled_to_in?(:investigate_event, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Completed investigation.\n#{note}"
      end
      event :assign_to_investigator, :transitions_to => :assigned_to_investigator, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_investigator, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        note = if self.investigator
                 "Routed to investigator #{self.investigator.try(:best_name)}\n#{note}"
               else
                 "Routed to queue #{self.event_queue.try(:queue_name)}\n#{note}"
               end
        add_note note
      end
    end
    state :rejected_by_investigator do
      on_entry do |prior_state, triggering_event, *event_args| 
        self.investigator_id = nil
        self.investigation_started_date = nil
      end
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
      event :assign_to_investigator, :transitions_to => :assigned_to_investigator, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_investigator, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        note = if self.investigator
                 "Routed to investigator #{self.investigator.try(:best_name)}\n#{note}"
               else
                 "Routed to queue #{self.event_queue.try(:queue_name)}\n#{note}"
               end
        add_note note
      end
      event :investigate, :transitions_to => :under_investigation, :meta => {:priv_required => :accept_event_for_investigation} do |note|
        unless User.current_user.is_entitled_to_in?(:accept_event_for_investigation, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Accepted by Investigator.\n#{note}"
      end
    end
    state :investigation_complete do
      on_entry do |prior_state, triggering_event, *event_args|
        self.investigation_completed_LHD_date = Date.today
      end
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
      event :assign_to_investigator, :transitions_to => :assigned_to_investigator, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_investigator, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Assigned to Investigator.\n#{note}"
      end
      event :approve, :transitions_to => :approved_by_lhd, :meta => {:priv_required => :approve_event_at_lhd} do |note|
        unless User.current_user.is_entitled_to_in?(:approve_event_at_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Approved at #{self.primary_jurisdiction.name}.\n#{note}"
      end
      event :reopen, :transitions_to => :reopened_by_manager, :meta => {:priv_required => :approve_event_at_lhd} do |note|
        unless User.current_user.is_entitled_to_in?(:approve_event_at_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Reopened by #{self.primary_jurisdiction.name} manager.\n#{note}"
      end
    end
    state :approved_by_lhd, :meta => {:description => 'Approved by Local Health Dept.'} do
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
      event :approve, :transitions_to => :closed, :meta => {:priv_required => :approve_event_at_state} do |note|
        unless User.current_user.is_entitled_to_in?(:approve_event_at_state, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Approved by State.\n#{note}"
        review_completed_by_state_date = Date.today
      end
      event :reopen, :transitions_to => :reopened_by_state, :meta => {:priv_required => :approve_event_at_state} do |note|
        unless User.current_user.is_entitled_to_in?(:approve_event_at_state, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Reopened by State.\n#{note}"
      end
    end
    state :reopened_by_manager do
      on_entry do |prior_event, transition, *args|
        self.investigation_completed_LHD_date = nil
      end
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
      event :assign_to_investigator, :transitions_to => :assigned_to_investigator, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_investigator, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        note = if self.investigator
                 "Routed to investigator #{self.investigator.try(:best_name)}\n#{note}"
               else
                 "Routed to queue #{self.event_queue.try(:queue_name)}\n#{note}"
               end
        add_note note
      end
      event :complete, :transitions_to => :investigation_complete, :meta => {:priv_required => :investigate_event} do |note|
        unless User.current_user.is_entitled_to_in?(:investigate_event, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Completed investigation.\n#{note}"
      end
    end
    state :reopened_by_state do
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
      event :assign_to_investigator, :transitions_to => :assigned_to_investigator, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_investigator, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        note = if self.investigator
                 "Routed to investigator #{self.investigator.try(:best_name)}\n#{note}"
               else
                 "Routed to queue #{self.event_queue.try(:queue_name)}\n#{note}"
               end
        add_note note
      end
      event :reopen, :transitions_to => :reopened_by_manager, :meta => {:priv_required => :approve_event_at_lhd} do |note|
        unless User.current_user.is_entitled_to_in?(:approve_event_at_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Reopened by #{self.primary_jurisdiction.name} manager.\n#{note}"
      end
      event :approve, :transitions_to => :approved_by_lhd, :meta => {:priv_required => :approve_event_at_lhd} do |note|
        unless User.current_user.is_entitled_to_in?(:approve_event_at_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Approved at #{self.primary_jurisdiction.name}.\n#{note}"
      end
    end
    state :closed, :meta => {:description => 'Approved by State'} do
      event :assign_to_lhd, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
        rescue Exception => e
          halt! e.message
        end
      end
    end        
  end

  def self.get_states_and_descriptions
    new.states.collect do |state|
      OpenStruct.new :state => state, :description => state_description(state)
    end
  end

  def self.state_description(state)
    new.states(state).meta[:description] || state.to_s.titleize
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

  def self.get_allowed_queues(query_queues)
    system_queues = EventQueue.queues_for_jurisdictions(User.current_user.jurisdiction_ids_for_privilege(:view_event))
    queue_ids = system_queues.collect { |system_queue| query_queues.include?(system_queue.queue_name) ? system_queue.id : nil }.compact
    queue_names = system_queues.collect { |system_queue| query_queues.include?(system_queue.queue_name) ? system_queue.queue_name : nil }.compact
    return queue_ids, queue_names
  end

end
