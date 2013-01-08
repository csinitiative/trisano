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

class EventQueue < ActiveRecord::Base
  belongs_to :jurisdiction, :class_name => 'PlaceEntity', :foreign_key => :jurisdiction_id

  validates_presence_of :queue_name, :jurisdiction_id
  validates_length_of :queue_name, :maximum => 100, :allow_blank => true
  validates_uniqueness_of :queue_name, :scope => :jurisdiction_id, :case_sensitive => false

  before_destroy :fix_up_events
  after_destroy :fix_up_views

  named_scope :queues_for_jurisdictions, lambda { |jurisdiction_ids|
    { :conditions => { :jurisdiction_id => jurisdiction_ids } }
  }

  def name_and_jurisdiction join_char=' - '
    [self.queue_name, self.jurisdiction.place.short_name].join join_char
  end

  private

  def fix_up_events
    Event.find(:all, :conditions => "event_queue_id = #{self.id}").each do |event|
      note = I18n.translate("system_notes.event_queue_deleted", :queue_name => self.queue_name, :locale => I18n.default_locale)

      begin
        event.reset
        note << " "
        note << I18n.translate("system_notes.event_needs_reassignment", :locale => I18n.default_locale)
      rescue
      end

      event.add_note(note)
      event.event_queue_id = nil
      event.save!
    end
  end

  def fix_up_views
    User.find(:all, :conditions => "event_view_settings IS NOT NULL").each do |user|
      # Remember, user.event_view_settings is a serialized hash
      user.save! if user.event_view_settings[:queues] && user.event_view_settings[:queues].delete(self.queue_name)
    end
  end

end
