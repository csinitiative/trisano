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
class MigrateParentDataToEventTypeTransition < ActiveRecord::Migration
  def self.up
    EventTypeTransition.transaction do
      promoted_morbidity_events = Event.find(:all, :conditions => ["parent_id IS NOT NULL AND type = ?", "morbidity_event"])
      promoted_morbidity_events.each do |event|
        # Prior to EventTypeTransition, the only transition was ContactEvent > MorbidityEvent
        ett = EventTypeTransition.new(:event_id => event.id, :was => ContactEvent, :became => MorbidityEvent, :created_at => event.created_at)
        ett.save!
      end

      raise "Not all event transitions migrated" if promoted_morbidity_events.count != EventTypeTransition.count
    end
  end

  def self.down
    EventTypeTransition.destroy_all
  end
end
