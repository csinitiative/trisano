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

class ContactEvent < HumanEvent
  include Workflow

  supports :tasks
  supports :attachments
  supports :promote_to_morbidity_event
  supports :promote_to_assessment_event

  before_create :direct_child_creation_initialization, :add_contact_event_creation_note

  after_create :add_parent_event_creation_note

  workflow do
    state :not_routed, :meta => {:description => I18n.translate('workflow.not_participating_in_workflow'),
      :note_text => '"#{I18n.translate(\'workflow.event_created_for_jurisdiction\', :locale => I18n.default_locale)} #{self.jurisdiction.name}."'} do
      promote_to_morbidity_event
      assign_to_lhd
    end
    state :new, :meta => {:note_text => '"#{I18n.translate(\'workflow.event_created_for_jurisdiction\', :locale => I18n.default_locale)} #{self.jurisdiction.name}."'} do
      assign_to_lhd
    end
    state :assigned_to_lhd, :meta => {:description => I18n.translate('workflow.assigned_to_lhd')} do
      # Won't work in jruby 1.2 because of this: https://fisheye.codehaus.org/browse/JRUBY-3490
      # Reimplement when fixed. Also see contact_event.rb and workaround in lib/workflow_helper.rb
      #
      # on_entry do |prior_state, triggering_event, *event_args|
      #   # An event can be routed to a new jurisdiction at any time; clear out settings from earlier pass throught the flow, if any.
      #   undo_workflow_side_effects
      # end
      assign_to_lhd
      accept_by_lhd :accept
      reject_by_lhd :reject
    end
    state :accepted_by_lhd, :meta => {:description => I18n.translate('workflow.accepted_by_lhd')} do
      assign_to_lhd
      assign_to_queue
      assign_to_investigator
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
        halt!(I18n.t("investigator_already_assigned")) unless investigator.nil?
      end
    end
    state :under_investigation do
      on_entry do |prior_state, triggering_event, *event_args|
        self.investigator_id = User.current_user.id
        self.investigation_started_date = Date.today
      end
      assign_to_lhd
      complete_investigation :complete
      complete_and_close_investigation :complete_and_close
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
      close_contact :approve
      reopen_by_manager :reopen
    end
    state :reopened_by_manager do
      on_entry do |prior_event, transition, *args|
        self.investigation_completed_LHD_date = nil
      end
      assign_to_lhd
      assign_to_queue
      assign_to_investigator
      complete_investigation :close
      complete_and_close_investigation :complete_and_close
    end
    state :closed do
      assign_to_lhd
    end
  end

  class << self
    def core_views
      [
        [I18n.t('core_views.demographics'), "Demographics"],
        [I18n.t('core_views.clinical'), "Clinical"],
        [I18n.t('core_views.laboratory'), "Laboratory"],
        [I18n.t('core_views.epidemiological'), "Epidemiological"]
      ]
    end
  end

  # If you're wondering why calling #destroy on a contact event isn't deleting the record, this is why.
  # Override destroy to soft-delete record instead.  This makes it easier to work with :autosave.
  def destroy

    # DEBT HERE
    # It seems this method gets called twice when deleting a contact event from a morbidity event
    # In order to prevent duplicate audit notes from being added, we check if the deleted_at
    # field is set.  The first time this is fired, it is not set.  The second time it is.
    # This prevents duplicate notes.
    parent_event.add_note(I18n.translate("system_notes.contact_event_deleted", :locale => I18n.default_locale)) if parent_event.present? && deleted_at.present?
    
    self.soft_delete
  end

  def copy_event(new_event, event_components)
    super
    # When we get a story asking for it, this is where we will copy over the (now poorly named) participations_contacts info to a new event.
    # That is, disposition etc.
  end

  def validate
    super
    base_errors = {}
    validate_disposition_date_against_birth_date(base_errors)

    unless base_errors.empty? && self.errors.empty?
      base_errors.values.each { |msg| self.errors.add(:base, *msg) }
    end
  end

  private
  
  def expire_parent_record_contacts_cache
    parent=self.parent_event
    if parent.present?
      parent.touch
      redis.delete_matched("views/events/#{parent.id}/show/contacts_tab")
      redis.delete_matched("views/events/#{parent.id}/showedit/contacts_tab/contacts_form")
    end
  end

  def add_parent_event_creation_note
    parent_event.add_note(I18n.translate("system_notes.contact_event_created", :locale => I18n.default_locale)) if parent_event.present?
  end

  def add_contact_event_creation_note
    self.add_note(I18n.translate("system_notes.contact_event_created", :locale => I18n.default_locale))
  end
  
  def validate_disposition_date_against_birth_date(base_errors)
    contact_bdate = self.try(:interested_party).try(:person_entity).try(:person).try(:birth_date)
    return if contact_bdate.nil?

    disposition_date = self.try(:participations_contact).try(:disposition_date)
    return if disposition_date.nil?

    if (disposition_date < contact_bdate)
      self.participations_contact.errors.add(:disposition_date, :cannot_precede_birth_date)
      base_errors['contacts'] = [:precede_birth_date, { :thing => I18n.t(:disposition) }]
    end
  end

end
