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

class EncounterEventsController < EventsController
  include EncounterEventsHelper

  def index
    render :text => t("encounter_event_no_index"), :status => 405
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @event }
    end
  end

  def new
    render :text => t("encounter_event_no_new"), :status => 405
  end

  def edit
  end

  def create
    render :text => t("encounter_event_no_create"), :status => 405
  end

  def update
    redis.delete_matched("views/events/#{@event.id}/*")

    go_back = params.delete(:return)

    respond_to do |format|
      @event.validate_against_bday = true
      if @event.update_attributes(params[:encounter_event])
        flash[:notice] = t("encounter_event_updated")
        format.html {
          if go_back
            redirect_to edit_encounter_event_url(@event, @query_params)
          else
            redirect_to encounter_event_url(@event, @query_params)
          end
        }
        format.xml  { head :ok }
        format.js   { render :inline => t("encounter_saved"), :status => :created }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.js   { render :inline => t("encounter_not_saved", :messages => @event.errors.full_messages), :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    head :method_not_allowed
  end

end
