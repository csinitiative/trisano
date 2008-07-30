require "migration_helpers"

class AlterTestedAtUphl < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up

    remove_index :lab_results, :tested_at_uphl_yn_id
    remove_foreign_key :lab_results, :tested_at_uphl_yn_id
    rename_column :lab_results, :tested_at_uphl_yn_id, :specimen_sent_to_uphl_yn_id
    add_foreign_key :lab_results, :specimen_sent_to_uphl_yn_id, :external_codes
    add_index :lab_results, :specimen_sent_to_uphl_yn_id
  end

  def self.down
    remove_index :lab_results, :specimen_sent_to_uphl_yn_id
    remove_foreign_key :lab_results, :specimen_sent_to_uphl_yn_id
    rename_column :lab_results, :specimen_sent_to_uphl_yn_id, :tested_at_uphl_yn_id
    add_foreign_key :lab_results, :tested_at_uphl_yn_id, :external_codes
    add_index :lab_results, :tested_at_uphl_yn_id
  end
end
