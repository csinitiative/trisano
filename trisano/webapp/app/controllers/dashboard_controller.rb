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
      format.html      
      format.js do
        # Hmmm. not sure why I had to add the .html.haml here.
        render :partial => 'event_tasks/list.html.haml', :locals => {:task_owner => User.current_user} 
      end
    end
  end

end
