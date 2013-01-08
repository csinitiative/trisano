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

class EventAccessRecordsController < ApplicationController

  before_filter :load_event

  def new
    @access_record = AccessRecord.new
  end

  def create
    @access_record = AccessRecord.new(params[:access_record])
    @access_record.event_id = @event.id
    @access_record.user_id = User.current_user.id
    @access_record.save ? redirect_to(redirect_path) : render(:action => "new")
  end

  private

  def load_event
    @event = Event.find(params[:event_id])
  end

  def redirect_path
    @event.is_a?(MorbidityEvent) ? cmr_path(@event) : self.send("#{@event.class.name.underscore}_path".to_sym, @event)
  end

end
