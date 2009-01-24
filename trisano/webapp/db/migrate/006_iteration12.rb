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

class Iteration12 < ActiveRecord::Migration
  def self.up
# create table people_races because people can belong to more than one race.
		create_table :people_races, :force => true do |t|
		    t.integer  :race_id
		    t.integer  :entity_id

		    t.timestamps
		end
#  add columns for people
		add_column :people, :food_handler_id, :integer
		add_column :people, :healthcare_worker_id, :integer
		add_column :people, :group_living_id, :integer
		add_column :people, :day_care_association_id, :integer
		add_column :people, :age_type_id, :integer
		add_column :people, :risk_factors, :string, :limit=>25
		add_column :people, :risk_factors_notes, :string, :limit=>100
		add_column :people, :approximate_age_no_birthday, :integer
#  add column to places
		add_column :places, :place_type_id, :integer
# add columns for events
		add_column :events, :outbreak_associated_id ,  :integer
		add_column :events, :outbreak_name ,  :string
		add_column :events, :investigation_LHD_status_id ,  :integer
		add_column :events, :investigation_started_date, :timestamp
		add_column :events, :investigation_completed_LHD_date, :timestamp
		add_column :events, :review_completed_UDOH_date,  :timestamp
		add_column :events, :first_reported_PH_date ,  :timestamp
		add_column :events, :results_reported_to_clinician_date,  :timestamp
		add_column :events, :MMWR ,  :integer
		add_column :events, :record_number ,  :string, :limit=>20

  end

  def self.down
		remove_column :people, :food_handler_id
		remove_column :people, :healthcare_worker_id
		remove_column :people, :group_living_id
		remove_column :people, :day_care_association_id
		remove_column :people, :age_type_id
		remove_column :people, :risk_factors
		remove_column :people, :risk_factors_notes
		remove_column :people, :approximate_age_no_birthday
		drop_table :people_races
		remove_column :events, :outbreak_associated_id
		remove_column :events, :outbreak_name
		remove_column :events, :investigation_LHD_status_id
		remove_column :events, :investigation_started_date
		remove_column :events, :investigation_completed_LHD_date
		remove_column :events, :review_completed_UDOH_date
		remove_column :events, :first_reported_PH_date
		remove_column :events, :results_reported_to_clinician_date
		# remove_column :events, :MMRW
		remove_column :events, :record_number
  end
end
