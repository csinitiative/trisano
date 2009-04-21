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

class EventFormsController < AdminController

  before_filter :find_event

  def index
    @event.get_investigation_forms
    event_type = @event.class.name.underscore

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
    if forms_to_add.empty? 
      flash[:error] = 'No forms were selected for addition to this event.'
    else
      begin
        @event.add_forms(forms_to_add)
      rescue ArgumentError, ActiveRecord::RecordNotFound
        render :file => "#{RAILS_ROOT}/public/422.html", :layout => 'application', :status => 422 and return
      rescue RuntimeError
        render :file => "#{RAILS_ROOT}/public/500.html", :layout => 'application', :status => 500 and return
      else
        flash[:notice] = 'The list of forms in use was successfully updated.'
      end
    end
    redirect_to event_forms_path(@event)
  end

  def destroy
    forms_to_remove = params[:forms_to_remove] || []
    if forms_to_remove.empty?
      flash[:error] = 'No forms were selected for removal from this event.'
    else
      if @event.remove_forms(forms_to_remove)
        flash[:notice] = 'The list of forms in use was successfully updated.'
      else
        flash[:notice] = 'Unable to remove forms from this event'
      end
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
