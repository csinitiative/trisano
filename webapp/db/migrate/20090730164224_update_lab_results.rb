class UpdateLabResults < ActiveRecord::Migration
 extend MigrationHelpers

  def self.up
    add_column :lab_results, :loinc_code, :string, :limit => 10
    add_column :lab_results, :test_type_id, :integer
    add_column :lab_results, :test_result_id, :integer
    add_column :lab_results, :result_value, :string
    add_column :lab_results, :units, :string, :limit => 50
    rename_column :lab_results, :specimen_sent_to_uphl_yn_id, :specimen_sent_to_state_id
    add_column :lab_results, :test_status_id, :integer
    add_column :lab_results, :comment, :text

    # Put this back when we have bootstrapped the data
    # add_foreign_key :lab_results, :test_type_id, :common_test_types
  end

  def self.down
    remove_column :lab_results, :test_type_id
    remove_column :lab_results, :interpretation_id
    remove_column :lab_results, :result_value
    remove_column :lab_results, :units
    rename_column :lab_results, :specimen_sent_to_state_id, :specimen_sent_to_uphl_yn_id
    remove_column :lab_results, :test_status_id
    remove_column :lab_results, :comment
  end
end
