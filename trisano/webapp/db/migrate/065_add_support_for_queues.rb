# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

require "migration_helpers"

class AddSupportForQueues < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    transaction do
      create_table :event_queues do |t|
        t.string :queue_name, :limit => 100
        t.integer :jurisdiction_id
      end
      add_foreign_key(:event_queues, :jurisdiction_id, :entities)

      add_column :events, :jurisdiction_id, :integer

      # Give jurisdictions short names too
      if RAILS_ENV == 'production'
        say "Adding short names for jurisdictions"

        short_names = {}
        short_names['Unassigned'] = 'Unassigned'
        short_names['Bear River Health Department'] = 'Bear River'
        short_names['Central Utah Public Health Department'] = 'Central Utah'
        short_names['Davis County Health Department'] = 'Davis County'
        short_names['Salt Lake Valley Health Department'] = 'Salt Lake Valley'
        short_names['Southeastern Utah District Health Department'] = 'Southeastern Utah'
        short_names['Southwest Utah Public Health Department'] = 'Southwest Utah'
        short_names['Summit County Public Health Department'] = 'Summit County'
        short_names['Tooele County Health Department'] = 'Tooele County'
        short_names['TriCounty Health Department'] = 'TriCounty'
        short_names['Utah County Health Department'] = 'Utah County'
        short_names['Utah State'] = 'Utah State'
        short_names['Wasatch County Health Department'] = 'Wasatch County'
        short_names['Weber-Morgan Health Department'] = 'Weber-Morgan'
        short_names['Out of State'] = 'Out of State'

        Place.jurisdictions.each { |jurisdiction| jurisdiction.update_attribute(:short_name, short_names[jurisdiction.name]) }
      end
    end

  end

  def self.down
    transaction do
      drop_table :event_queues
      remove_column :events, :jurisdiction_id
      if RAILS_ENV == 'production'
        Place.jurisdictions.each { |jurisdiction| jurisdiction.update_attribute(:short_name, "") }
      end
    end
  end
end
