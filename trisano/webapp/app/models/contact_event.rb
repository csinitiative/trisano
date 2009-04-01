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

class ContactEvent < HumanEvent
  include Workflow

  supports :tasks
  supports :attachments
  
  before_create do |contact|
    contact.add_note("Contact event created.")
  end

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
      event :complete_and_close, :transitions_to => :closes, :meta => {:priv_required => :investigate_event} do |note|
        unless User.current_user.is_entitled_to_in?(:investigate_event, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Investigator closed investigation.\n#{note}"
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
      event :approve, :transitions_to => :closed, :meta => {:priv_required => :approve_event_at_lhd} do |note|
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
      event :complete_and_close, :transitions_to => :closes, :meta => {:priv_required => :investigate_event} do |note|
        unless User.current_user.is_entitled_to_in?(:investigate_event, self.jurisdiction.secondary_entity_id)
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Investigator closed investigation.\n#{note}"
      end
    end
    state :closed do
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

  class << self
    def core_views
      [
        ["Demographics", "Demographics"], 
        ["Clinical", "Clinical"], 
        ["Laboratory", "Laboratory"], 
        ["Epidemiological", "Epidemiological"]
      ]
    end
  end

  # If you're wondering why calling #destroy on a contact event isn't deleting the record, this is why.
  # Override destroy to soft-delete record instead.  This makes it easier to work with :autosave.
  def destroy
    self.soft_delete
  end

  def promote_to_morbidity_event
    raise "Cannot promote an unsaved contact to a morbidity event" if self.new_record?
    self['type'] = MorbidityEvent.to_s
    # Pull morb forms
    if self.disease_event && self.disease_event.disease
      jurisdiction = self.jurisdiction ? self.jurisdiction.secondary_entity_id : nil
      self.add_forms(Form.get_published_investigation_forms(self.disease_event.disease_id, jurisdiction, 'morbidity_event'))
    end
    self.add_note("Event changed from contact event to morbidity event")

    if self.save
      self.freeze
      # Return a fresh copy from the db
      MorbidityEvent.find(self.id)
    else
      false
    end
  end

  def copy_event(new_event, event_components)
    super
    # When we get a story asking for it, this is where we will copy over the (now poorly named) participations_contacts info to a new event.
    # That is, disposition etc.
  end
  
end
