class UpdateLabResults < ActiveRecord::Migration
 extend MigrationHelpers

  def self.up
    remove_column :lab_results, :test_type
    add_column :lab_results, :test_type_id, :integer
    remove_column :lab_results, :test_detail
    remove_column :lab_results, :lab_result_text
    rename_column :lab_results, :interpretation_id, :test_result_id
    add_column :lab_results, :result_value, :string
    add_column :lab_results, :units, :string, :limit => 50

    # Put this back when we have bootstrapped the data
    # add_foreign_key :lab_results, :test_type_id, :common_test_types
  end

  def self.down
    add_column :lab_results, :test_type, :string
    remove_column :lab_results, :test_type_id
    add_column :lab_results, :test_detail, :string
    add_column :lab_results, :lab_result_text, :text
    rename_column :lab_results, :test_result_id, :interpretation_id
    remove_column :lab_results, :result_value
    remove_column :lab_results, :units
  end
end
