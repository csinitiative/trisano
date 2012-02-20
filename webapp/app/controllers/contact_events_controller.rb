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

class ContactEventsController < EventsController
  include ContactEventsHelper

  before_filter :load_parent, :only => [ :new, :create ]
  before_filter :can_promote?, :only => :event_type

  def index
    render :text => t("contact_event_no_index"), :status => 405
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @event }
      format.print { @print_options = params[:print_options] || [] }
    end
  end

  def new
    @event = ContactEvent.new(:parent_id => @parent_event.id)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @event }
    end
  end

  def edit
  end

  def create
    unless User.current_user.can?(:create_event, @parent_event)
      render :partial => "events/permission_denied",
        :locals => { :reason => t("no_event_create_privs"), :event => @event },
        :layout => true,
        :status => 403 and return
    end

    instantiate_contact

    respond_to do |format|
      if @event.save
        @event.reload
        @event.try(:address).try(:establish_canonical_address)

        redis.delete_matched("views/events/#{@parent_event.id}/edit/contacts_tab*")
        redis.delete_matched("views/events/#{@parent_event.id}/show/contacts_tab*")
        redis.delete_matched("views/events/#{@parent_event.id}/showedit/contacts_tab*")

        flash[:notice] = t("contact_event_created")
        format.html {
          redirect_to edit_contact_event_url(@event)
        }
        format.xml  { head :status => :created, :location => @event }
      else
        format.html { render :action => "new", :status => :unprocessable_entity }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    redis.delete_matched("views/events/#{@event.id}/*")

    go_back = params.delete(:return)

    # Assume that "save & exits" represent a 'significant' update
    @event.add_note(I18n.translate("system_notes.event_edited", :locale => I18n.default_locale)) unless go_back
    respond_to do |format|
      if @event.update_attributes(params[:contact_event])

        redis.delete_matched("views/events/#{@event.parent_id}/edit/contacts_tab*")
        redis.delete_matched("views/events/#{@event.parent_id}/show/contacts_tab*")
        redis.delete_matched("views/events/#{@event.parent_id}/showedit/contacts_tab*")

        flash[:notice] = t("contact_event_successfully_updated")
        format.html do
          if go_back
            redirect_to edit_contact_event_url(@event, @query_params)
          else
            url = params[:redirect_to]
            url = contact_event_url(@event, @query_params) if url.blank?
            redirect_to url
          end
        end
        format.xml  { head :ok }
        format.js   { render :inline => t("contact_saved"), :status => :created }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.js   do
          render :inline => t("contact_not_saved", :message => @event.errors.full_messages), :status => :unprocessable_entity 
        end
      end
    end
  end

  def copy_address
    @event = ContactEvent.find(params[:id])
    original_address = @event.parent_event.address
    #JSON to pass.  We shan't use a loop because we don't want all members.
    if original_address
      response.headers['X-JSON'] =
        "{street_number: \"" + original_address.street_number.to_s +
        "\", street_name: \"" + original_address.street_name +
        "\", unit_number: \"" + original_address.unit_number.to_s +
        "\", city: \"" + original_address.city +
        "\", state_id: \"" + original_address.state_id.to_s +
        "\", county_id: \"" + original_address.county_id.to_s +
        "\", postal_code: \"" + original_address.postal_code.to_s + "\"}"
    end
    head :ok
  end

  def destroy
    head :method_not_allowed
  end

  def event_type
    if m_event = @event.promote_to_morbidity_event
      flash[:notice] = t(:promoted_to_morbidity)
      redirect_to cmr_path(m_event)
    else
      flash.now[:error] = t("could_not_promote_to_morbidity")
      render :action => :edit, :status => :bad_request
    end
  end

  private

  def load_parent
    @parent_event = MorbidityEvent.find(parent_id_from_params)
  end

  def parent_id_from_params
    params[:parent_id].blank? ? params[:contact_event][:parent_id] : params[:parent_id]
  end

  def instantiate_contact
    if params[:from_person]
      @event = ContactEvent.new(:parent_id => @parent_event.id)
      person_entity = PersonEntity.find(params[:from_person])
      @event.build_interested_party(:primary_entity_id => person_entity.id)
    else
      @event = ContactEvent.new(params[:contact_event])
    end
  end

  def can_promote?
    unless User.current_user.can_create?(@event)
      render(:partial => 'events/permission_denied',
             :layout => true,
             :locals => { :reason => t("no_event_create_privs") },
             :status => 403) and return
    end
  end
end
