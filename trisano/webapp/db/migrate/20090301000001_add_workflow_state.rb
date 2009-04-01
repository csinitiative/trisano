class AddWorkflowState < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    ActiveRecord::Base.transaction do
      add_column :events, :workflow_state, :string
    end
  end

  def self.down
    remove_column :events, :workflow_state
  end
end
