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
    # Filter out forms already associated with the event
    event_type = @event.class.name.underscore
    @forms_available = Form.find_by_sql("SELECT * FROM forms WHERE status = 'Live' AND event_type = '#{event_type}' AND id NOT IN (SELECT form_id FROM form_references WHERE event_id = #{params[:event_id]})")
    @forms_in_use = Form.find_by_sql("SELECT * FROM forms WHERE status = 'Live' AND event_type = '#{event_type}' AND id IN (SELECT form_id FROM form_references WHERE event_id = #{params[:event_id]})")
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
