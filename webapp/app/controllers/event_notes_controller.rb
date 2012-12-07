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

class EventNotesController < ApplicationController

  before_filter :find_event
  before_filter :can_view_event?

  def index
    @mode = params[:mode].blank? ? 'show' : params[:mode]
    conditions = ["event_id = ?", @event.id]
    unless params[:note_type].blank?
      conditions[0] << " AND note_type IN (?)"
      conditions << params[:note_type].split(", ")
    end
    @notes = Note.find(:all, :conditions => conditions, :order => "created_at DESC")
  end
end
