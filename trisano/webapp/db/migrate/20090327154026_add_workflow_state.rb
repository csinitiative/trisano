class AddWorkflowState < ActiveRecord::Migration
  def self.up
    Event.transaction do
      add_column :events, :workflow_state, :string

      if RAILS_ENV == 'production'
        MorbidityEvent.update_all("workflow_state = 'new'", "event_status = 'NEW'")
        MorbidityEvent.update_all("workflow_state = 'assigned_to_lhd'", "event_status = 'ASGD-LHD'")
        MorbidityEvent.update_all("workflow_state = 'accepted_by_lhd'", "event_status = 'ACPTD-LHD'")
        MorbidityEvent.update_all("workflow_state = 'rejected_by_lhd'", "event_status = 'RJCTD-LHD'")
        MorbidityEvent.update_all("workflow_state = 'assigned_to_investigator'", "event_status = 'ASGD-INV'")
        MorbidityEvent.update_all("workflow_state = 'under_investigation'", "event_status = 'UI'")
        MorbidityEvent.update_all("workflow_state = 'rejected_by_investigator'", "event_status = 'RJCTD-INV'")
        MorbidityEvent.update_all("workflow_state = 'investigation_complete'", "event_status = 'IC'")
        MorbidityEvent.update_all("workflow_state = 'approved_by_lhd'", "event_status = 'APP-LHD'")
        MorbidityEvent.update_all("workflow_state = 'reopened_by_manager'", "event_status = 'RO-MGR'")
        MorbidityEvent.update_all("workflow_state = 'closed'", "event_status = 'CLOSED'")
        MorbidityEvent.update_all("workflow_state = 'reopened_by_state'", "event_status = 'RO-STATE'")

        ContactEvent.update_all("workflow_state = 'new'")
        
        CoreField.update_all "key = 'morbidity_event[workflow_state]'", 
                             "key = 'morbidity_event[event_status]'"

        CsvField.update_all "long_name = 'patient_workflow_state', use_description = 'workflow_state'",
                            "long_name = 'patient_event_status'"

        ExportColumn.update_all "column_name = 'workflow_state'",
                                "column_name = 'event_status'"
      end
      
      remove_column :events, :event_status
    end
  end

  def self.down
    remove_column :events, :workflow_state
    add_column :events, :event_status, :string
  end
end
