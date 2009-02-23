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

class EventTasksController < ApplicationController

  before_filter :find_event
  before_filter :can_update?
  
  def index
    respond_to do |format|
      format.html do
        @task = Task.new
        @task.event_id = @event.id
        render :action => 'new'
      end
      format.js do
        #Hmmmmm. Why do I have to add the .html.haml onto the partial?
        render :partial => 'tasks/list.html.haml', :locals => { :task_owner => @event }
      end
    end
  end

  def new
    @task = Task.new
    @task.event_id = @event.id
  end

  def edit
    @task = @event.tasks.find(params[:id])
  end

  def create
    @task = Task.new(params[:task])

    if !params[:task][:user_id].blank?
      @task.user_id = params[:task][:user_id]
    else
      @task.user_id = User.current_user.id
    end
    
    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html {redirect_to request.env["HTTP_REFERER"] }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @task = @event.tasks.find(params[:id])
    @task.user_id = params[:task][:user_id] unless params[:task][:user_id].blank?
    
    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to request.env["HTTP_REFERER"] }
        format.js { }
      else
        format.html { render :action => "edit" }
        format.js { flash[:error] = 'Could not update task.' }
      end
    end
    
  end

  private

  def can_update?
    @event ||= Event.find(params[:id])
    unless User.current_user.is_entitled_to_in?(:update_event, @event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      render :text => "Permission denied: You do not have update privileges for this jurisdiction", :status => 403
      return
    end
  end

  def find_event
    begin
      @event = Event.find(params[:event_id])
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => 'application', :status => 404 and return
    end
  end
end
