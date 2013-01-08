# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

  # Note show and destroy are blocked is config/routes
  before_filter :can_update_event?, :only => [:new, :edit, :create, :update]
  before_filter :can_view_event?, :only => [:index]

  after_filter TouchEventFilter, :only => [:create, :update]

  def index
    respond_to do |format|
      format.html
      format.js do
        render :partial => 'tasks/list.html.haml', :locals => { :task_owner => @event }
      end
      format.xml do
        render '/event_tasks/index.xml.haml', :locals => { :event => @event }
      end
    end
  end

  def new
    @task = Task.new
    @task.event_id = @event.id
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end

  def edit
    @task = @event.tasks.find(params[:id])
  end

  def create
    # ignore if present in the form; take from the URL
    params[:task][:event_id] = params[:event_id]
    @task = Task.new params[:task]

    if !params[:task][:user_id].blank?
      @task.user_id = params[:task][:user_id]
    else
      @task.user_id = User.current_user.id
    end

    respond_to do |format|
      if @task.save
        flash[:notice] = t("event_task_created")
        format.html { redirect_to event_tasks_path(@event) }
        format.js {}
        format.xml { head :ok }
      else
        format.html { render :action => "new" }
        format.js { render :action => "new" }
        format.xml { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @task = @event.tasks.find(params[:id])
    @task.user_id = params[:task][:user_id] unless params[:task][:user_id].blank?

    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = t("event_task_updated")
        format.html { redirect_to edit_event_task_path(@event, @task) }
        format.js { }
      else
        format.html { render :action => "edit" }
        format.js { flash[:error] = t("could_not_update_task") }
      end
    end

  end

end
