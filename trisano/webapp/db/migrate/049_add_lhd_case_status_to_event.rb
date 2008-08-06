require "migration_helpers"

class AddLhdCaseStatusToEvent < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :events, :lhd_case_status_id, :integer
    add_foreign_key :events, :lhd_case_status_id, :external_codes
    add_index :events, :lhd_case_status_id

    remove_index (:events, :event_case_status_id)
    remove_foreign_key :events, :event_case_status_id
    rename_column :events, :event_case_status_id, :udoh_case_status_id
    add_foreign_key :events, :udoh_case_status_id, :external_codes
    add_index :events, :udoh_case_status_id
  end

  def self.down
    remove_column :events, :lhd_case_status_id

    remove_index (:events, :udoh_case_status_id)
    remove_foreign_key :events, :udoh_case_status_id
    rename_column :events, :udoh_case_status_id, :event_case_status_id
    add_foreign_key :events, :event_case_status_id, :external_codes
    add_index :events, :event_case_status_id
  end
end
