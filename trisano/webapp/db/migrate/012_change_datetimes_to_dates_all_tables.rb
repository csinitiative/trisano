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

class ChangeDatetimesToDatesAllTables < ActiveRecord::Migration
  def self.up
    change_column :events, :investigation_started_date, :date
    change_column :events, :investigation_completed_LHD_date, :date
    change_column :events, :review_completed_UDOH_date, :date
    change_column :events, :first_reported_PH_date, :date
    change_column :events, :results_reported_to_clinician_date, :date

    change_column :organizations, :duration_start_date, :date
    change_column :organizations, :duration_end_date, :date
  end

  def self.down
    change_column :events, :investigation_started_date, :datetime
    change_column :events, :investigation_completed_LHD_date, :datetime
    change_column :events, :review_completed_UDOH_date, :datetime
    change_column :events, :first_reported_PH_date, :datetime
    change_column :events, :results_reported_to_clinician_date, :datetime

    change_column :organizations, :duration_start_date, :datetime
    change_column :organizations, :duration_end_date, :datetime
  end
end
