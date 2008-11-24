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

class EventFormsController < AdminController

  before_filter :find_event

  def index
    @event.get_investigation_forms
    event_type = @event.class.name.underscore

    # Filter out forms already associated with the event
    @forms_in_use = @event.form_references.collect { |ref| ref.form }
    form_ids_in_use = @forms_in_use.map { |form| form.id }
    if form_ids_in_use.empty?
      @forms_available = Form.find(:all, :conditions => ["status = ? AND event_type = ?", 'Live', event_type])
    else
      @forms_available = Form.find(:all, :conditions => ["status = ? AND event_type = ? AND id NOT IN (?)", 'Live', event_type, form_ids_in_use])
    end
  end

  def create
    forms_to_add = params[:forms_to_add] || []
    # Don't dup forms already on this event.
    if forms_to_add.empty? 
      flash[:error] = 'No forms were selected for addition to this event.'
    elsif (forms_to_add - @event.form_references.map { |form| form.id}).all? do |form_id|
       #legitimate form?
        begin
          form = Form.find(form_id)
        rescue
          render :file => "#{RAILS_ROOT}/public/422.html", :layout => 'application', :status => 422 and return
        end
        @event.form_references.create(:form_id => form_id)
      end
      flash[:notice] = 'The list of forms in use was successfully updated.'
    else
      flash[:error] = 'There was an error during processing.'
    end
    redirect_to event_forms_path(@event)
  end

  private

  def find_event
    begin
      @event = Event.find(params[:event_id])
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => 'application', :status => 404 and return
    end
  end
end
