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

module EventCalendarHelper
  def event_calendar
    return if @year.blank? or @month.blank?
    result = ""

    next_month = (@month == 12) ? 1 : @month+1
    previous_month = (@month == 1) ? 12 : @month-1

    next_year = (@month == 12) ? @year+1 : @year
    previous_year = (@month == 1) ? @year-1 : @year

    result << calendar(:year => @year,
      :month => @month,
      :abbrev => (0..-1),
      :previous_month_text => link_to(
        "<< #{translated_month_names[previous_month]}",
        :action => :calendar,
        :month => previous_month,
        :year => previous_year),
      :next_month_text => link_to(
        "#{translated_month_names[next_month]} >>",
        :action => :calendar,
        :month => next_month,
        :year => next_year)
    ) do |d|

      date = Date.new(@year, @month, d.mday)

      tasks_on_day = @tasks.collect { |task|
        task if (task.due_date == date)
      }.compact

      task_details = ""
      task_details << "<ul>" unless tasks_on_day.empty?

      tasks_on_day.each do |task|

        case task.status
        when "pending"
          task_style = "task-list-pending"
        when "complete"
          task_style = "task-list-complete"
        when
          task_style = "task-list-na"
        end

        task_details << "<li class='#{task_style}'>"

        if task.priority == "high"
          task_details << "&uarr;"
        elsif task.priority == "low"
          task_details << "&darr;"
        end

        task_details << "#{link_to(task.name, edit_event_task_path(task.event, task))}"
        task_details << ", <i>#{task.category.code_description}</i>" unless task.category.blank?
        task_details << "</li>"
      end

      task_details << "</ul>" unless tasks_on_day.empty?

      ["#{d.mday}<br/><br/>#{task_details}"]

    end

    result
  end

end
