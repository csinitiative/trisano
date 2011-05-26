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

class ProdUpdateEventViewSettingsQueues < ActiveRecord::Migration
  def self.up
    return unless ENV['UPGRADE']
    transaction do
      users_with_queue_filters.each do |user|
        execute ViewSettingsConverter.new(user).to_update_sql
      end
    end
  end

  def self.down
  end

  def self.users_with_queue_filters
    execute(<<-SQL)
      SELECT id, event_view_settings FROM users
      WHERE event_view_settings ~ ':queues:.*-'
    SQL
  end

  class ViewSettingsConverter
    class << self
      def queue_ids
        @queue_ids ||= Hash[*conn.execute(<<-SQL).map { |t| [t["queue_name"], t["id"]] }.flatten]
          SELECT id, queue_name FROM event_queues
        SQL
      end

      private

      def conn
        ActiveRecord::Base.connection
      end
    end

    def initialize(user_data)
      @user_data = user_data
    end

    def to_update_sql
      <<-SQL
        UPDATE users SET event_view_settings = '#{converted_settings.to_yaml}'
        WHERE id = #{user_id}
      SQL
    end

    private

    def converted_settings
      return @converted_settings if @converted_settings
      @converted_settings = YAML::load @user_data["event_view_settings"]
      @converted_settings[:queues] = @converted_settings[:queues].map do |name|
        queue_ids[name]
      end
      @converted_settings
    end

    def user_id
      @user_data["id"]
    end

    def queue_ids
      self.class.queue_ids
    end
  end

end
