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

module DashboardHelper
  extensible_helper

  def render_dashboard_sections
    dashboard_sections.each do |method|
      self.send method
    end
  end

  def dashboard_sections
    [
      :render_dashboard_tasks,
      :render_dashboard_tools
    ]
  end

  def render_dashboard_tasks
    haml_tag(:h2) { haml_concat I18n.t('tasks') }
    haml_tag :span, :style => 'clear: both;' do
      haml_concat(
        link_to_function(t('change_filter'), "Effect.toggle('task_view_settings')") +
        "&nbsp;|&nbsp;" +
        link_to(I18n.t('view_on_calendar'), calendar_path(:month => Time.now.month, :year => Time.now.year))
      )
    end

    haml_tag :div, :id => 'task_view_settings', :style => 'display: none;' do
      haml_concat(render :partial => 'filter_tasks_form')
    end
    haml_tag :div, :id => 'tasks', :style => 'clear: both;' do
      haml_concat(render :partial => 'tasks/list', :locals => { :task_owner => User.current_user })
    end
  end

  def render_dashboard_tools
    if User.current_user.is_entitled_to?(:view_access_records)
      haml_tag(:h2) { haml_concat I18n.t('tools') }
      haml_concat(link_to I18n.t('event_access_records'), access_records_path, :id => "access_records_tool")
    end
  end

end
