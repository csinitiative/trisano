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

module TasksHelper

  def event_task_action_links(task)
    task_action_links(task, :controller => :event_tasks, :event_id => task.event_id)
  end

  def user_task_action_links(task)
    task_action_links(task, :controller => :user_tasks, :user_id => task.user_id)
  end
  
  def task_action_links(task, options = {})
    options = (params || {}).merge(options)
    options = options.merge(:action => 'update', :id => task.id)

    result = ""
    if task.status != "complete"
      result << link_to_remote("Complete", :url => options.merge(:task => {'status' => 'complete'}), :method => :put )
    else
      result << "<b>Complete</b>"
    end

    result << "&nbsp;|&nbsp;"
    
    if task.status != "not_applicable"
      result << link_to_remote("N/A", :url => options.merge(:task => {'status' => "not_applicable"}), :method => :put )
    else
      result << "<b>N/A</b>"
    end
    
  end

  def sort_urls(task_owner)
    prefix = task_owner.is_a?(Event) ? 'event' : 'user'
    %w(due_date name notes category_name priority user_name).inject({}) do |memo, field|
      memo[field] = params.merge(:controller => "#{prefix}_tasks".to_sym,
                                 :action => :index,
                                 "#{prefix}_id".to_sym => task_owner.id, 
                                 :tasks_ordered_by => field)
      memo
    end
  end
    
end
