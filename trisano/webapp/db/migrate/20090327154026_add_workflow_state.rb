class AddWorkflowState < ActiveRecord::Migration
  def self.up
    add_column :events, :workflow_state, :string
    # TODO: production migration of status
    remove_column :events, :event_status
  end

  def self.down
    remove_column :events, :workflow_state
    add_column :events, :event_status, :string
  end
end
