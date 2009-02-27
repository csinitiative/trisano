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

class EventNotesController < ApplicationController

  before_filter :find_event
  before_filter :can_view?

  def index
    @mode = params[:mode].blank? ? 'show' : params[:mode]
    conditions = ["event_id = ?", @event.id]
    unless params[:note_type].blank?
      conditions[0] << " AND note_type = ?"
      conditions << params[:note_type]
    end
    @notes = Note.find(:all, :conditions => conditions, :order => "created_at ASC")
  end

  private

  def can_view?
    @event ||= Event.find(params[:id])
    unless User.current_user.is_entitled_to_in?(:view_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      render :text => "Permission denied: You do not have view privileges for this jurisdiction", :status => 403
      return
    end
  end

  def find_event
    begin
      @event = Event.find(params[:event_id])
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => 'application', :status => 404 and return
    end
  end
  
end
