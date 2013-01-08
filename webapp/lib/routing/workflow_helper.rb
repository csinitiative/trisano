# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

module Routing
  # these methods will get mixed into Workflow::Specification
  module WorkflowHelper
    def assign_to_lhd(action=:assign_to_lhd)
      event action, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless self.jurisdiction.allows_current_user_to? :route_event_to_any_lhd
          halt!(I18n.translate("insufficient_privileges_to_route_from_jurisdiction"))
        end
        begin
          if route_to_jurisdiction(jurisdiction, secondary_jurisdictions, note)
            # We don't really want to do this here.  We'd rather use the on_entry hook of the workflow handler,
            # but this bug in jruby 1.2 won't let us: https://fisheye.codehaus.org/browse/JRUBY-3490
            # When bug is fixed, remove this and re-enable the on_entry handler in morbidity_event.rb and contact_event.rb, q.v.
            # or, move this into human_event#route_to_jurisdiction
            self.update_attributes(
              :investigation_started_date => nil,
              :investigation_completed_LHD_date => nil,
              :review_completed_by_state_date => nil,
              :investigator_id => nil,
              :event_queue_id => nil
            )
          else
            # We only want to change state if the primary jurisdiction changed, not secondaries
            halt :no_jurisdiction_change
          end
        rescue Exception => e
          halt! e.message
        end
      end
      event :reset_to_new, :transitions_to => :new, :meta => {:priv_required => :route_event_to_any_lhd}
    end

    def promote_to_morbidity_event
      event :promote_as_new, :transitions_to => :new, :meta => {:priv_required => :create_event} do
        add_note I18n.translate("system_notes.event_promoted_from_to", :locale => I18n.default_locale, :from => self.type.humanize.downcase, :to => "morbidity event")
      end
      event :promote_as_accepted, :transitions_to => :accepted_by_lhd, :meta => {:priv_required => :create_event} do
        add_note I18n.translate("system_notes.event_promoted_from_to", :locale => I18n.default_locale, :from => self.type.humanize.downcase, :to => "morbidity event")
      end
    end

    def accept_by_lhd(action=:accept)
      event action, :transitions_to => :accepted_by_lhd, :meta => {:priv_required => :accept_event_for_lhd} do |note|
        unless self.jurisdiction.allows_current_user_to? :accept_event_for_lhd
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_accepted_by",
            :jurisdiction_name => self.jurisdiction.try(:name),
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

    def reject_by_lhd(action=:reject)
      event action, :transitions_to => :rejected_by_lhd, :meta => {:priv_required => :accept_event_for_lhd} do |note|
        unless self.jurisdiction.allows_current_user_to? :accept_event_for_lhd
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_rejected_by",
            :jurisdiction_name => self.jurisdiction.try(:name),
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

    def approve_by_lhd(action=:approve)
      event action, :transitions_to => :approved_by_lhd, :meta => {:priv_required => :approve_event_at_lhd} do |note|
        unless self.jurisdiction.allows_current_user_to? :approve_event_at_lhd
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_approved_at",
            :jurisdiction_name => self.jurisdiction.try(:name),
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

    def assign_to_queue(action=:assign_to_queue)
      event action, :transitions_to => :assigned_to_queue, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless self.jurisdiction.allows_current_user_to? :route_event_to_investigator
          halt!(I18n.translate("insufficient_privileges_to_route_from_jurisdiction"))
        end
        add_note(I18n.translate("system_notes.workflow_routed_to_queue",
            :name => self.event_queue.try(:queue_name),
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

    def assign_to_investigator(action=:assign_to_investigator)
      event action, :transitions_to => :assigned_to_investigator, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless self.jurisdiction.allows_current_user_to? :route_event_to_investigator
          halt!(I18n.translate("insufficient_privileges_to_route_from_jurisdiction"))
        end
        add_note(I18n.translate("system_notes.workflow_routed_to_investigator",
            :name => self.investigator.try(:best_name),
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

    def investigate(action=:investigate)
      event action, :transitions_to => :under_investigation, :meta => {:priv_required => :accept_event_for_investigation} do |note|
        unless self.jurisdiction.allows_current_user_to? :accept_event_for_investigation
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_accepted_by_investigator",
            :note => note,
            :name => self.investigator.try(:best_name),
            :locale => I18n.default_locale)
        )
      end
    end

    def reject_by_investigator(action=:reject)
      event action, :transitions_to => :rejected_by_investigator, :meta => {:priv_required => :accept_event_for_investigation} do |note|
        unless self.jurisdiction.allows_current_user_to? :accept_event_for_investigation
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_rejected_for_investigation",
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

    def complete_investigation(action=:complete)
      event action, :transitions_to => :investigation_complete, :meta => {:priv_required => :investigate_event} do |note|
        unless self.jurisdiction.allows_current_user_to? :investigate_event
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_completed_investigation",
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

    def complete_and_close_investigation(action=:complete_and_close)
      event action, :transitions_to => :closed, :meta => {:priv_required => :investigate_event} do |note|
        unless self.jurisdiction.allows_current_user_to? :investigate_event
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_investigator_closed_investigation",
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

    def reopen_by_manager(action=:reopen)
      event action, :transitions_to => :reopened_by_manager, :meta => {:priv_required => :approve_event_at_lhd} do |note|
        unless self.jurisdiction.allows_current_user_to? :approve_event_at_lhd
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_reopened_by",
            :jurisdiction_name => self.jurisdiction.try(:name),
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

    def reopen_by_state(action=:reopen)
      event action, :transitions_to => :reopened_by_state, :meta => {:priv_required => :approve_event_at_state} do |note|
        unless self.jurisdiction.allows_current_user_to? :approve_event_at_state
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_reopened_by_state",
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

    def close(action=:approve)
      event action, :transitions_to => :closed, :meta => {:priv_required => :approve_event_at_state} do |note|
        unless self.jurisdiction.allows_current_user_to? :approve_event_at_state
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_approved_by_state",
            :note => note,
            :locale => I18n.default_locale)
        )
        self.review_completed_by_state_date = Date.today
      end
    end

    def close_contact(action=:approve)
      event action, :transitions_to => :closed, :meta => {:priv_required => :approve_event_at_lhd} do |note|
        unless self.jurisdiction.allows_current_user_to? :approve_event_at_lhd
          halt!(I18n.translate("insufficient_privileges_for_change"))
        end
        add_note(I18n.translate("system_notes.workflow_approved_at",
            :jurisdiction_name => self.jurisdiction.try(:name),
            :note => note,
            :locale => I18n.default_locale)
        )
      end
    end

  end
end

Workflow::Specification.send(:include, Routing::WorkflowHelper)
