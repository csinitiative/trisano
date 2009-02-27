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

module DashboardHelper

  def task_filter_description(params)
    parts = []
    unless params[:look_back].blank?
      text = case params[:look_back]
             when '0': 'today'
             when '1': 'yesterday'
             else      "#{Date.today - params[:look_back].to_i}"
             end
      parts << "starting from #{text}"
    end
    unless params[:look_ahead].blank?
      text = case params[:look_ahead]
             when '0': 'today'
             when '1': 'tomorrow'
             else      "#{Date.today + params[:look_ahead].to_i}"
             end
      parts << "through #{text}"
    end
    parts = ['for today'] if params[:look_ahead] == '0' && params[:look_back] == '0'
    "Showing all tasks #{parts.join(' ')}".strip + "."
  end
  
end
