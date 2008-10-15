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
    super(:contact_event)
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
    prep_multimodels

    go_back = params.delete(:return)
    
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

  def destroy
    head :method_not_allowed
  end

  private

    def prep_multimodels
      params[:contact_event][:active_patient][:existing_telephone_attributes] ||= {}
      params[:contact_event][:active_patient][:existing_treatment_attributes] ||= {}
      params[:contact_event][:existing_lab_attributes] ||= {}
      params[:contact_event][:existing_hospital_attributes] ||= {}
      params[:contact_event][:existing_diagnostic_attributes] ||= {}
      params[:contact_event][:existing_clinician_attributes] ||= {}
    end
end
