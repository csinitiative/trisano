# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the terms of the
# GNU Affero General Public License as published by the Free Software Foundation, either 
# version 3 of the License, or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
# See the GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License along with TriSano. 
# If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

class EventQueue < ActiveRecord::Base
  belongs_to :jurisdiction, :class_name => 'Entity', :foreign_key => :jurisdiction_id
  validates_presence_of :queue_name, :jurisdiction_id
  before_save :replace_white_space
  before_destroy :fix_up_events
  after_destroy :fix_up_views

  class << self
    def queues_for_jurisdictions(jurisdiction_ids)
      jurisdiction_ids = jurisdiction_ids.to_a
      find(:all, :conditions => ["jurisdiction_id IN (?)", jurisdiction_ids])
    end
  end

  private

  def replace_white_space
    self.queue_name = Utilities::make_queue_name(self.queue_name) + "-" + Utilities::make_queue_name(jurisdiction.current_place.short_name)
  end

  def fix_up_events
    Event.find(:all, :conditions => "event_queue_id = #{self.id}").each do |event|
      note = "Event queue '#{self.queue_name}' has been deleted. Event has been moved out of that queue."

      if event.event_status == "ASGD-INV" && event.investigator.nil?     # If the event has been assigned to this queue, but not yet accepted
        event.event_status = "ACPTD-LHD"                                 # then set the status back to 'accepted by LHD' and add a note
        note += " Event has not yet been accepted for investigation and should be reassigned."
      end

      event.new_note_attributes = { :note => note }
      event.event_queue_id = nil
      event.save!
    end
  end

  def fix_up_views
    User.find(:all, :conditions => "event_view_settings IS NOT NULL").each do |user|
      # Remember, user.event_view_settings is a serialized hash
      user.save! if user.event_view_settings[:queues].delete(self.queue_name)
    end
  end

end
