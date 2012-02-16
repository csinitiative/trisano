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

class PlaceEventsController < EventsController
  before_filter :load_parent, :only => [ :new, :create ]

  def index
    render :text => t("no_direct_place_event_access"), :status => 405
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @event }
    end
  end

  def new
    @event = PlaceEvent.new(:parent_id => @parent_event.id)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @event }
    end
  end

  def edit
  end

  def create
    unless User.current_user.can?(:create_event, @parent_event)
      render :partial => "events/permission_denied", :locals => { :reason => t("no_event_create_privs"), :event => @event }, :layout => true, :status => 403 and return
    end

    instantiate_place_event

    respond_to do |format|
      if @event.save
        @event.reload
        @event.try(:address).try(:establish_canonical_address)
        redis.delete_matched("views/events/#{@parent_event.id}/edit/epi_tab*")
        redis.delete_matched("views/events/#{@parent_event.id}/show/epi_tab*")
        redis.delete_matched("views/events/#{@parent_event.id}/showedit/epi_tab*")
        flash[:notice] = t("place_exposure_created")
        format.html {
          redirect_to edit_place_event_url(@event)
        }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new", :status => :unprocessable_entity }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    redis.delete_matched("views/events/#{@event.id}/*")
    redis.delete_matched("views/events/#{@event.parent_id}/edit/epi_tab*")
    redis.delete_matched("views/events/#{@event.parent_id}/show/epi_tab*")
    redis.delete_matched("views/events/#{@event.parent_id}/showedit/epi_tab*")

    go_back = params.delete(:return)
    @event.add_note(t("system_notes.event_edited", :locale => I18n.default_locale)) unless go_back

    respond_to do |format|
      @event.validate_against_bday = true
      if @event.update_attributes(params[:place_event])
        flash[:notice] = t("place_event_updated")
        format.html do
          if go_back
            redirect_to edit_place_event_url(@event)
          else
            url = params[:redirect_to]
            url = place_event_url(@event, @query_params) if url.blank?
            redirect_to url
          end
        end
        format.xml  { head :ok }
        format.js   { render :inline => t("place_event_saved"), :status => :created }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.js   { render :inline => t("place_event_not_saved", :message => @event.errors.full_messages), :status => :unprocessable_entity }
      end
    end
  end

  private

  def load_parent
    @parent_event = MorbidityEvent.find(parent_id_from_params)
  end

  def parent_id_from_params
    params[:parent_id].blank? ? params[:place_event][:parent_id] : params[:parent_id]
  end

  def instantiate_place_event
    if params[:from_place]
      @event = PlaceEvent.new(:parent_id => @parent_event.id)
      @event.build_interested_place(:primary_entity_id => PlaceEntity.find(params[:from_place]).id)
    else
      @event = PlaceEvent.new(params[:place_event])
    end
  end
end
