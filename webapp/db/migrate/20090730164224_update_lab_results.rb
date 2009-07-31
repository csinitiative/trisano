class UpdateLabResults < ActiveRecord::Migration
 extend MigrationHelpers

  def self.up
    remove_column :lab_results, :test_type
    add_column :lab_results, :test_type_id, :integer

    # Put this back when we have bootstrapped the data
    # add_foreign_key :lab_results, :test_type_id, :common_test_types
  end

  def self.down
    add_column :lab_results, :test_type, :string
    remove_column :lab_results, :test_type_id
  end
end
