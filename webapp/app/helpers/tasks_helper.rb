# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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
    task_action_links(task, :controller => :event_tasks, :owner_id => task.event_id)
  end

  def user_task_action_links(task)
    task_action_links(task, :controller => :user_tasks, :owner_id => task.user_id)
  end

  def task_action_links(task, options = {})
    unless User.current_user.is_entitled_to_in?(:update_event, task.event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
      return task.status
    end
    result = ""
    options = (params || {}).merge(options)
    options = options.merge(:action => 'update', :id => task.id)
    path = update_status_path(options)

    result << %Q{<select id="task-status-change-#{task.id}" onchange="updateStatusRequest('#{path}', this.value)">}
    result << options_for_select(Task.status_array, task.status)
    result << "</select>"
    result << "<br/>"

    result << link_to(t(:edit_event), edit_event_path(task.event))

    result << "&nbsp;|&nbsp;"
    result << link_to(t(:edit_task), edit_event_task_path(task.event, task))
    unless task.due_date.nil?
      result << "&nbsp;|&nbsp;"
      result << link_to(t(:calendar_view), calendar_path(:month => task.due_date.month, :year => task.due_date.year))
    end
  end

  def sort_urls(task_owner)
    prefix = task_owner.is_a?(Event) ? 'event' : 'user'
    %w(due_date name notes category_name priority user_name status disease_name).inject({}) do |memo, field|
      memo[field] = params.merge(:controller => "#{prefix}_tasks".to_sym,
        :action => :index,
        "#{prefix}_id".to_sym => task_owner.id,
        :tasks_ordered_by =>field)
      memo[field]['id'] = h(memo[field]['id'])
      memo[field]['tab_index'] = h(memo[field]['tab_index'])
      memo
    end
  end

  private

  # Manually builds the URL for updating via the Ajaxy status drop-down. Doesn't do a
  # straight merge of options because there can be some extra cruft in there that
  # throws off the update. Could be cleaned up a bit, but works as is across the various
  # places the task list is displayed.
  def update_status_path(options)
    result = ""

    url_options = {
      :controller => options[:controller],
      :action => options["action"],
      :id => options["id"]
    }

    if options[:controller].to_s.split('_')[0] == "event"
      url_options[:event_id] = options["owner_id"]
    else
      url_options[:user_id] = options["owner_id"]
    end

    User.task_view_params.each do |param|
      url_options[param] = options[param] unless options[param].nil?
    end

    result << url_for( url_options )
  end


end
