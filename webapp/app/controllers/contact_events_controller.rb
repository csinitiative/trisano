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

class ContactEventsController < EventsController

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
    render :text => t("contact_event_no_new"), :status => 405
  end

  def edit
    # Filter #can_update? is called which loads up @event with the found event. Nothing to do here.
  end

  def create
    render :text => t("contact_event_no_create"), :status => 405
  end

  def update
    go_back = params.delete(:return)

    # Assume that "save & exits" represent a 'significant' update
    @event.add_note(I18n.translate("system_notes.event_edited", :locale => I18n.default_locale)) unless go_back

    respond_to do |format|
      if @event.update_attributes(params[:contact_event])
        flash[:notice] = t("contact_event_successfully_updated")
        format.html {
          if go_back
            redirect_to edit_contact_event_url(@event, @query_params)
          else
            redirect_to contact_event_url(@event, @query_params)
          end
        }
        format.xml  { head :ok }
        format.js   { render :inline => t("contact_saved"), :status => :created }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.js   { render :inline => t("contact_not_saved", :message => @event.errors.full_messages), :status => :unprocessable_entity }
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
end
