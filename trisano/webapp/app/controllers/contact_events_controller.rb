# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

  def auto_complete_for_lab_name
    entered_name = params[:contact_event][:new_lab_attributes].first[:name]
    @items = Place.find(:all, :select => "DISTINCT ON (entity_id) entity_id, name", 
      :conditions => [ "LOWER(name) LIKE ? and place_type_id IN 
                       (SELECT id FROM codes WHERE code_name = 'placetype' AND the_code = 'L')", entered_name.downcase + '%'],
      :order => "entity_id, created_at ASC, name ASC",
      :limit => 10
    )
    render :inline => '<ul><% for item in @items %><li id="lab_name_id_<%= item.entity_id %>"><%= h item.name %></li><% end %></ul>'
  end

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
    params[:contact_event][:existing_lab_attributes] ||= {}
    params[:contact_event][:existing_hospital_attributes] ||= {}
    params[:contact_event][:existing_diagnostic_attributes] ||= {}
    params[:contact_event][:existing_telephone_attributes] ||= {}

    respond_to do |format|
      if @event.update_attributes(params[:contact_event])
        flash[:notice] = 'Contact event was successfully updated.'
        format.html { redirect_to(contact_event_url(@event)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    head :method_not_allowed
  end

end
