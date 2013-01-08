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

Given /^the following tasks for the event$/ do |table|
  table.hashes.each do |hash|
    date_string = hash["due_date"]

    case date_string
    when "today"
      date = DateTime.now
    when "tomorrow"
      date = DateTime.now + 1.day
    when "next month"
      date = DateTime.now + 1.month
    end

    hash = hash.merge(
      "due_date" => date,
      "category" => ExternalCode.find_by_code_name_and_code_description("task_category", hash["category"]),
      "user_id" => @current_user.id,
      "event_id" => @event.id
    )
    task = Factory(:task, hash)
    task.status = hash["status"].gsub(" ", "_").downcase
    task.save!
  end
end

Then /^the task "([^\"]*)" should be styled as (.+)$/ do |task_name, style|
  style = "na" if style == "not applicable"
  response.should have_xpath("//li[@class='task-list-#{style}']//a[contains(text(),'#{task_name}')]")
end

