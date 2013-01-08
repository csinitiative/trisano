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

class UserTasksController < ApplicationController

  before_filter :find_user

  def index
    respond_to do |format|
      format.js do
        render :partial => "tasks/list.html.haml", :locals => {:task_owner => @user}
      end
    end
  end

  def update
    @task = @user.tasks.find(params[:id])
    
    if @task.update_attributes(params[:task])
      flash[:notice] = t("task_successfully_updated")
    else
      flash[:error] = t("task_update_failed")
    end
    
  end

  private

  def find_user
    begin
      @user = User.find(params[:user_id])
    rescue
      render :file => static_error_page_path(404), :layout => 'application', :status => 404 and return
    end
  end
end
