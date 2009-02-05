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

class EventTasksController < AdminController

  before_filter :find_event

  def index
    @task = Task.new
    @task.event_id = @event.id
    render :action => 'new'
  end

  def new
    @task = Task.new
    @task.event_id = @event.id
  end

  def create
    @task = Task.new(params[:task])
    @task.user_id = User.current_user.id

    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html {redirect_to request.env["HTTP_REFERER"] }
      else
        format.html { render :action => "new" }
      end
    end
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
