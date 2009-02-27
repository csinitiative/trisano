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

class UserTasksController < ApplicationController

  before_filter :find_user

  # we only respond to an ajax request.
  def index
    respond_to do |format|
      format.js do
        #Hmmmmm. Why do I have to add the .html.haml onto the partial?
        render :partial => "tasks/list.html.haml", :locals => {:task_owner => @user}
      end
    end
  end

  def update
    @task = @user.tasks.find(params[:id])
    
    # Updates currently only come in through a simple status-changing Ajax call
    if @task.update_attributes(params[:task])
      flash[:notice] = 'Task was successfully updated.'
    else
      flash[:error] = 'Could not update task.'
    end
    
  end

  private

  def find_user
    begin
      @user = User.find(params[:user_id])
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => 'application', :status => 404 and return
    end
  end
end
