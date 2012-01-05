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
require 'ostruct'

class MorbidityEvent < HumanEvent
  include Workflow

  supports :tasks
  supports :attachments

  before_save :generate_mmwr
  before_save :initialize_children
  before_save :check_export_updates
  before_create :set_initial_workflow_state
  before_create :set_default_jurisdiction

  validates_date :first_reported_PH_date, {
    :allow_blank => false,
    :on_or_before =>  lambda { |record| record.new_record? ? Date.today : record.created_at },
    :unless => lambda { |record| record.suppress_validation?(:first_reported_PH_date) }
  }

  workflow do
    # on_entry evaluated at wrong time, so note is attached to meta for :new
    state :new, :meta => {:note_text => '"#{I18n.translate(\'workflow.event_created_for_jurisdiction\', :locale => I18n.default_locale)} #{self.jurisdiction.name}."'} do
      assign_to_lhd
    end
    state :assigned_to_lhd, :meta => {:description => I18n.translate('workflow.assigned_to_lhd')} do
      # Won't work in jruby 1.2 because of this: https://fisheye.codehaus.org/browse/JRUBY-3490
      # Reimplement when fixed. Also see contact_event.rb and lib/workflow_helper.rb
      #
      # on_entry do |prior_state, triggering_event, *event_args|
      #  # An event can be routed to a new jurisdiction at any time; clear out settings from earlier pass throught the flow, if any.
      #  undo_workflow_side_effects
      #end
      assign_to_lhd
      accept_by_lhd :accept
      reject_by_lhd :reject
    end
    state :accepted_by_lhd, :meta => {:description => I18n.translate('workflow.accepted_by_lhd')} do
      assign_to_lhd
      assign_to_investigator
      assign_to_queue
      investigate
    end
    state :rejected_by_lhd, :meta => {:description => I18n.translate('workflow.rejected_by_lhd')} do
      on_entry do |prior_state, triggering_event, *event_args|
        self.route_to_jurisdiction(Place.unassigned_jurisdiction)
      end
      assign_to_lhd
    end
    state :assigned_to_queue, :meta => {:description => I18n.translate('workflow.assigned_to_queue')} do
      # Commented out becuase UT is using queues not as a place for investigators to pull work from, but to route a case
      # to a 'program' (department, e.g. STDs).  And then a program manager routes to an individual.  I'm  not deleting
      # this code, 'cause I'd like to ressurect it some day.
      #
      # on_entry do |prior_state, triggering_event, *event_args|
      #   # An event can be assigned to a queue at any time; clear out settings from earlier pass throught the flow, if any.
      #   undo_workflow_side_effects
      # end
      assign_to_lhd
      investigate :accept
      reject_by_investigator :reject
      assign_to_queue
      assign_to_investigator
    end
    state :assigned_to_investigator, :meta => {:description => I18n.translate('workflow.assigned_to_investigator')} do
      on_entry do |prior_state, triggering_event, *event_args|
        # An event can be assigned to an investigator at any time; clear out settings from earlier an earlier pass through the flow, if any.
        undo_workflow_side_effects
      end
      assign_to_lhd
      investigate :accept
      reject_by_investigator :reject
      assign_to_queue
      assign_to_investigator
      # need a way to reset state if an event queue goes away.
      event :reset, :transitions_to => :accepted_by_lhd do
        halt!(I18n.translate('investigator_already_assigned')) unless investigator.nil?
      end
    end
    state :under_investigation do
      on_entry do |prior_state, triggering_event, *event_args|
        self.investigator = User.current_user
        self.investigation_started_date = Date.today
      end
      assign_to_lhd
      complete_investigation :complete
      assign_to_queue
      assign_to_investigator
    end
    state :rejected_by_investigator do
      on_entry do |prior_state, triggering_event, *event_args|
        self.investigator_id = nil
        self.investigation_started_date = nil
      end
      assign_to_lhd
      assign_to_queue
      assign_to_investigator
      investigate
    end
    state :investigation_complete do
      on_entry do |prior_state, triggering_event, *event_args|
        self.investigation_completed_LHD_date = Date.today
      end
      assign_to_lhd
      assign_to_queue
      assign_to_investigator
      approve_by_lhd :approve
      reopen_by_manager :reopen
    end
    state :approved_by_lhd, :meta => {:description => I18n.translate('workflow.approved_by_lhd')} do
      assign_to_lhd
      close :approve
      reopen_by_state :reopen
    end
    state :reopened_by_manager do
      on_entry do |prior_event, transition, *args|
        self.investigation_completed_LHD_date = nil
      end
      assign_to_lhd
      assign_to_queue
      assign_to_investigator
      complete_investigation :complete
    end
    state :reopened_by_state do
      assign_to_lhd
      assign_to_queue
      assign_to_investigator
      reopen_by_manager :reopen
      approve_by_lhd :approve
    end
    state :closed, :meta => {:description => I18n.translate('workflow.approved_by_state')} do
      assign_to_lhd
    end
  end

  def self.core_views
    [
      [I18n.t('core_views.demographics'), "Demographics"],
      [I18n.t('core_views.clinical'), "Clinical"],
      [I18n.t('core_views.laboratory'), "Laboratory"],
      [I18n.t('core_views.contacts'), "Contacts"],
      [I18n.t('core_views.epidemiological'), "Epidemiological"],
      [I18n.t('core_views.reporting'), "Reporting"],
      [I18n.t('core_views.administrative'), "Administrative"]
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

  def xml_fields
    ['acuity',
     'event_name',
     'other_data_1',
     'other_data_2',
     'outbreak_name',
     ['investigator_id', {:rel => :investigator}],
     'workflow_state',
     'investigation_started_date',
     'investigation_completed_LHD_date',
     'created_at',
     'parent_guardian',
     ['imported_from_id', {:rel => :imported}],
     ['lhd_case_status_id', {:rel => :case}],
     ['state_case_status_id', {:rel => :case}],
     'first_reported_PH_date',
     ['outbreak_associated_id', {:rel => :yesno}],
     'results_reported_to_clinician_date']
  end

  private

  def generate_mmwr
    mmwr = Mmwr.new({
        :onsetdate => disease.try(:disease_onset_date),
        :diagnosisdate => disease.try(:date_diagnosed),
        :labresultdate => definitive_lab_date,
        :firstreportdate => self.first_reported_PH_date,
        :event_created_date => new_record? ? Date.today : self.created_at.to_date
      })

    self.MMWR_week = mmwr.mmwr_week
    self.MMWR_year = mmwr.mmwr_year
  end

  def validate
    super

    unless disease_onset_date_valid?
      restriction = I18n.t('first_reported_PH_date', :scope => [:activerecord, :attributes, :event])
      errors.add('disease_event.disease_onset_date', :on_or_before, :restriction => restriction)
      disease_event.errors.add(:disease_onset_date, :on_or_before, :restriction => restriction)
    end

    return if self.interested_party.nil?
    return unless bdate = self.interested_party.person_entity.try(:person).try(:birth_date)
    base_errors = {}

    self.place_child_events.each do |pce|
      if (date = pce.participations_place.try(:date_of_exposure).try(:to_date)) && (date < bdate)
        pce.participations_place.errors.add(:date_of_exposure, :cannot_precede_birth_date)
        base_errors['epi'] = [:precede_birth_date, { :thing => I18n.t(:epi) }]
      end
    end
    self.encounter_child_events.each do |ece|
      if (date = ece.participations_encounter.try(:encounter_date).try(:to_date)) && (date < bdate)
        ece.participations_encounter.errors.add(:encounter_date, :cannot_precede_birth_date)
        base_errors['encounters'] = [:precede_birth_date, { :thing => I18n.t(:encounter) }]
      end
    end

    unless base_errors.empty?
      base_errors.values.each { |msg| self.errors.add(:base, *msg) }
    end
  end

  def set_initial_workflow_state
    jurisdiction_id = jurisdiction.try(:secondary_entity_id)
    if jurisdiction_id && jurisdiction_id != Place.unassigned_jurisdiction_entity_id
      self.workflow_state = 'accepted_by_lhd'
    end
  end

  def set_default_jurisdiction
    if self.jurisdiction.try(:secondary_entity).nil? and Place.unassigned_jurisdiction
      self.build_jurisdiction(:secondary_entity => Place.unassigned_jurisdiction.entity)
    end
  end

  def disease_onset_date_valid?
    return true if first_reported_PH_date.blank?
    return true if disease_event.try(:disease_onset_date).blank?
    return disease_event.disease_onset_date <= first_reported_PH_date
  end
end
