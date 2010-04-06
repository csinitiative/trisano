# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

class PlaceEventsController < EventsController
  def index
    render :text => t("no_direct_place_event_access"), :status => 405
  end

  def show
    # @event initialized in can_view? filter

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def new
    render :text => t("no_direct_place_event_creation"), :status => 405
  end

  def edit
    # Filter #can_update? is called which loads up @event with the found event. Nothing to do here.
  end

  def create
    render :text => t("no_direct_place_event_creation"), :status => 405
  end

  def update
    go_back = params.delete(:return)
    @event.add_note(t("system_notes.event_edited", :locale => I18n.default_locale)) unless go_back

    respond_to do |format|
      @event.validate_against_bday = true
      if @event.update_attributes(params[:place_event])
        flash[:notice] = t("place_event_updated")
        format.html {
          if go_back
            render :action => "edit"
          else
            redirect_to place_event_url(@event, @query_params)
          end
        }
        format.xml  { head :ok }
        format.js   { render :inline => t("place_event_saved"), :status => :created }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.js   { render :inline => t("place_event_not_saved", :message => @event.errors.full_messages), :status => :unprocessable_entity }
      end
    end
  end

end
