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

class DashboardController < ApplicationController

  # Creating a controller for a single user task ajax call seemed a
  # little heavy. If a full user task mvc shows up, this call should
  # be merged in there.
  def index
    respond_to do |format|      
      @user = User.current_user
      format.html do
        if has_a_filter_applied?(params)
          query_options = {
            :look_ahead => params[:look_ahead], 
            :look_back => params[:look_back]}
          @user.update_attribute(:task_view_settings, query_options)
        elsif @user.has_task_view_settings?
          redirect_to url_for(params.merge(@user.task_view_settings))
          return
        end        
        render
      end
      format.js do
        # Hmmm. not sure why I had to add the .html.haml here.
        render :partial => 'event_tasks/list.html.haml', :locals => {:task_owner => @user} 
      end
    end
  end

  private 

  def has_a_filter_applied?(params)
    params.has_key?(:look_ahead) || params.has_key?(:look_back)
  end

end
