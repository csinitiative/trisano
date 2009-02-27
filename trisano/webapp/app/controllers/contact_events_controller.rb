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

class ContactEventsController < EventsController

  def index
    render :text => "Contacts can only be listed from the morbidity event show page of individuals who have contacts.", :status => 405
  end

  def show
    # @event initialized in can_view? filter

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def new
    render :text => "Contacts can only be created from within a morbidity event.", :status => 405
  end

  def edit
    # Filter #can_update? is called which loads up @event with the found event. Nothing to do here.
  end

  def create
    render :text => "Contacts can only be created from within a morbidity event.", :status => 405
  end

  def update
    go_back = params.delete(:return)
    
    # Assume that "save & exits" represent a 'significant' update
    @event.add_note("Edited event") unless go_back

    respond_to do |format|
      if @event.update_attributes(params[:contact_event])
        flash[:notice] = 'Contact event was successfully updated.'
        format.html { 
          if go_back
            render :action => "edit"
          else
            query_str = @tab_index ? "?tab_index=#{@tab_index}" : ""
            redirect_to(contact_event_url(@event) + query_str)
          end
        }
        format.xml  { head :ok }
        format.js   { render :inline => "Contact saved.", :status => :created }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.js   { render :inline => "Contact event not saved: <%= @event.errors.full_messages %>", :status => :unprocessable_entity }
      end
    end
  end

  def copy_address
    @event = ContactEvent.find(params[:id])
    original_address = @event.parent_event.interested_party.person_entity.address
    #JSON to pass.  We shan't use a loop because we don't want all members.
    response.headers['X-JSON'] = "{street_number: \"" + original_address.street_number.to_s +
      "\", street_name: \"" + original_address.street_name + 
      "\", unit_number: \"" + original_address.unit_number.to_s +
      "\", city: \"" + original_address.city +
      "\", state_id: \"" + original_address.state_id.to_s +
      "\", county_id: \"" + original_address.county_id.to_s +
      "\", postal_code: \"" + original_address.postal_code.to_s + "\"}"
    head :ok
  end

  def destroy
    head :method_not_allowed
  end

  def event_type
    if @event.promote_to_morbidity_event    
      redirect_to cmr_path(@event.id)
    else
      flash[:error] = 'Could not promote to morbidity event.'
      render :action => "show"
    end
  end
end
