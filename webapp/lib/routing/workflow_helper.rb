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

module Routing
  # these methods will get mixed into Workflow::Specification
  module WorkflowHelper
    def assign_to_lhd(action=:assign_to_lhd)
      event action, :transitions_to => :assigned_to_lhd, :meta => {:priv_required => :route_event_to_any_lhd} do |jurisdiction, secondary_jurisdictions, note|
        unless self.jurisdiction.allows_current_user_to? :route_event_to_any_lhd
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        begin
          if route_to_jurisdiction jurisdiction, secondary_jurisdictions, note
            # We don't really want to do this here.  We'd rather use the on_entry hook of the workflow handler,
            # but this bug in jruby 1.2 won't let us: https://fisheye.codehaus.org/browse/JRUBY-3490
            # When bug is fixed, remove this and re-enable the on_entry handler in morbidity_event.rb and contact_event.rb, q.v.
            self.update_attributes(
              :investigation_started_date => nil,
              :investigation_completed_LHD_date => nil,
              :review_completed_by_state_date => nil,
              :investigator_id => nil,
              :event_queue_id => nil
            )
          else
            # We only want to change state if the primary jurisdiction changed, not secondaries
            halt
          end
        rescue Exception => e
          halt! e.message
        end
      end
      event :reset_to_new, :transitions_to => :new, :meta => {:priv_required => :route_event_to_any_lhd}
    end

    def promote_to_cmr
      event :promote_as_new, :transitions_to => :new, :meta => {:priv_required => :create_event} do
        unless self.jurisdiction.allows_current_user_to? :create_event
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Promoted from contact."
      end
       event :promote_as_accepted, :transitions_to => :accepted_by_lhd, :meta => {:priv_required => :create_event} do
        unless self.jurisdiction.allows_current_user_to? :create_event
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Promoted from contact."
      end
   end

    def accept_by_lhd(action=:accept)
      event action, :transitions_to => :accepted_by_lhd, :meta => {:priv_required => :accept_event_for_lhd} do |note|
        unless self.jurisdiction.allows_current_user_to? :accept_event_for_lhd
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Accepted by #{self.primary_jurisdiction.try(:name)}.\n#{note}"
      end
    end

    def reject_by_lhd(action=:reject)
      event action, :transitions_to => :rejected_by_lhd, :meta => {:priv_required => :accept_event_for_lhd} do |note|
        unless self.jurisdiction.allows_current_user_to? :accept_event_for_lhd
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Rejected by #{self.primary_jurisdiction.try(:name)}.\n#{note}"
      end
    end

    def approve_by_lhd(action=:approve)
      event action, :transitions_to => :approved_by_lhd, :meta => {:priv_required => :approve_event_at_lhd} do |note|
        unless self.jurisdiction.allows_current_user_to? :approve_event_at_lhd
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Approved at #{self.primary_jurisdiction.try(:name)}.\n#{note}"
      end
    end

    def assign_to_queue(action=:assign_to_queue)
      event action, :transitions_to => :assigned_to_queue, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless self.jurisdiction.allows_current_user_to? :route_event_to_investigator
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        note = "Routed to queue #{self.event_queue.try(:queue_name)}\n#{note}"
        add_note note
      end
    end

    def assign_to_investigator(action=:assign_to_investigator)
      event action, :transitions_to => :assigned_to_investigator, :meta => {:priv_required => :route_event_to_investigator} do |note|
        unless self.jurisdiction.allows_current_user_to? :route_event_to_investigator
          halt! "You do not have sufficient privileges to route events from this jurisdiction"
        end
        note = "Routed to investigator #{self.investigator.try(:best_name)}\n#{note}"
        add_note note
      end
    end

    def investigate(action=:investigate)
      event action, :transitions_to => :under_investigation, :meta => {:priv_required => :accept_event_for_investigation} do |note|
        unless self.jurisdiction.allows_current_user_to? :accept_event_for_investigation
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Accepted by Investigator\n#{note}"
      end
    end

    def reject_by_investigator(action=:reject)
      event action, :transitions_to => :rejected_by_investigator, :meta => {:priv_required => :accept_event_for_investigation} do |note|
        unless self.jurisdiction.allows_current_user_to? :accept_event_for_investigation
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Rejected for investigation.\n#{note}"
      end
    end

    def complete_investigation(action=:complete)
      event action, :transitions_to => :investigation_complete, :meta => {:priv_required => :investigate_event} do |note|
        unless self.jurisdiction.allows_current_user_to? :investigate_event
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Completed investigation.\n#{note}"
      end
    end

    def complete_and_close_investigation(action=:complete_and_close)
      event action, :transitions_to => :closed, :meta => {:priv_required => :investigate_event} do |note|
        unless self.jurisdiction.allows_current_user_to? :investigate_event
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Investigator closed investigation.\n#{note}"
      end
    end

    def reopen_by_manager(action=:reopen)
      event action, :transitions_to => :reopened_by_manager, :meta => {:priv_required => :approve_event_at_lhd} do |note|
        unless self.jurisdiction.allows_current_user_to? :approve_event_at_lhd
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Reopened by #{self.primary_jurisdiction.try(:name)} manager.\n#{note}"
      end
    end

    def reopen_by_state(action=:reopen)
      event action, :transitions_to => :reopened_by_state, :meta => {:priv_required => :approve_event_at_state} do |note|
        unless self.jurisdiction.allows_current_user_to? :approve_event_at_state
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Reopened by State.\n#{note}"
      end
    end

    def close(action=:approve)
      event action, :transitions_to => :closed, :meta => {:priv_required => :approve_event_at_state} do |note|
        unless self.jurisdiction.allows_current_user_to? :approve_event_at_state
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Approved by State.\n#{note}"
        self.review_completed_by_state_date = Date.today
      end
    end

    def close_contact(action=:approve)
      event action, :transitions_to => :closed, :meta => {:priv_required => :approve_event_at_lhd} do |note|
        unless self.jurisdiction.allows_current_user_to? :approve_event_at_lhd
          halt! "You do not have sufficient privileges to make this change"
        end
        add_note "Approved at #{self.primary_jurisdiction.try(:name)}.\n#{note}"
      end
    end

  end
end

Workflow::Specification.send(:include, Routing::WorkflowHelper)
