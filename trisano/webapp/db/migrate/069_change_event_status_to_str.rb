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

class ChangeEventStatusToStr < ActiveRecord::Migration
  def self.up
    transaction do
      add_column :events, :event_status, :string

      # migrate data
      status_codes = ExternalCode.find_all_by_code_name('eventstatus')

      status_codes.each do |code|
        Event.update_all("event_status = '#{code.the_code}'", "event_status_id = #{code.id}")
      end
      # end migrate data

      remove_column :events, :event_status_id

      ExternalCode.delete_all("code_name = 'eventstatus'")
    end
  end

  def self.down

    transaction do
      add_column :events, :event_status_id, :integer

      # Rebuild eventstatus rows in external_codes
      sort_order = 0
      Event.get_states_and_descriptions.each do |state|
        ExternalCode.create({:code_name => 'eventstatus', :the_code => state.state, :code_description => state.description, :sort_order => sort_order += 5, :live => true})
      end

      # Reset events to point at external_codes
      status_codes = ExternalCode.find_all_by_code_name('eventstatus')

      status_codes.each do |code|
        Event.update_all("event_status_id = #{code.id}", "event_status = '#{code.the_code}'")
      end

      remove_column :events, :event_status
    end 

  end
end
