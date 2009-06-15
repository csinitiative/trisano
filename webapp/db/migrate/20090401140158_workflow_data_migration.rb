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

class WorkflowDataMigration < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'        
      execute <<-SQL
        update events set workflow_state = 'new' 
        where event_status = 'NEW' and type = 'MorbidityEvent'
      SQL

      execute <<-SQL
        update events set workflow_state = 'assigned_to_lhd'
        where event_status = 'ASGD-LHD' and type = 'MorbidityEvent'
      SQL
      
      execute <<-SQL
        update events set workflow_state = 'accepted_by_lhd'
        where event_status = 'ACPTD-LHD' and type = 'MorbidityEvent'
      SQL

      execute <<-SQL
        update events set workflow_state = 'rejected_by_lhd' 
        where event_status = 'RJCTD-LHD' and type = 'MorbidityEvent'
      SQL

      execute <<-SQL
        update events set workflow_state = 'assigned_to_investigator'
        where event_status = 'ASGD-INV' and type = 'MorbidityEvent'
      SQL
      
      execute <<-SQL
        update events set workflow_state = 'under_investigation'
        where event_status = 'UI' and type = 'MorbidityEvent'
      SQL

      execute <<-SQL
        update events set workflow_state = 'rejected_by_investigator'
        where event_status = 'RJCTD-INV' and type = 'MorbidityEvent'
      SQL

      execute <<-SQL
        update events set workflow_state = 'investigation_complete'
        where event_status = 'IC' and type = 'MorbidityEvent'
      SQL

      execute <<-SQL
        update events set workflow_state = 'approved_by_lhd'
        where event_status = 'APP-LHD' and type = 'MorbidityEvent'
      SQL

      execute <<-SQL
        update events set workflow_state = 'reopened_by_manager'
        where event_status = 'RO-MGR' and type = 'MorbidityEvent'
      SQL

      execute <<-SQL
        update events set workflow_state = 'closed'
        where event_status = 'CLOSED' and type = 'MorbidityEvent'
      SQL

      execute <<-SQL
        update events set workflow_state = 'reopened_by_state'
        where event_status = 'RO-STATE' and type = 'MorbidityEvent'
      SQL

      execute <<-SQL
        update events set workflow_state = 'new'
        where type = 'ContactEvent'
      SQL
      
      execute <<-SQL
        update core_fields set key = 'morbidity_event[workflow_state]'
        where key = 'morbidity_event[event_status]'
      SQL

      execute <<-SQL
        update csv_fields set long_name = 'patient_workflow_state', 
                              use_description = 'workflow_state'
        where long_name = 'patient_event_status'
      SQL

      execute <<-SQL
        update export_columns set column_name = 'workflow_state'
        where column_name = 'event_status'
      SQL
    end
    
    remove_column :events, :event_status
end

  def self.down
    add_column :events, :event_status, :string
  end
end
