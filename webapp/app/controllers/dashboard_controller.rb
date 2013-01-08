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

class DashboardController < ApplicationController

  # Creating a controller for a single user task ajax call seemed a
  # little heavy. If a full user task mvc shows up, this call should
  # be merged in there.
  def index
    @user = User.current_user
    if has_a_filter_applied?(params)
      @user.store_as_task_view_settings(params)
      render
    else
      redirect_to url_for(params.merge(@user.task_view_settings))
    end
  end

  def calendar
    calendar_setup(params)
  end
  
  private

  def calendar_setup(params)
    @month = params[:month].blank? ? Time.now.month : params[:month].to_i
    @year = params[:month].blank? ? Time.now.year : params[:year].to_i
    start_date = Date.new(@year, @month) - 1.day
    end_date = start_date.advance(:months => 1) + 3.days
    @tasks = Task.find_all_by_user_id(User.current_user.id, :conditions => ["due_date BETWEEN ? AND ?", start_date, end_date], :include => :category)
  end

  def has_a_filter_applied?(params)
    params.keys.any? { |param| User.task_view_params.include?(param.to_sym) }
  end

end
