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

module TaskFilter

  def filter_tasks(options={})
    filter_methods = [:days_filter, :disease_filter, :jurisdictions_filter, :task_status_filter]
    conditions = {:sql => [], :values => []}
    if self.is_a? Event
      conditions[:sql] << "tasks.event_id = ?"
      conditions[:values] << self.id
    else
      filter_methods.unshift(:users_filter)
    end

    filter_methods.each do |filter|
      sql, values = send(filter, options)
      conditions[:sql] << sql if sql
      # build the conditional
      conditions[:values] += values if values
    end

    find_options = {}
    find_options[:conditions] = [conditions[:sql].join(' AND ')] + conditions[:values]
    find_options[:include] = {:event => {
        :disease_event => {
          :disease => {} },
        :all_jurisdictions => {
          :secondary_entity => {
            :place => {} } } } }
    Task.find(:all, find_options)
  end

  private

  def convert_integer(candidate)
    return if candidate.nil?
    begin
      Integer(candidate)
    rescue
      nil
    end
  end

  def users_filter(options)
    if options[:users].nil? || options[:users].empty?
      viewable_users = [User.current_user.id]
    else
      users = options[:users].collect(&:to_i)
      allowed_users = User.default_task_assignees.collect(&:id)
      viewable_users = users.select {|user| allowed_users.include?(user)}
    end
    ['tasks.user_id IN (?)', [viewable_users.uniq]]
  end

  def jurisdictions_filter(options)
    if options[:jurisdictions]
      jurisdictions = options[:jurisdictions].collect(&:to_i)
      allowed_jurisdictions = User.current_user.jurisdictions_for_privilege(:approve_event_at_state).collect(&:id)
      ['places.id IN (?)', [jurisdictions & allowed_jurisdictions]]
    else
      [nil, nil]
    end
  end

  def days_filter(options)
    look_ahead = convert_integer(options[:look_ahead])
    look_back  = convert_integer(options[:look_back])
    case
    when look_back && look_ahead
      ["tasks.due_date between ? and ?", [Date.today - look_back, Date.today + look_ahead]]
    when look_ahead
      ["tasks.due_date <= ?", [Date.today + look_ahead]]
    when look_back
      ["tasks.due_date >= ?", [Date.today - look_back]]
    else
      [nil, nil]
    end
  end

  def disease_filter(options)
    result = [nil, nil]
    unless options[:disease_filter].nil?
      result[0] =  "diseases.id IN (?)"
      result[1] = [options[:disease_filter]]
    end
    result
  end

  def task_status_filter(options)
    filter = options[:task_statuses] || []
    statuses = filter.empty? ? Task.valid_statuses : filter
    ['tasks.status IN (?)', [statuses]]
  end
end
